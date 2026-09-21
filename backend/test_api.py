import requests, json
r = requests.get(
    'http://127.0.0.1:8000/api/v1/faculty/student-verifications/',
    headers={'Authorization': 'Bearer test'}
)
print("Status:", r.status_code)
try:
    data = r.json()
    items = data if isinstance(data, list) else data.get('results', [])
    for d in items:
        email = d.get('email', '')
        ca = d.get('companies_applied', 'N/A')
        sl = d.get('shortlisted', 'N/A')
        print(f"  {email}: applied={ca}, shortlisted={sl}")
except Exception as e:
    print("Error:", e, r.text[:300])
