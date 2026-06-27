import frappe
from frappe.utils import now_datetime, add_days


def regenerate_recommendations():
    profiles = frappe.get_all("Beauty User Profile", filters={"enabled": 1})
    for profile in profiles:
        try:
            doc = frappe.get_doc("Beauty User Profile", profile.name)
            if doc.latest_skin_assessment:
                assessment = frappe.get_doc("Skin Assessment", doc.latest_skin_assessment)
                frappe.get_attr("aura.api.recommendations.generate_recommendations")(
                    doc.name, assessment
                )
        except Exception:
            frappe.log_error(
                message=f"Failed to regenerate recommendations for {profile.name}",
                title="Daily Task: regenerate_recommendations",
            )
