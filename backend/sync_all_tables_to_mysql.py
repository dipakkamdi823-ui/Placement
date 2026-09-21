import os
import sqlite3
import pymysql
import json

def sync_all():
    print("Connecting to MySQL stufac_db...")
    m_conn = pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="root",
        database="stufac_db",
        autocommit=True,
        cursorclass=pymysql.cursors.DictCursor
    )
    m_cur = m_conn.cursor()

    # 1. Sync from db.sqlite3 (Django models, auth, faculty, certificates, audit logs, sessions)
    if os.path.exists("backend/db.sqlite3"):
        print("\n--- Syncing Django tables from backend/db.sqlite3 ---")
        s_conn = sqlite3.connect("backend/db.sqlite3")
        s_conn.row_factory = sqlite3.Row
        s_cur = s_conn.cursor()

        s_cur.execute("SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
        tables = s_cur.fetchall()

        for t in tables:
            tname = t["name"]
            sql = t["sql"]
            # Check if table exists in MySQL
            m_cur.execute("SHOW TABLES LIKE %s", (tname,))
            if not m_cur.fetchone():
                mysql_sql = sql.replace('"', '`')
                mysql_sql = mysql_sql.replace("DEFERRABLE INITIALLY DEFERRED", "")
                mysql_sql = mysql_sql.replace("AUTOINCREMENT", "AUTO_INCREMENT")
                mysql_sql = mysql_sql.replace("datetime", "DATETIME")
                mysql_sql = mysql_sql.replace("bool", "TINYINT(1)")
                mysql_sql = mysql_sql.replace("varchar", "VARCHAR")
                mysql_sql = mysql_sql.replace("integer NOT NULL PRIMARY KEY AUTO_INCREMENT", "INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY")
                # Clean table creation
                print(f"Creating missing table: {tname}")
                try:
                    m_cur.execute(mysql_sql)
                except Exception as e:
                    print(f"  Note on creating {tname}: {e}")

            # Now sync data
            try:
                s_cur.execute(f"SELECT * FROM `{tname}`")
                rows = s_cur.fetchall()
                if rows:
                    cols = [k for k in rows[0].keys()]
                    col_names = ", ".join([f"`{c}`" for c in cols])
                    placeholders = ", ".join(["%s"] * len(cols))
                    insert_sql = f"INSERT IGNORE INTO `{tname}` ({col_names}) VALUES ({placeholders})"
                    for r in rows:
                        val_list = [r[k] for k in cols]
                        try:
                            m_cur.execute(insert_sql, val_list)
                        except Exception as e:
                            pass
                    print(f"  Synced {len(rows)} rows into `{tname}`")
            except Exception as e:
                print(f"  Data sync error on {tname}: {e}")

        s_conn.close()

    # 2. Sync from stufac_persistent.db (student tables)
    if os.path.exists("backend/stufac_persistent.db"):
        print("\n--- Syncing Student tables from backend/stufac_persistent.db ---")
        st_conn = sqlite3.connect("backend/stufac_persistent.db")
        st_conn.row_factory = sqlite3.Row
        st_cur = st_conn.cursor()

        st_cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
        for t in st_cur.fetchall():
            tname = t["name"]
            st_cur.execute(f"SELECT * FROM `{tname}`")
            rows = st_cur.fetchall()
            if rows:
                cols = [k for k in rows[0].keys()]
                col_names = ", ".join([f"`{c}`" for c in cols])
                placeholders = ", ".join(["%s"] * len(cols))
                insert_sql = f"INSERT IGNORE INTO `{tname}` ({col_names}) VALUES ({placeholders})"
                for r in rows:
                    val_list = [r[k] for k in cols]
                    try:
                        m_cur.execute(insert_sql, val_list)
                    except Exception as e:
                        pass
                print(f"  Synced {len(rows)} rows into `{tname}`")
        st_conn.close()

    # 3. Seed data for faculty, organizations, opportunities if empty
    print("\n--- Checking and Seeding Opportunities and Organizations ---")
    m_cur.execute("SELECT COUNT(*) as cnt FROM organizations")
    if m_cur.fetchone()["cnt"] == 0:
        print("Running seed_data.py to populate organizations & opportunities...")
        os.system("python backend/seed_data.py")

    # 4. List all MySQL tables and count rows
    print("\n========================================================")
    print("  ALL TABLES IN MYSQL stufac_db")
    print("========================================================")
    m_cur.execute("SHOW TABLES")
    all_tables = [list(r.values())[0] for r in m_cur.fetchall()]
    for tbl in sorted(all_tables):
        m_cur.execute(f"SELECT COUNT(*) as cnt FROM `{tbl}`")
        cnt = m_cur.fetchone()["cnt"]
        print(f"  - {tbl:<30} ({cnt} rows)")

    print("========================================================")
    print("Total Tables in MySQL:", len(all_tables))
    m_conn.close()

if __name__ == "__main__":
    sync_all()
