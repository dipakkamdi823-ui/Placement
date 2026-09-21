from api.db_helper import get_db

conn = get_db()
cursor = conn.cursor()

def test_query(name, q):
    try:
        cursor.execute(q)
        res = cursor.fetchone()
        print(f"{name}: SUCCESS -> {res}")
    except Exception as e:
        print(f"{name}: FAILED -> {e}")

test_query("1. Students", "SELECT COUNT(*) as cnt FROM users WHERE role = 'Student'")
test_query("2. Faculty", "SELECT COUNT(*) as cnt FROM faculty")
test_query("3. Opportunities", "SELECT COUNT(*) as cnt FROM opportunities")
test_query("4. Applications", "SELECT COUNT(*) as cnt FROM applications")
test_query("5. Offered Apps", "SELECT COUNT(*) as cnt FROM applications WHERE UPPER(status) IN ('SELECTED', 'OFFERED', 'APPROVED', 'PLACED')")
test_query("6. Pending Verif", "SELECT COUNT(*) as cnt FROM student_verification_requests WHERE UPPER(status) = 'PENDING'")
test_query("7. Pending Orgs", "SELECT COUNT(*) as cnt FROM organizations WHERE UPPER(verification_status) = 'PENDING'")
test_query("8. Pending Opps", "SELECT COUNT(*) as cnt FROM opportunities WHERE UPPER(status) LIKE '%PENDING%'")
test_query("9. Verified Orgs", "SELECT COUNT(*) as cnt FROM organizations WHERE UPPER(verification_status) = 'VERIFIED'")

conn.close()
