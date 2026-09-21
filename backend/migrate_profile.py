import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_backend.settings')

from api.db_helper import get_db

conn = get_db()
cursor = conn.cursor()

cols_to_add = [
    ('program', 'TEXT'),
    ('admission_year', 'INTEGER'),
    ('passout_year', 'INTEGER'),
    ('linkedin', 'TEXT'),
    ('github', 'TEXT'),
    ('bio', 'TEXT'),
]

for col, dtype in cols_to_add:
    try:
        cursor.execute(f'ALTER TABLE student_profiles ADD COLUMN {col} {dtype}')
        print(f'Added column: {col}')
    except Exception as e:
        print(f'Column {col} already exists or error: {e}')

conn.commit()
conn.close()
print('Migration complete.')
