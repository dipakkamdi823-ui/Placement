"""
Generate complete MySQL Dump (.sql file) directly from live MySQL stufac_db
Usage: python generate_mysql_dump.py
"""

import pymysql
import os

SQL_OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "stufac_mysql_database.sql")

def generate_mysql_dump():
    print("Connecting to live MySQL stufac_db to generate SQL dump...")
    conn = pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="root",
        database="stufac_db",
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor
    )
    cursor = conn.cursor()

    lines = [
        "-- ========================================================",
        "-- STUFAC: Student & Faculty Talent Alignment Platform",
        "-- Complete MySQL Database Export & Setup Script",
        "-- ========================================================",
        "",
        "CREATE DATABASE IF NOT EXISTS `stufac_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;",
        "USE `stufac_db`;",
        "",
        "SET FOREIGN_KEY_CHECKS = 0;",
        ""
    ]

    cursor.execute("SHOW TABLES")
    raw_tables = cursor.fetchall()
    tables = [list(r.values())[0] for r in raw_tables]

    for tbl in sorted(tables):
        lines.append(f"-- --------------------------------------------------------")
        lines.append(f"-- Table structure for `{tbl}`")
        lines.append(f"-- --------------------------------------------------------")
        lines.append(f"DROP TABLE IF EXISTS `{tbl}`;")

        # Get CREATE TABLE definition
        cursor.execute(f"SHOW CREATE TABLE `{tbl}`")
        create_stmt = cursor.fetchone()["Create Table"]
        lines.append(create_stmt + ";")
        lines.append("")

        # Get data
        cursor.execute(f"SELECT * FROM `{tbl}`")
        rows = cursor.fetchall()
        if rows:
            lines.append(f"-- Dumping data for table `{tbl}` ({len(rows)} records)")
            cols = list(rows[0].keys())
            cols_str = ", ".join([f"`{c}`" for c in cols])
            
            for r in rows:
                val_list = []
                for c in cols:
                    v = r[c]
                    if v is None:
                        val_list.append("NULL")
                    elif isinstance(v, (int, float)):
                        val_list.append(str(v))
                    else:
                        clean_str = str(v).replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r")
                        val_list.append(f"'{clean_str}'")
                lines.append(f"INSERT INTO `{tbl}` ({cols_str}) VALUES ({', '.join(val_list)});")
            lines.append("")

    lines.append("SET FOREIGN_KEY_CHECKS = 1;")
    lines.append("-- Complete database dump finished successfully.")

    with open(SQL_OUTPUT_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    conn.close()
    print(f"[OK] Full MySQL Database script exported to: {SQL_OUTPUT_PATH}")
    print(f"[OK] Total Tables Dumped: {len(tables)}")
    print(f"[OK] Total File Size: {os.path.getsize(SQL_OUTPUT_PATH) / 1024:.2f} KB")

if __name__ == "__main__":
    generate_mysql_dump()
