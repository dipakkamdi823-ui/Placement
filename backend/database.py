import os
import json
import sqlite3

# Flexible Database Layer Supporting MySQL (Primary / Configured) with Automatic SQLite / Mongo Fallback

MYSQL_CONFIG = {
    "host": os.environ.get("MYSQL_HOST", "localhost"),
    "user": os.environ.get("MYSQL_USER", "root"),
    "password": os.environ.get("MYSQL_PASSWORD", "root"),
    "database": os.environ.get("MYSQL_DB", "stufac_db"),
    "port": int(os.environ.get("MYSQL_PORT", 3306))
}

DB_SQLITE_PATH = os.path.join(os.path.dirname(__file__), "stufac_persistent.db")

class RowDict(dict):
    """Dictionary that supports both key-based access (.get(), ['key']) and index-based access (row[0])"""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._values = []

    def __getitem__(self, item):
        if isinstance(item, int):
            return self._values[item]
        return super().__getitem__(item)

def row_dict_factory(cursor, row):
    d = RowDict()
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
        d._values.append(row[idx])
    return d

class CursorWrapper:
    def __init__(self, cursor, is_mysql):
        self.cursor = cursor
        self.is_mysql = is_mysql

    def execute(self, query, params=()):
        if self.is_mysql and "?" in query:
            query = query.replace("?", "%s")
        return self.cursor.execute(query, params)

    def fetchone(self):
        return self.cursor.fetchone()

    def fetchall(self):
        return self.cursor.fetchall()

    @property
    def lastrowid(self):
        return self.cursor.lastrowid

class DBWrapper:
    def __init__(self, conn, is_mysql=False):
        self.conn = conn
        self.is_mysql = is_mysql

    def cursor(self):
        if self.is_mysql:
            try:
                return CursorWrapper(self.conn.cursor(dictionary=True), is_mysql=True)
            except Exception:
                return CursorWrapper(self.conn.cursor(), is_mysql=True)
        else:
            return CursorWrapper(self.conn.cursor(), is_mysql=False)

    def commit(self):
        return self.conn.commit()

    def close(self):
        return self.conn.close()

class DatabaseLayer:
    def __init__(self):
        self.db_type = "sqlite"
        self.mysql_driver = "pymysql"
        self._init_connection()

    def _init_connection(self):
        # Check if MySQL can connect
        try:
            try:
                import pymysql
                import pymysql.cursors
                conn = pymysql.connect(
                    host=MYSQL_CONFIG["host"],
                    user=MYSQL_CONFIG["user"],
                    password=MYSQL_CONFIG["password"],
                    port=MYSQL_CONFIG["port"],
                    cursorclass=pymysql.cursors.DictCursor,
                    autocommit=True
                )
                cursor = conn.cursor()
                cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{MYSQL_CONFIG['database']}`")
                cursor.execute(f"USE `{MYSQL_CONFIG['database']}`")
                conn.close()
                self.db_type = "mysql"
                self.mysql_driver = "pymysql"
                print(f"[MySQL] Successfully connected to MySQL database `{MYSQL_CONFIG['database']}` via PyMySQL.")
            except Exception:
                import mysql.connector
                conn = mysql.connector.connect(
                    host=MYSQL_CONFIG["host"],
                    user=MYSQL_CONFIG["user"],
                    password=MYSQL_CONFIG["password"],
                    port=MYSQL_CONFIG["port"]
                )
                cursor = conn.cursor()
                cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{MYSQL_CONFIG['database']}`")
                conn.close()
                self.db_type = "mysql"
                self.mysql_driver = "mysql.connector"
                print(f"[MySQL] Successfully connected to MySQL database `{MYSQL_CONFIG['database']}` via mysql.connector.")
        except Exception as e:
            print(f"[Database] MySQL connection not active ({e}). Using embedded SQLite database layer.")
            self.db_type = "sqlite"

        self.setup_tables()

    def get_connection(self):
        if self.db_type == "mysql":
            if getattr(self, "mysql_driver", "") == "pymysql":
                import pymysql
                import pymysql.cursors
                conn = pymysql.connect(
                    host=MYSQL_CONFIG["host"],
                    user=MYSQL_CONFIG["user"],
                    password=MYSQL_CONFIG["password"],
                    database=MYSQL_CONFIG["database"],
                    port=MYSQL_CONFIG["port"],
                    cursorclass=pymysql.cursors.DictCursor,
                    autocommit=True
                )
                return DBWrapper(conn, is_mysql=True)
            else:
                import mysql.connector
                conn = mysql.connector.connect(**MYSQL_CONFIG)
                return DBWrapper(conn, is_mysql=True)
        else:
            conn = sqlite3.connect(DB_SQLITE_PATH, timeout=20.0)
            conn.row_factory = row_dict_factory
            return DBWrapper(conn, is_mysql=False)

    def setup_tables(self):
        conn = self.get_connection()
        cursor = conn.cursor()

        if self.db_type == "mysql":
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS profile (
                student_id VARCHAR(50) PRIMARY KEY,
                name VARCHAR(100),
                email VARCHAR(100) UNIQUE,
                roll_no VARCHAR(50),
                dept VARCHAR(100),
                year VARCHAR(50),
                cgpa VARCHAR(20),
                contact VARCHAR(50),
                linkedin VARCHAR(150),
                github VARCHAR(150),
                bio TEXT,
                profile_completion_pct INT,
                verified_by_faculty INT,
                consent_resume_sharing INT,
                admission_year VARCHAR(50),
                passout_year VARCHAR(50),
                program VARCHAR(100)
            )
            """)
            for col, typ in [('admission_year', 'VARCHAR(50)'), ('passout_year', 'VARCHAR(50)'), ('program', 'VARCHAR(100)')]:
                try:
                    cursor.execute(f"ALTER TABLE profile ADD COLUMN {col} {typ}")
                except Exception:
                    pass
            for col, typ in [('admission_year', 'INT'), ('passout_year', 'INT'), ('program', 'VARCHAR(100)')]:
                try:
                    cursor.execute(f"ALTER TABLE student_profiles ADD COLUMN {col} {typ}")
                except Exception:
                    pass

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS resume (
                resume_id VARCHAR(50) PRIMARY KEY,
                filename VARCHAR(150),
                file_size VARCHAR(50),
                upload_date VARCHAR(100),
                version INT,
                status VARCHAR(50),
                parsed_data TEXT,
                file_url VARCHAR(500),
                file_data LONGTEXT,
                student_id VARCHAR(50),
                student_email VARCHAR(150)
            )
            """)
            for col, typ in [('file_url', 'VARCHAR(500)'), ('file_data', 'LONGTEXT'), ('student_id', 'VARCHAR(50)'), ('student_email', 'VARCHAR(150)')]:
                try:
                    cursor.execute(f"ALTER TABLE resume ADD COLUMN {col} {typ}")
                except Exception:
                    pass
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS skills (
                skill_id VARCHAR(50) PRIMARY KEY,
                skill_name VARCHAR(100),
                category VARCHAR(100),
                source VARCHAR(50),
                student_id VARCHAR(50),
                student_email VARCHAR(150)
            )
            """)
            for col, typ in [('student_id', 'VARCHAR(50)'), ('student_email', 'VARCHAR(150)')]:
                try:
                    cursor.execute(f"ALTER TABLE skills ADD COLUMN {col} {typ}")
                except Exception:
                    pass
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS opportunities (
                id VARCHAR(50) PRIMARY KEY,
                title VARCHAR(150),
                organization VARCHAR(150),
                domain VARCHAR(100),
                location VARCHAR(100),
                stipend VARCHAR(100),
                duration VARCHAR(50),
                mode VARCHAR(50),
                deadline VARCHAR(50),
                description TEXT,
                eligibility TEXT,
                required_skills TEXT,
                type VARCHAR(50)
            )
            """)
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS applications (
                application_id VARCHAR(50) PRIMARY KEY,
                student_id INT,
                student_name VARCHAR(150),
                student_email VARCHAR(150),
                opportunity_id VARCHAR(50),
                opportunity_title VARCHAR(150),
                organization VARCHAR(150),
                applied_date VARCHAR(50),
                status VARCHAR(50),
                last_updated VARCHAR(100),
                notes TEXT
            )
            """)
            for col, typ in [('student_id', 'INT'), ('student_name', 'VARCHAR(150)'), ('student_email', 'VARCHAR(150)')]:
                try:
                    cursor.execute(f"ALTER TABLE applications ADD COLUMN {col} {typ}")
                except Exception:
                    pass

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS notifications (
                id VARCHAR(50) PRIMARY KEY,
                student_email VARCHAR(255),
                title VARCHAR(150),
                message TEXT,
                timestamp VARCHAR(50),
                `read` INT DEFAULT 0,
                type VARCHAR(50),
                created_at DATETIME
            )
            """)
            for col, typ in [('student_email', 'VARCHAR(255)'), ('created_at', 'DATETIME')]:
                try:
                    cursor.execute(f"ALTER TABLE notifications ADD COLUMN {col} {typ}")
                except Exception:
                    pass
        else:
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS profile (
                student_id TEXT PRIMARY KEY,
                name TEXT, email TEXT UNIQUE, roll_no TEXT, dept TEXT, year TEXT, cgpa TEXT,
                contact TEXT, linkedin TEXT, github TEXT, bio TEXT, profile_completion_pct INTEGER,
                verified_by_faculty INTEGER, consent_resume_sharing INTEGER,
                admission_year TEXT, passout_year TEXT, program TEXT
            )
            """)
            for col in ["admission_year", "passout_year", "program"]:
                try:
                    cursor.execute(f"ALTER TABLE profile ADD COLUMN {col} TEXT")
                except Exception:
                    pass

            cursor.execute("""
            CREATE TABLE IF NOT EXISTS resume (
                resume_id TEXT PRIMARY KEY, filename TEXT, file_size TEXT, upload_date TEXT,
                version INTEGER, status TEXT, parsed_data TEXT, file_url TEXT, file_data TEXT,
                student_id TEXT, student_email TEXT
            )
            """)
            for col in ["file_url", "file_data", "student_id", "student_email"]:
                try:
                    cursor.execute(f"ALTER TABLE resume ADD COLUMN {col} TEXT")
                except Exception:
                    pass
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS skills (
                skill_id TEXT PRIMARY KEY, skill_name TEXT, category TEXT, source TEXT, student_id TEXT, student_email TEXT
            )
            """)
            for col in ["student_id", "student_email"]:
                try:
                    cursor.execute(f"ALTER TABLE skills ADD COLUMN {col} TEXT")
                except Exception:
                    pass
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS opportunities (
                id TEXT PRIMARY KEY, title TEXT, organization TEXT, domain TEXT, location TEXT,
                stipend TEXT, duration TEXT, mode TEXT, deadline TEXT, description TEXT,
                eligibility TEXT, required_skills TEXT, type TEXT
            )
            """)
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS applications (
                application_id TEXT PRIMARY KEY, student_id TEXT, student_name TEXT, student_email TEXT,
                opportunity_id TEXT, opportunity_title TEXT,
                organization TEXT, applied_date TEXT, status TEXT, last_updated TEXT, notes TEXT
            )
            """)
            for col in ["student_id", "student_name", "student_email"]:
                try:
                    cursor.execute(f"ALTER TABLE applications ADD COLUMN {col} TEXT")
                except Exception:
                    pass
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE,
                password_hash TEXT,
                role TEXT DEFAULT 'Student',
                is_active INTEGER DEFAULT 1,
                is_verified INTEGER DEFAULT 0
            )
            """)
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS student_profiles (
                student_id INTEGER PRIMARY KEY,
                roll_number TEXT,
                first_name TEXT,
                last_name TEXT,
                department TEXT,
                graduation_year INTEGER DEFAULT 2027,
                cgpa REAL DEFAULT 0.0,
                preferred_opportunity_type TEXT DEFAULT 'Both',
                verification_status TEXT DEFAULT 'Pending',
                placement_readiness_score REAL DEFAULT 0.0,
                phone_number TEXT,
                linkedin TEXT,
                github TEXT,
                bio TEXT,
                passout_year INTEGER,
                admission_year INTEGER,
                program TEXT
            )
            """)
            for col in ["phone_number", "linkedin", "github", "bio", "active_resume_id", "passout_year", "admission_year", "program"]:
                try:
                    cursor.execute(f"ALTER TABLE student_profiles ADD COLUMN {col} TEXT")
                except Exception:
                    pass
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS notifications (
                id TEXT PRIMARY KEY, title TEXT, message TEXT, timestamp TEXT, read INTEGER, type TEXT
            )
            """)

        conn.commit()
        conn.close()

db_layer = DatabaseLayer()

def init_db():
    db_layer.setup_tables()

def get_db():
    return db_layer.get_connection()

