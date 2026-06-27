import frappe
from frappe import _


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


@frappe.whitelist()
def get_plans():
    plans = frappe.get_all(
        "Subscription Plan",
        filters={"is_active": 1},
        fields=["name", "plan_name", "plan_type", "price_monthly", "price_yearly", "description", "sort_order"],
        order_by="sort_order asc",
    )

    for plan in plans:
        features = frappe.get_all(
            "Plan Feature",
            filters={"parent": plan.name},
            fields=["feature_name", "is_included"],
        )
        plan["features"] = features

    return plans


@frappe.whitelist()
def get_current_subscription():
    profile = get_current_profile()

    subs = frappe.get_all(
        "User Subscription",
        filters={"user": profile, "is_active": 1},
        fields=["name", "plan", "start_date", "end_date", "auto_renew", "payment_method", "subscription_type"],
        order_by="start_date desc",
        limit=1,
    )

    if not subs:
        profile_doc = frappe.get_doc("Beauty User Profile", profile)
        return {
            "subscription_status": profile_doc.subscription_status,
            "plan": None,
        }

    sub = subs[0]
    plan_details = frappe.db.get_value(
        "Subscription Plan", sub.plan,
        ["plan_name", "plan_type", "price_monthly", "price_yearly"], as_dict=True
    )
    sub["plan_details"] = plan_details

    return sub


@frappe.whitelist()
def upgrade_plan(plan_id, type):
    if not frappe.db.exists("Subscription Plan", plan_id):
        frappe.throw(_("Plan not found"))

    if type not in ("Monthly", "Yearly"):
        frappe.throw(_("Invalid subscription type"))

    profile = get_current_profile()
    plan = frappe.get_doc("Subscription Plan", plan_id)

    existing = frappe.get_all(
        "User Subscription",
        filters={"user": profile, "is_active": 1},
    )
    for sub_name in existing:
        frappe.db.set_value("User Subscription", sub_name, "is_active", 0)

    doc = frappe.get_doc({
        "doctype": "User Subscription",
        "user": profile,
        "plan": plan_id,
        "start_date": frappe.utils.today(),
        "is_active": 1,
        "auto_renew": 1,
        "subscription_type": type,
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return {
        "message": _(f"Successfully upgraded to {plan.plan_name}"),
        "subscription": doc.as_dict(),
    }


@frappe.whitelist()
def cancel_subscription():
    profile = get_current_profile()

    subs = frappe.get_all(
        "User Subscription",
        filters={"user": profile, "is_active": 1},
    )

    if not subs:
        frappe.throw(_("No active subscription found"))

    for sub_name in subs:
        frappe.db.set_value("User Subscription", sub_name, "is_active", 0)
        frappe.db.set_value("User Subscription", sub_name, "auto_renew", 0)

    frappe.db.set_value("Beauty User Profile", profile, "subscription_status", "Free")
    frappe.db.commit()

    return {"message": _("Subscription cancelled successfully")}
