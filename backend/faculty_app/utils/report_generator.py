"""
SAIOTAF - Faculty & Moderator Module
Report generation for accreditation / department summaries (FR-FAC-07).

Two export formats are supported:
  - xlsx via openpyxl
  - pdf  via reportlab

This module returns raw bytes + content-type + filename so the calling view
stays a thin HTTP adapter (testable independent of Django's response cycle).
"""

import io
from datetime import datetime


def _fetch_report_dataset(department: str | None, term: str | None, session: str | None = None) -> list[dict]:
    """
    Queries live placement & applications database to compile accredited report entries.
    """
    try:
        import re
        from api.db_helper import get_db
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT a.status, a.applied_date, a.last_updated,
                   COALESCE(sp.department, '') AS student_department,
                   sp.graduation_year, sp.passout_year
            FROM applications a
            LEFT JOIN student_profiles sp ON sp.student_id = a.student_id
        """)
        all_rows = cursor.fetchall()
        conn.close()

        session_years = [int(y) for y in re.findall(r'\b\d{4}\b', session)] if session and session.strip().lower() not in ['all', 'all sessions'] else []
        s_start = min(session_years) if session_years else None
        s_end = max(session_years) if session_years else None

        filtered = []
        for r in all_rows:
            d = dict(r)

            # 1. Department filter
            if department and department.strip().lower() != "all departments":
                dept_lower = department.strip().lower()
                dept_first = dept_lower.split()[0] if dept_lower else ""
                s_dept = (d.get("student_department") or "").strip().lower()
                if not s_dept:
                    continue
                s_first = s_dept.split()[0] if s_dept else ""
                if not (dept_lower in s_dept or
                        s_dept in dept_lower or
                        (dept_first and s_first and dept_first == s_first and len(dept_first) > 3)):
                    continue

            # 2. Session filter
            if s_start is not None and s_end is not None:
                app_date = str(d.get("applied_date") or d.get("last_updated") or "")
                d_years = [int(y) for y in re.findall(r'\b\d{4}\b', app_date)]
                app_year = d_years[0] if d_years else None
                grad_year = d.get("passout_year") or d.get("graduation_year")

                matched_session = False
                if app_year and (s_start <= app_year <= s_end):
                    matched_session = True
                elif grad_year and (s_start <= grad_year <= s_end):
                    matched_session = True
                if not matched_session:
                    continue

            filtered.append(r)
        rows = filtered

        statuses = [dict(r).get("status", "").strip() for r in rows]
    except Exception:
        statuses = []

    total_apps = len(statuses)
    under_review = sum(1 for s in statuses if s.lower() in ["under review", "under_review"])
    shortlisted = sum(1 for s in statuses if s.lower() in ["shortlisted"])
    interview = sum(1 for s in statuses if s.lower() in ["interview"])
    offered = sum(1 for s in statuses if s.lower() in ["selected", "offered", "accepted"])
    shortlisted_stage = shortlisted + interview
    rate = f"{((offered / total_apps) * 100):.1f}%" if total_apps > 0 else "0.0%"

    return [
        {
            "session": session or "2025-2026",
            "term": term or "Even Semester (Term II)",
            "department": department or "All Departments",
            "total_applications": total_apps,
            "under_review": under_review,
            "shortlisted": shortlisted_stage,
            "interview_stage": interview,
            "offered_placed": offered,
            "placement_rate": rate
        }
    ]


def generate_placement_report(fmt: str, department: str | None, term: str | None, session: str | None = None):
    dataset = _fetch_report_dataset(department, term, session)
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")

    if fmt == "xlsx":
        return _generate_xlsx(dataset, timestamp)
    return _generate_pdf(dataset, timestamp)


def _generate_xlsx(dataset, timestamp):
    from openpyxl import Workbook

    wb = Workbook()
    ws = wb.active
    ws.title = "Placement Report"

    if dataset:
        headers = list(dataset[0].keys())
        ws.append(headers)
        for row in dataset:
            ws.append([row[h] for h in headers])

    buffer = io.BytesIO()
    wb.save(buffer)
    buffer.seek(0)

    filename = f"placement_report_{timestamp}.xlsx"
    content_type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    return buffer.getvalue(), content_type, filename


def _generate_pdf(dataset, timestamp):
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.lib import colors

    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter)
    styles = getSampleStyleSheet()
    story = [Paragraph("SAIOTAF Placement Report", styles["Title"]), Spacer(1, 16)]

    if dataset:
        headers = list(dataset[0].keys())
        table_data = [headers] + [[str(row[h]) for h in headers] for row in dataset]
        table = Table(table_data)
        table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#2c3e50")),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
            ("FONTSIZE", (0, 0), (-1, -1), 9),
        ]))
        story.append(table)

    doc.build(story)
    buffer.seek(0)

    filename = f"placement_report_{timestamp}.pdf"
    return buffer.getvalue(), "application/pdf", filename
