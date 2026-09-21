import sys
sys.path.insert(0, '.')
from database import get_db

conn = get_db()
cursor = conn.cursor()

print("=== Direct query: GROUP BY student_email ===")
cursor.execute("""
    SELECT student_email,
           COUNT(application_id) AS companies_applied,
           SUM(CASE WHEN LOWER(COALESCE(status, '')) IN ('shortlisted', 'selected', 'offered', 'offer', 'accepted')
                    THEN 1 ELSE 0 END) AS shortlisted_count
    FROM applications
    WHERE student_email IS NOT NULL AND student_email != ''
    GROUP BY student_email
""")
rows = cursor.fetchall()
print("Rows returned:", len(rows))
for r in rows:
    print(r)

conn.close()
