import frappe
from frappe import _


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


@frappe.whitelist()
def get_routine_templates():
    templates = frappe.get_all(
        "Routine Template",
        filters={"is_active": 1},
        fields=["name", "template_name", "routine_type", "description"],
        order_by="template_name asc",
    )

    for t in templates:
        steps = frappe.get_all(
            "Routine Template Step",
            filters={"parent": t.name},
            fields=["step_number", "step_name", "step_description", "duration_minutes", "product_category"],
            order_by="step_number asc",
        )
        t["steps"] = steps

    return templates


@frappe.whitelist()
def get_user_routines():
    profile = get_current_profile()
    routines = frappe.get_all(
        "User Routine",
        filters={"user": profile},
        fields=["name", "routine_template", "is_active", "start_date", "adherence_rate"],
        order_by="modified desc",
    )

    for r in routines:
        steps = frappe.get_all(
            "User Routine Step",
            filters={"parent": r.name},
            fields=["step_number", "step_name", "product", "is_completed", "completed_time", "notes"],
            order_by="step_number asc",
        )
        r["steps"] = steps
        r["template_details"] = frappe.db.get_value(
            "Routine Template", r["routine_template"],
            ["template_name", "routine_type", "description"], as_dict=True
        )

    return routines


@frappe.whitelist()
def create_user_routine(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    if not data.get("routine_template"):
        frappe.throw(_("Routine template is required"))

    if not frappe.db.exists("Routine Template", data["routine_template"]):
        frappe.throw(_("Routine template not found"))

    template = frappe.get_doc("Routine Template", data["routine_template"])

    doc = frappe.get_doc({
        "doctype": "User Routine",
        "user": profile,
        "routine_template": data["routine_template"],
        "is_active": data.get("is_active", 1),
        "start_date": data.get("start_date", frappe.utils.today()),
    })

    for step in template.steps:
        doc.append("steps", {
            "step_number": step.step_number,
            "step_name": step.step_name,
            "product": None,
            "is_completed": 0,
            "notes": None,
        })

    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return doc.as_dict()


@frappe.whitelist()
def update_routine_progress(routine_id, step_number):
    if not frappe.db.exists("User Routine", routine_id):
        frappe.throw(_("Routine not found"))

    routine = frappe.get_doc("User Routine", routine_id)

    step_found = False
    for step in routine.steps:
        if step.step_number == int(step_number):
            step.is_completed = 1
            step.completed_time = frappe.utils.nowtime()
            step_found = True
            break

    if not step_found:
        frappe.throw(_("Step not found in routine"))

    routine.save(ignore_permissions=True)
    frappe.db.commit()

    return routine.as_dict()


@frappe.whitelist()
def get_today_routine():
    profile = get_current_profile()
    today = frappe.utils.today()
    weekday = frappe.utils.get_weekday(today)

    is_weekend = weekday in ("Saturday", "Sunday")

    active_routines = frappe.get_all(
        "User Routine",
        filters={"user": profile, "is_active": 1},
        fields=["name", "routine_template", "adherence_rate"],
    )

    if not active_routines:
        frappe.throw(_("No active routine found. Create one first."))

    routine = frappe.get_doc("User Routine", active_routines[0].name)
    template = frappe.get_doc("Routine Template", routine.routine_template)

    if template.routine_type == "Weekly" and not is_weekend:
        return {
            "message": _("Weekly routine is scheduled for weekends"),
            "today_routine": None,
            "active_routine": routine.as_dict(),
        }

    data = routine.as_dict()
    data["template_details"] = {
        "template_name": template.template_name,
        "routine_type": template.routine_type,
        "description": template.description,
    }

    return data


@frappe.whitelist()
def start_routine_session(routine_id):
    if not frappe.db.exists("User Routine", routine_id):
        frappe.throw(_("Routine not found"))

    profile = get_current_profile()
    routine = frappe.get_doc("User Routine", routine_id)

    if routine.user != profile:
        frappe.throw(_("You can only start your own routines"))

    steps = frappe.get_all(
        "User Routine Step",
        filters={"parent": routine_id},
        fields=["step_number", "step_name", "product", "is_completed"],
        order_by="step_number asc"
    )

    return {
        "message": _("Routine session started"),
        "routine_id": routine_id,
        "started_at": frappe.utils.now(),
        "steps": steps,
    }


@frappe.whitelist()
def complete_step(routine_id, step_number, duration_seconds):
    if not frappe.db.exists("User Routine", routine_id):
        frappe.throw(_("Routine not found"))

    profile = get_current_profile()
    routine = frappe.get_doc("User Routine", routine_id)

    if routine.user != profile:
        frappe.throw(_("You can only update your own routines"))

    step_found = False
    for step in routine.steps:
        if step.step_number == int(step_number):
            step.is_completed = 1
            step.completed_time = frappe.utils.nowtime()
            step.duration_seconds = int(duration_seconds)
            step_found = True
            break

    if not step_found:
        frappe.throw(_("Step not found in routine"))

    routine.save(ignore_permissions=True)
    frappe.db.commit()

    completed_steps = sum(1 for s in routine.steps if s.is_completed)
    total_steps = len(routine.steps)

    return {
        "message": _("Step {0} completed").format(step_number),
        "routine_id": routine_id,
        "step_number": step_number,
        "duration_seconds": int(duration_seconds),
        "completed_steps": completed_steps,
        "total_steps": total_steps,
        "progress_pct": round((completed_steps / total_steps) * 100, 1) if total_steps else 0,
    }
