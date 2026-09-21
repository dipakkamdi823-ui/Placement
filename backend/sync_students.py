"""
sync_students.py
Syncs real registered students from MySQL -> Django StudentVerificationRequest
so the faculty dashboard shows actual students, not seed/fake data.
"""
import os
import django
import uuid

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from api.db_helper import get_db
from faculty_app.models import StudentVerificationRequest

conn = get_db()
c = conn.cursor()
c.execute("""
    SELECT u.user_id, u.email, sp.first_name, sp.last_name,
           sp.roll_number, sp.department, sp.verification_status
    FROM users u
    LEFT JOIN student_profiles sp ON u.user_id = sp.student_id
""")
rows = c.fetchall()
print(f"Found {len(rows)} real students in MySQL")

deleted, _ = StudentVerificationRequest.objects.filter(email__endswith="@student.edu").delete()
print(f"Removed {deleted} fake seed records")

status_map = {"Approved": "APPROVED", "Pending": "PENDING", "Rejected": "REJECTED"}

for r in rows:
    email = r["email"]
    first = (r["first_name"] or "").strip()
    last = (r["last_name"] or "").strip()
    full_name = f"{first} {last}".strip() or email.split("@")[0].title()
    uid = r["user_id"]
    roll = r["roll_number"] or f"CS2023{uid}"
    dept = r["department"] or "Computer Science & Engineering"
    db_status = r["verification_status"] or "Pending"
    status = status_map.get(db_status, "PENDING")

    obj, created = StudentVerificationRequest.objects.update_or_create(
        email=email,
        defaults=dict(
            student_id=uuid.uuid4(),
            full_name=full_name,
            roll_number=roll,
            department=dept,
            year_of_study=3,
            status=status,
        ),
    )
    action = "CREATED" if created else "UPDATED"
    print(f"  {action}: {full_name} | {email} | {status}")

print("\nSync complete! Faculty dashboard will now show real students.")
