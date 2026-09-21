import os
import sqlite3
import pymysql
import json
import re

def clean_sqlite_ddl(sql):
    sql = sql.replace('"', '`')
    sql = sql.replace("DEFERRABLE INITIALLY DEFERRED", "")
    sql = sql.replace("AUTOINCREMENT", "AUTO_INCREMENT")
    sql = sql.replace("datetime", "DATETIME")
    sql = sql.replace("bool", "TINYINT(1)")
    sql = sql.replace("varchar", "VARCHAR")
    sql = sql.replace("integer NOT NULL PRIMARY KEY AUTO_INCREMENT", "INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY")
    sql = sql.replace("integer unsigned", "INT UNSIGNED")
    sql = sql.replace("integer", "INT")
    sql = sql.replace("real", "DOUBLE")
    # Remove SQLite index names inside create table if any
    return sql

def full_sync():
    print("==================================================")
    print("  FULL SYNC: ALL PROJECT TABLES INTO MYSQL stufac_db")
    print("==================================================")

    m_conn = pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="root",
        database="stufac_db",
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )
    m_cur = m_conn.cursor()

    # Disable foreign key checks for clean structure alignment
    m_cur.execute("SET FOREIGN_KEY_CHECKS = 0")

    # 1. Sync Django DB (db.sqlite3)
    if os.path.exists("backend/db.sqlite3"):
        s_conn = sqlite3.connect("backend/db.sqlite3")
        s_conn.row_factory = sqlite3.Row
        s_cur = s_conn.cursor()

        s_cur.execute("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
        tables = s_cur.fetchall()

        for t in tables:
            tname = t["name"]
            sql = t["sql"]
            if not sql:
                continue

            # Drop and recreate if schema is mismatched (like opportunities)
            m_cur.execute(f"DROP TABLE IF EXISTS `{tname}`")
            clean_sql = clean_sqlite_ddl(sql)
            try:
                m_cur.execute(clean_sql)
                print(f"Created table: `{tname}`")
            except Exception as e:
                print(f"Error creating `{tname}`: {e}")
                continue

            # Copy data
            s_cur.execute(f"SELECT * FROM `{tname}`")
            rows = s_cur.fetchall()
            if rows:
                cols = list(rows[0].keys())
                col_names = ", ".join([f"`{c}`" for c in cols])
                placeholders = ", ".join(["%s"] * len(cols))
                insert_sql = f"INSERT INTO `{tname}` ({col_names}) VALUES ({placeholders})"
                for r in rows:
                    val_list = [r[k] for k in cols]
                    try:
                        m_cur.execute(insert_sql, val_list)
                    except Exception as e:
                        pass
                print(f"  -> Populated {len(rows)} records into `{tname}`")
            else:
                print(f"  -> `{tname}` initialized (0 records)")

        s_conn.close()

    # 2. Sync Student DB (stufac_persistent.db)
    if os.path.exists("backend/stufac_persistent.db"):
        st_conn = sqlite3.connect("backend/stufac_persistent.db")
        st_conn.row_factory = sqlite3.Row
        st_cur = st_conn.cursor()

        st_cur.execute("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
        st_tables = st_cur.fetchall()

        for t in st_tables:
            tname = t["name"]
            sql = t["sql"]
            if not sql:
                continue

            # If not created by Django, create it
            m_cur.execute("SHOW TABLES LIKE %s", (tname,))
            if not m_cur.fetchone():
                clean_sql = clean_sqlite_ddl(sql)
                try:
                    m_cur.execute(clean_sql)
                    print(f"Created student table: `{tname}`")
                except Exception as e:
                    print(f"Error creating student `{tname}`: {e}")

            # Copy data
            st_cur.execute(f"SELECT * FROM `{tname}`")
            rows = st_cur.fetchall()
            if rows:
                cols = list(rows[0].keys())
                col_names = ", ".join([f"`{c}`" for c in cols])
                placeholders = ", ".join(["%s"] * len(cols))
                insert_sql = f"INSERT IGNORE INTO `{tname}` ({col_names}) VALUES ({placeholders})"
                for r in rows:
                    val_list = [r[k] for k in cols]
                    try:
                        m_cur.execute(insert_sql, val_list)
                    except Exception as e:
                        pass
                print(f"  -> Populated {len(rows)} records into student table `{tname}`")

        st_conn.close()

    m_cur.execute("SET FOREIGN_KEY_CHECKS = 1")

    # 3. Print complete table catalog
    print("\n========================================================")
    print("  ALL DATABASE TABLES LIVE IN MYSQL (stufac_db)")
    print("========================================================")
    m_cur.execute("SHOW TABLES")
    all_tables = [list(r.values())[0] for r in m_cur.fetchall()]
    for i, tbl in enumerate(sorted(all_tables), 1):
        m_cur.execute(f"SELECT COUNT(*) as cnt FROM `{tbl}`")
        cnt = m_cur.fetchone()["cnt"]
        print(f"  [{i:02d}] {tbl:<32} -> {cnt:>4} rows")

    print("========================================================")
    print(f"  Total Tables in stufac_db: {len(all_tables)}")
    print("========================================================")

    # 4. Generate updated MySQL dump for submission
    print("\nExporting complete updated stufac_mysql_database.sql...")
    os.system("python backend/generate_mysql_dump.py")

    m_conn.close()

if __name__ == "__main__":
    full_sync()
