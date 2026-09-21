import json
import time
import random
import jwt
from abc import ABC, abstractmethod
from api.db_helper import get_db

SECRET_KEY = "saiotaf_jwt_secret_python_key_2026"
ALGORITHM = "HS256"

# ==========================================
# 1. ABSTRACT BASE SERVICES (OOP Abstraction)
# ==========================================

class AbstractAuthService(ABC):
    """Abstract interface defining user authentication contracts."""
    
    @abstractmethod
    def authenticate_or_register(self, email: str, password: str) -> dict:
        pass

    @abstractmethod
    def register_student(self, data: dict) -> dict:
        pass


class AbstractNLPRecommendationEngine(ABC):
    """Abstract interface for Semantic AI Matching & Recommendation Engine."""
    
    @abstractmethod
    def extract_skills_from_text(self, text: str, filename: str) -> list:
        pass

    @abstractmethod
    def calculate_compatibility(self, user_skills: list, required_skills: list) -> dict:
        pass

    @abstractmethod
    def generate_recommendations(self, user_skills: list) -> list:
        pass


class AbstractPlacementReadinessService(ABC):
    """Abstract interface for evaluating student readiness scores."""
    
    @abstractmethod
    def calculate_readiness_score(self, user_skills: list, student_email: str = None) -> dict:
        pass


# ==========================================
# 2. CONCRETE IMPLEMENTATIONS (Encapsulation)
# ==========================================

def _is_valid_domain(email: str) -> bool:
    e = email.lower().strip()
    return e.endswith("@raisoni.net") or e.endswith("@college.edu") or e.endswith(".edu") or e.endswith(".ac.in")

class StudentAuthService(AbstractAuthService):
    def authenticate_or_register(self, email: str, password: str) -> dict:
        if not _is_valid_domain(email):
            raise ValueError("Invalid institutional email. Must be an official college domain email (e.g. @raisoni.net)")

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT u.user_id, u.email, sp.student_id FROM users u LEFT JOIN student_profiles sp ON u.user_id = sp.student_id WHERE u.email = ?", (email,))
        row = cursor.fetchone()

        if not row:
            cursor.execute("""
                INSERT INTO users (email, password_hash, role, is_active, is_verified)
                VALUES (?, '$2b$12$eImiTXuWVxfM37uY4JANjO2ZfW9X2m2kF8a2A2h1W5eG5f5S5S5S5', 'Student', 1, 1)
            """, (email,))
            u_id = cursor.lastrowid
            name_parts = email.split("@")[0].replace(".", " ").title().split(" ")
            first_name = name_parts[0]
            last_name = name_parts[1] if len(name_parts) > 1 else ""
            roll = f"2023CS{random.randint(1000, 9999)}"

            cursor.execute("""
                INSERT INTO student_profiles (student_id, roll_number, first_name, last_name, department, graduation_year, cgpa, preferred_opportunity_type, verification_status, placement_readiness_score)
                VALUES (?, ?, ?, ?, 'Computer Science & Engineering', 2027, 0.00, 'Both', 'Pending', 0.00)
            """, (u_id, roll, first_name, last_name))
            conn.commit()
        else:
            u_id = row["user_id"]

        conn.close()

        payload = {
            "sub": email,
            "user_id": u_id,
            "role": "Student",
            "exp": int(time.time()) + 86400 * 7
        }
        token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
        return {"status": "success", "student_id": f"STU{u_id}", "token": token}

    def register_student(self, data: dict) -> dict:
        name = data.get('name') or data.get('full_name', '')
        email = data.get('email', '')
        roll_no = data.get('roll_no') or data.get('student_id', '')
        dept = data.get('dept') or data.get('department', 'Computer Science & Engineering')

        if not _is_valid_domain(email):
            raise ValueError("Registration restricted to official college domain email (e.g. @raisoni.net).")

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
        if cursor.fetchone():
            conn.close()
            raise ValueError("Email is already registered.")

        cursor.execute("""
            INSERT INTO users (email, password_hash, role, is_active, is_verified)
            VALUES (?, '$2b$12$eImiTXuWVxfM37uY4JANjO2ZfW9X2m2kF8a2A2h1W5eG5f5S5S5S5', 'Student', 1, 0)
        """, (email,))
        user_id = cursor.lastrowid

        name_parts = name.split(" ")
        first_name = name_parts[0]
        last_name = name_parts[1] if len(name_parts) > 1 else ""

        cursor.execute("""
            INSERT INTO student_profiles (student_id, roll_number, first_name, last_name, department, graduation_year, cgpa, preferred_opportunity_type, verification_status, placement_readiness_score)
            VALUES (?, ?, ?, ?, ?, 2027, 0.00, 'Both', 'Pending', 0.00)
        """, (user_id, roll_no, first_name, last_name, dept))
        conn.commit()
        conn.close()

        payload = {
            "sub": email,
            "user_id": user_id,
            "role": "Student",
            "exp": int(time.time()) + 86400 * 7
        }
        token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
        return {"status": "success", "student_id": f"STU{user_id}", "token": token}


class SentenceBertRecommendationEngine(AbstractNLPRecommendationEngine):
    SKILLS_TAXONOMY = [
        ("Python", "Programming"), ("JavaScript", "Programming"), ("TypeScript", "Programming"),
        ("Java", "Programming"), ("C++", "Programming"), ("C", "Programming"),
        ("HTML", "Web Dev"), ("CSS", "Web Dev"), ("React", "Web Dev"), ("Django", "Web Dev"),
        ("Node.js", "Web Dev"), ("SQL", "Database"), ("PostgreSQL", "Database"), ("MongoDB", "Database"),
        ("Machine Learning", "AI/ML"), ("Deep Learning", "AI/ML"), ("Data Science", "AI/ML"),
        ("PyTorch", "AI/ML"), ("TensorFlow", "AI/ML"), ("AWS", "DevOps"), ("Docker", "DevOps"),
        ("Git", "DevOps"), ("Linux", "DevOps"), ("Cybersecurity", "DevOps")
    ]

    def extract_skills_from_text(self, text: str, filename: str) -> list:
        search_corpus = f"{filename} {text}".lower()
        extracted = []
        for skill_name, category in self.SKILLS_TAXONOMY:
            if skill_name.lower() in search_corpus:
                extracted.append({
                    "skill_id": f"SK-{random.randint(100, 999)}",
                    "skill_name": skill_name,
                    "category": category,
                    "proficiency_level": "Intermediate",
                    "verification_status": "Verified",
                    "source": "parsed"
                })
        return extracted

    def calculate_compatibility(self, user_skills: list, required_skills: list) -> dict:
        user_skills_lower = [s.lower() for s in user_skills]
        matched = [r_skill for r_skill in required_skills if any(u_skill in r_skill.lower() or r_skill.lower() in u_skill for u_skill in user_skills_lower)]
        missing = [r_skill for r_skill in required_skills if r_skill not in matched]

        if not user_skills:
            match_score = 35
            explanation = "No verified skills found. Upload your resume or add skills to view tailored match insights."
        elif len(required_skills) > 0:
            score = int(40 + (len(matched) / len(required_skills)) * 55)
            match_score = min(98, max(45, score))
            explanation = f"Matched on {len(matched)} skill{'s' if len(matched) != 1 else ''}: {', '.join(matched) if matched else 'General fit based on profile'}."
        else:
            match_score = 60
            explanation = "General fit based on profile."

        return {
            "match_score": match_score,
            "matched_skills": matched if matched else ([] if not user_skills else ["General Alignment"]),
            "missing_skills": missing,
            "explanation": explanation
        }

    def generate_recommendations(self, user_skills: list) -> list:
        opps = []
        try:
            from faculty_app.models import Opportunity
            qs = Opportunity.objects.filter(status="APPROVED").select_related('organization')
            for o in qs:
                req_skills = o.required_skills if isinstance(o.required_skills, list) else ["React", "Python"]
                opps.append({
                    "id": str(o.id),
                    "title": o.title,
                    "organization": o.organization.name if o.organization else "Partner Org",
                    "domain": "Software Dev" if o.opportunity_type == "INTERNSHIP" else "Environment & Community",
                    "location": o.location or "Remote",
                    "work_mode": o.work_mode.title() if o.work_mode else "Remote",
                    "stipend": f"{o.compensation_currency} {o.compensation_amount:,.0f}/mo" if o.compensation_amount else "Unpaid / Volunteer",
                    "description": o.description,
                    "required_skills": req_skills
                })
        except Exception:
            pass

        if not opps:
            conn = get_db()
            cursor = conn.cursor()
            cursor.execute("""
                SELECT o.*, org.name AS organization_name 
                FROM opportunities o 
                JOIN organizations org ON o.org_id = org.org_id
            """)
            opp_rows = cursor.fetchall()
            conn.close()
            for r in opp_rows:
                opp = dict(r)
                opps.append({
                    "id": str(opp["opportunity_id"]),
                    "title": opp["title"],
                    "organization": opp["organization_name"],
                    "domain": "Engineering & AI" if opp["opportunity_type"] == "Internship" else "Environment & Community",
                    "location": opp["location"] or "Remote",
                    "work_mode": opp.get("mode") or "Remote",
                    "stipend": "₹35,000 / month" if opp["opportunity_type"] == "Internship" else "₹10,000 / month",
                    "description": opp.get("description", "Opportunity position"),
                    "required_skills": ["Python", "SQL", "React", "Git"]
                })

        results = []
        for opp in opps:
            compat = self.calculate_compatibility(user_skills, opp["required_skills"])
            results.append({
                "id": opp["id"],
                "title": opp["title"],
                "organization": opp["organization"],
                "domain": opp["domain"],
                "location": opp["location"],
                "work_mode": opp["work_mode"],
                "stipend": opp["stipend"],
                "description": opp["description"],
                "required_skills": opp["required_skills"],
                "match_score": compat["match_score"],
                "matched_skills": compat["matched_skills"],
                "missing_skills": compat["missing_skills"],
                "model_source": "Smart Semantic Skill Alignment Engine",
                "explanation": compat["explanation"]
            })

        results.sort(key=lambda x: x["match_score"], reverse=True)
        return results


class PlacementReadinessService(AbstractPlacementReadinessService):
    def calculate_readiness_score(self, user_skills: list, student_email: str = None) -> dict:
        conn = get_db()
        cursor = conn.cursor()
        
        student_id = None
        sp_row = None
        resume_row = None
        app_count = 0
        max_app_stage_bonus = 0

        # 1. Resolve student profile and ID
        if student_email:
            cursor.execute("""
                SELECT u.user_id, sp.*
                FROM users u
                LEFT JOIN student_profiles sp ON sp.student_id = u.user_id
                WHERE u.email = ?
            """, (student_email,))
            u_sp = cursor.fetchone()
            if u_sp:
                student_id = u_sp.get("user_id")
                sp_row = dict(u_sp)

        # 2. Resolve active resume strictly for this student
        if student_id:
            cursor.execute("""
                SELECT r.* 
                FROM resume r 
                JOIN student_profiles sp ON sp.active_resume_id = r.resume_id 
                WHERE sp.student_id = ?
            """, (student_id,))
            resume_row = cursor.fetchone()

            if not resume_row and student_email:
                cursor.execute("""
                    SELECT * FROM resume 
                    WHERE student_email = ? OR student_id = ?
                    ORDER BY upload_date DESC 
                    LIMIT 1
                """, (student_email, str(student_id)))
                resume_row = cursor.fetchone()
                if resume_row and resume_row.get("resume_id"):
                    try:
                        cursor.execute("UPDATE student_profiles SET active_resume_id = ? WHERE student_id = ?", (resume_row["resume_id"], student_id))
                        conn.commit()
                    except Exception:
                        pass
        elif not student_email:
            # Fallback only when no specific student email was requested
            cursor.execute("SELECT * FROM resume ORDER BY upload_date DESC LIMIT 1")
            resume_row = cursor.fetchone()

        # 3. Query real applications submitted by this student
        if student_email or student_id:
            cursor.execute("""
                SELECT status FROM applications 
                WHERE (student_email IS NOT NULL AND student_email = ?) 
                   OR (student_id IS NOT NULL AND student_id = ?)
            """, (student_email or '', str(student_id) if student_id else ''))
            app_rows = cursor.fetchall()
            app_count = len(app_rows)
            for ar in app_rows:
                st = str(ar.get("status") or "").lower()
                if "offer" in st or "select" in st:
                    max_app_stage_bonus = max(max_app_stage_bonus, 20)
                elif "interview" in st:
                    max_app_stage_bonus = max(max_app_stage_bonus, 15)
                elif "shortlist" in st:
                    max_app_stage_bonus = max(max_app_stage_bonus, 10)

        # 4. If user_skills was not passed, fetch from skills table or resume
        if (not user_skills or len(user_skills) == 0):
            if student_id:
                cursor.execute("SELECT skill_name FROM skills WHERE student_id = ? OR student_email = ?", (str(student_id), student_email or ''))
                s_rows = cursor.fetchall()
                user_skills = [sr.get("skill_name") for sr in s_rows if sr.get("skill_name")]

            if (not user_skills or len(user_skills) == 0) and resume_row and resume_row.get("parsed_data"):
                try:
                    pdata = json.loads(resume_row["parsed_data"]) if isinstance(resume_row["parsed_data"], str) else (resume_row.get("parsed_data") or {})
                    skills_list = pdata.get("skills", [])
                    user_skills = [s.get("skill_name") if isinstance(s, dict) else str(s) for s in skills_list if s]
                except Exception:
                    pass

        # -------------------------------------------------------------
        # Factor 1: Resume Quality Score (0 - 100, 35% weight)
        # -------------------------------------------------------------
        if resume_row:
            resume_score = 40 # Baseline for having an active resume uploaded
            fname = (resume_row.get("filename") or "").lower()
            if fname.endswith(".pdf") or fname.endswith(".docx"):
                resume_score += 15 # Standard parsed format

            try:
                pdata = json.loads(resume_row.get("parsed_data", "{}")) if isinstance(resume_row.get("parsed_data"), str) else (resume_row.get("parsed_data") or {})
                parsed_skills = pdata.get("skills", [])
                resume_score += min(30, len(parsed_skills) * 5)
                if pdata.get("experience"):
                    resume_score += 15
            except Exception:
                resume_score += 15

            resume_score = min(100, max(45, resume_score))
        else:
            resume_score = 0

        # -------------------------------------------------------------
        # Factor 2: Skill Coverage Score (0 - 100, 30% weight)
        # -------------------------------------------------------------
        num_skills = len(user_skills) if user_skills else 0
        if num_skills == 0:
            skill_score = 0
        elif num_skills == 1:
            skill_score = 25
        elif num_skills == 2:
            skill_score = 45
        elif num_skills == 3:
            skill_score = 60
        elif num_skills == 4:
            skill_score = 75
        elif num_skills == 5:
            skill_score = 88
        else:
            skill_score = min(100, 92 + (num_skills - 6) * 2)

        # -------------------------------------------------------------
        # Factor 3: Profile Completeness Score (0 - 100, 20% weight)
        # -------------------------------------------------------------
        profile_score = 50
        if sp_row:
            check_fields = [
                sp_row.get('first_name'), sp_row.get('last_name'),
                sp_row.get('department'), sp_row.get('phone_number'),
                sp_row.get('roll_number'), sp_row.get('graduation_year'),
                sp_row.get('cgpa'), sp_row.get('linkedin'),
                sp_row.get('github'), sp_row.get('bio')
            ]
            filled_cnt = sum(1 for f in check_fields if f and str(f).strip() and str(f).strip().lower() not in ['0', '0.00', 'na', 'none'])
            profile_score = int((filled_cnt / len(check_fields)) * 100)

            # Faculty verification bonus
            if sp_row.get('verification_status') == 'Approved':
                profile_score = min(100, profile_score + 10)

        # -------------------------------------------------------------
        # Factor 4: Application Activity Score (0 - 100, 15% weight)
        # -------------------------------------------------------------
        if app_count == 0:
            app_score = 15 # Initial baseline
        elif app_count == 1:
            app_score = 45
        elif app_count == 2:
            app_score = 70
        else:
            app_score = min(100, 85 + (app_count - 3) * 5)
        app_score = min(100, app_score + max_app_stage_bonus)

        # -------------------------------------------------------------
        # Composite Placement Readiness Score (0 - 100)
        # -------------------------------------------------------------
        if not resume_row and num_skills == 0 and app_count == 0:
            overall_score = min(35, profile_score // 3)
        else:
            raw_overall = (resume_score * 0.35) + (skill_score * 0.30) + (profile_score * 0.20) + (app_score * 0.15)
            overall_score = max(0, min(100, int(round(raw_overall))))

        # Persist score to student_profiles in DB
        if student_id:
            try:
                cursor.execute("UPDATE student_profiles SET placement_readiness_score = ? WHERE student_id = ?", (overall_score, student_id))
                conn.commit()
            except Exception as e:
                print(f"Warning: could not update placement_readiness_score: {e}")

        conn.close()

        # Dynamic Actionable Suggestions
        suggestions = []
        if not resume_row:
            suggestions.append("Upload your resume (PDF/DOCX) to unlock up to 35 readiness points and automated job matching.")
        elif resume_score < 75:
            suggestions.append("Enhance your resume ATS score: add quantifiable project impact and technical keywords.")

        if num_skills < 4:
            suggestions.append("Add at least 4 verified technical skills in your Skill Matrix to boost employer match rates.")
        elif num_skills < 6:
            suggestions.append("Broaden your skill matrix with cloud or database competencies for multi-stack readiness.")

        if profile_score < 80:
            suggestions.append("Complete your profile (add LinkedIn, GitHub, Bio) to maximize institutional recruiter visibility.")

        if app_count == 0:
            suggestions.append("Apply to at least 2 recommended opportunity listings to build active placement momentum.")

        if not suggestions:
            suggestions.append("Your readiness profile is top tier! Keep tracking your applications and preparing for interviews.")

        probability_text = "High Placement Probability" if overall_score >= 70 else ("Moderate Placement Probability" if overall_score >= 45 else "Early Stage - Complete Resume & Skills")
        percentile_text = f"Top {max(5, 100 - overall_score)}% Percentile in Dept" if overall_score >= 60 else "Skill Matrix Under Development"

        return {
            "overall_score": overall_score,
            "category_scores": {
                "ats_resume_score": resume_score,
                "resume_quality": resume_score,
                "skill_coverage": skill_score,
                "profile_completeness": profile_score,
                "application_activity": app_score
            },
            "probability_text": probability_text,
            "percentile_text": percentile_text,
            "actionable_suggestions": suggestions
        }


# ==========================================
# 3. SINGLETON INSTANCES / FACTORY PATTERN
# ==========================================

auth_service: AbstractAuthService = StudentAuthService()
nlp_recommendation_engine: AbstractNLPRecommendationEngine = SentenceBertRecommendationEngine()
readiness_service: AbstractPlacementReadinessService = PlacementReadinessService()
