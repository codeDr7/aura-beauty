import frappe
from frappe.utils import now_datetime, add_days


def archive_inactive_profiles():
    cutoff = add_days(now_datetime(), -90)
    inactive = frappe.get_all(
        "Beauty User Profile",
        filters=[
            ["modified", "<", cutoff],
            ["enabled", "=", 1],
        ],
    )
    for profile in inactive:
        try:
            doc = frappe.get_doc("Beauty User Profile", profile.name)
            doc.enabled = 0
            doc.save(ignore_permissions=True)
        except Exception:
            frappe.log_error(
                message=f"Failed to archive profile {profile.name}",
                title="Monthly Task: archive_inactive_profiles",
            )
