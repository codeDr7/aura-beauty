import frappe
from frappe import _


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


@frappe.whitelist()
def submit_skin_assessment(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    doc = frappe.get_doc({
        "doctype": "Skin Assessment",
        "user": profile,
        "assessment_date": data.get("assessment_date", frappe.utils.today()),
        "skin_type": data.get("skin_type"),
        "sensitivity": data.get("sensitivity"),
        "acne_presence": data.get("acne_presence"),
        "pigmentation": data.get("pigmentation"),
        "dark_spots": data.get("dark_spots"),
        "wrinkles": data.get("wrinkles"),
        "fine_lines": data.get("fine_lines"),
        "pore_visibility": data.get("pore_visibility"),
        "redness": data.get("redness"),
        "hydration_level": data.get("hydration_level"),
    })

    if data.get("main_goals"):
        for goal in data["main_goals"]:
            doc.append("main_goals", {"goal": goal.get("goal", goal)})

    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return doc.as_dict()


@frappe.whitelist()
def submit_hair_assessment(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    doc = frappe.get_doc({
        "doctype": "Hair Assessment",
        "user": profile,
        "assessment_date": data.get("assessment_date", frappe.utils.today()),
        "hair_type": data.get("hair_type"),
        "hair_texture": data.get("hair_texture"),
        "hair_thickness": data.get("hair_thickness"),
        "hair_density": data.get("hair_density"),
        "scalp_condition": data.get("scalp_condition"),
        "hair_loss": data.get("hair_loss"),
        "dandruff": data.get("dandruff"),
        "dryness": data.get("dryness"),
        "chemical_treatments": data.get("chemical_treatments"),
        "hair_damage": data.get("hair_damage"),
    })

    if data.get("main_goals"):
        for goal in data["main_goals"]:
            doc.append("main_goals", {"goal": goal.get("goal", goal)})

    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return doc.as_dict()


@frappe.whitelist()
def submit_lifestyle_assessment(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    doc = frappe.get_doc({
        "doctype": "Lifestyle Assessment",
        "user": profile,
        "assessment_date": data.get("assessment_date", frappe.utils.today()),
        "sleep_quality": data.get("sleep_quality"),
        "water_intake": data.get("water_intake"),
        "activity_level": data.get("activity_level"),
        "stress_level": data.get("stress_level"),
        "sun_exposure": data.get("sun_exposure"),
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return doc.as_dict()


@frappe.whitelist()
def get_latest_skin_assessment():
    profile = get_current_profile()
    assessments = frappe.get_all(
        "Skin Assessment",
        filters={"user": profile},
        fields=["*"],
        order_by="assessment_date desc",
        limit=1,
    )
    if not assessments:
        frappe.throw(_("No skin assessment found"))
    return assessments[0]


@frappe.whitelist()
def get_latest_hair_assessment():
    profile = get_current_profile()
    assessments = frappe.get_all(
        "Hair Assessment",
        filters={"user": profile},
        fields=["*"],
        order_by="assessment_date desc",
        limit=1,
    )
    if not assessments:
        frappe.throw(_("No hair assessment found"))
    return assessments[0]


@frappe.whitelist()
def get_assessment_history(doctype, limit=10):
    profile = get_current_profile()
    valid_doctypes = ["Skin Assessment", "Hair Assessment", "Lifestyle Assessment"]
    if doctype not in valid_doctypes:
        frappe.throw(_("Invalid assessment type"))

    return frappe.get_all(
        doctype,
        filters={"user": profile},
        fields=["name", "assessment_date", "overall_score"],
        order_by="assessment_date desc",
        limit=limit,
    )


@frappe.whitelist()
def submit_skin_analysis(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    doc = frappe.get_doc({
        "doctype": "Skin Analysis Result",
        "user": profile,
        "analysis_date": data.get("analysis_date", frappe.utils.now()),
        "image": data.get("image"),
        "hydration_score": data.get("hydration_score"),
        "pore_visibility": data.get("pore_visibility"),
        "texture_score": data.get("texture_score"),
        "pigmentation_score": data.get("pigmentation_score"),
        "redness_score": data.get("redness_score"),
        "overall_score": data.get("overall_score"),
        "findings": data.get("findings"),
        "recommendations": data.get("recommendations"),
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    overall = data.get("overall_score")
    if overall is not None:
        profile_doc = frappe.get_doc("Beauty User Profile", profile)
        profile_doc.skin_score = overall
        profile_doc.save(ignore_permissions=True)

    return doc.as_dict()


@frappe.whitelist()
def get_analysis_history(limit=10):
    profile = get_current_profile()

    results = frappe.get_all(
        "Skin Analysis Result",
        filters={"user": profile},
        fields=["name", "analysis_date", "image", "hydration_score", "pore_visibility", "texture_score", "pigmentation_score", "redness_score", "overall_score", "findings", "recommendations"],
        order_by="analysis_date desc",
        limit=limit,
    )

    return results
