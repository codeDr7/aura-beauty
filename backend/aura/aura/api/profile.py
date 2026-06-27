import frappe
from frappe import _


def get_current_profile():
    user_email = frappe.session.user
    if user_email == "Guest":
        frappe.throw(_("Please login first"), frappe.PermissionError)

    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return frappe.get_doc("Beauty User Profile", profile_name)


@frappe.whitelist()
def get_profile():
    profile = get_current_profile()
    return profile.as_dict()


@frappe.whitelist()
def create_profile(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    user_email = frappe.session.user
    if frappe.db.exists("Beauty User Profile", {"user": user_email}):
        frappe.throw(_("Profile already exists for this user"))

    profile = frappe.get_doc({
        "doctype": "Beauty User Profile",
        "user": user_email,
        "full_name": data.get("full_name", frappe.db.get_value("User", user_email, "full_name")),
        "age_range": data.get("age_range"),
        "gender": data.get("gender"),
        "country": data.get("country"),
        "climate": data.get("climate"),
        "skin_type": data.get("skin_type"),
        "skin_sensitivity": data.get("skin_sensitivity"),
        "hair_type": data.get("hair_type"),
        "created_date": frappe.utils.today(),
    })
    profile.insert(ignore_permissions=True)
    frappe.db.commit()

    return profile.as_dict()


@frappe.whitelist()
def update_profile(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    allowed_fields = [
        "full_name", "age_range", "gender", "country", "climate",
        "skin_type", "skin_sensitivity", "hair_type"
    ]
    for field in allowed_fields:
        if field in data:
            setattr(profile, field, data[field])

    profile.save(ignore_permissions=True)
    frappe.db.commit()

    return profile.as_dict()


@frappe.whitelist()
def get_skin_score():
    profile = get_current_profile()
    history = frappe.get_all(
        "Skin Assessment",
        filters={"user": profile.name},
        fields=["assessment_date", "overall_score"],
        order_by="assessment_date desc",
        limit=10,
    )
    return {
        "current_score": profile.skin_score,
        "history": history,
    }


@frappe.whitelist()
def get_hair_score():
    profile = get_current_profile()
    history = frappe.get_all(
        "Hair Assessment",
        filters={"user": profile.name},
        fields=["assessment_date", "overall_score"],
        order_by="assessment_date desc",
        limit=10,
    )
    return {
        "current_score": profile.hair_score,
        "history": history,
    }


def on_profile_update(doc, method):
    pass
