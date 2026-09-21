import sys
sys.path.insert(0, '.')
from database import get_db

conn = get_db()
cursor = conn.cursor()

print("=== APPLICATIONS table columns ===")
try:
    cursor.execute("SHOW COLUMNS FROM applications")
    for r in cursor.fetchall():
        print(r)
except Exception as e:
    print("Error:", e)

print("\n=== APPLICATIONS data ===")
try:
    cursor.execute("SELECT application_id, student_id, student_email, student_name, organization, status FROM applications LIMIT 10")
    for r in cursor.fetchall():
        print(r)
except Exception as e:
    print("Error:", e)
    # Try without student_email
    cursor.execute("SELECT * FROM applications LIMIT 5")
    for r in cursor.fetchall():
        print(r)

conn.close()
