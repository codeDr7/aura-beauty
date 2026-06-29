import frappe
from frappe.utils import now_datetime


def send_progress_summary():
    profiles = frappe.get_all("Beauty User Profile", filters={"enabled": 1})
    for profile in profiles:
        try:
            doc = frappe.get_doc("Beauty User Profile", profile.name)
            email = frappe.db.get_value("User", doc.user, "email")
            if email:
                frappe.sendmail(
                    recipients=[email],
                    subject="Your Weekly Aura Progress Summary",
                    template="progress_summary",
                    args={
                        "full_name": doc.full_name or doc.user,
                        "skin_score": doc.skin_score,
                        "hair_score": doc.hair_score,
                        "consistency_score": doc.routine_consistency_score,
                        "profile": doc,
                    },
                )
        except Exception:
            frappe.log_error(
                message=f"Failed to send progress summary for {profile.name}",
                title="Weekly Task: send_progress_summary",
            )
