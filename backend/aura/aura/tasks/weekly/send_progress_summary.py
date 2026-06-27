import frappe
from frappe.utils import now_datetime, add_days


def send_progress_summary():
    profiles = frappe.get_all("Beauty User Profile", filters={"enabled": 1})
    for profile in profiles:
        try:
            doc = frappe.get_doc("Beauty User Profile", profile.name)
            if doc.email:
                frappe.sendmail(
                    recipients=[doc.email],
                    subject="Your Weekly Aura Progress Summary",
                    template="weekly_progress_summary",
                    args={"profile": doc},
                )
        except Exception:
            frappe.log_error(
                message=f"Failed to send progress summary for {profile.name}",
                title="Weekly Task: send_progress_summary",
            )
