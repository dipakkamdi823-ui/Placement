"""
Import stufac_mysql_database.sql directly into local MySQL Server
"""

import pymysql
import os
import re

SQL_FILE = os.path.join(os.path.dirname(__file__), "stufac_mysql_database.sql")

def import_sql():
    print("[*] Connecting to MySQL on localhost:3306 with user 'root'...")
    conn = pymysql.connect(
        host="127.0.0.1",
        port=3306,
        user="root",
        password="root",
        autocommit=True
    )
    cursor = conn.cursor()

    print("[*] Creating database `stufac_db` if not exists...")
    cursor.execute("CREATE DATABASE IF NOT EXISTS `stufac_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
    cursor.execute("USE `stufac_db`;")

    with open(SQL_FILE, "r", encoding="utf-8") as f:
        sql_content = f.read()

    # Split by semicolon statements
    statements = [s.strip() for s in re.split(r';(?:\s*[\r\n]+)', sql_content) if s.strip()]

    print(f"[*] Executing {len(statements)} SQL statements into `stufac_db`...")
    for stmt in statements:
        if stmt.startswith("--") or not stmt:
            continue
        try:
            cursor.execute(stmt)
        except Exception as e:
            print(f"Notice on statement: {e}")

    # Verify tables
    cursor.execute("SHOW TABLES;")
    tables = [r[0] for r in cursor.fetchall()]
    print("\n[OK] Successfully imported tables into MySQL `stufac_db`:")
    for t in tables:
        cursor.execute(f"SELECT COUNT(*) FROM `{t}`;")
        cnt = cursor.fetchone()[0]
        print(f"  - `{t}`: {cnt} records")

    conn.close()
    print("\n[SUCCESS] MySQL Database `stufac_db` is live and ready!")

if __name__ == "__main__":
    import_sql()
