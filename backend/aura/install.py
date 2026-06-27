import frappe


def after_install():
    _create_default_concern_tags()
    _create_default_routine_templates()
    _create_default_subscription_plans()
    _create_default_community_groups()
    frappe.db.commit()


def _create_default_concern_tags():
    if frappe.db.exists("Concern Tag", {"is_active": 1}):
        return
    defaults = [
        "Acne & Breakouts", "Aging & Fine Lines", "Dryness & Dehydration",
        "Dark Circles", "Hyperpigmentation", "Dullness", "Redness & Sensitivity",
        "Large Pores", "Oiliness", "Texture Issues",
    ]
    for name in defaults:
        ct = frappe.get_doc({"doctype": "Concern Tag", "concern_name": name, "is_active": 1})
        ct.insert(ignore_permissions=True)


def _create_default_routine_templates():
    if frappe.db.exists("Routine Template", {"is_active": 1}):
        return
    templates = [
        {"name": "Morning Essentials", "routine_type": "Morning", "is_active": 1, "steps": [
            {"step_order": 1, "step_type": "Cleanser", "description": "Gentle foaming cleanser"},
            {"step_order": 2, "step_type": "Toner", "description": "Hydrating toner"},
            {"step_order": 3, "step_type": "Serum", "description": "Vitamin C serum"},
            {"step_order": 4, "step_type": "Moisturizer", "description": "Lightweight moisturizer"},
            {"step_order": 5, "step_type": "Sunscreen", "description": "SPF 50+ sunscreen"},
        ]},
        {"name": "Night Recovery", "routine_type": "Night", "is_active": 1, "steps": [
            {"step_order": 1, "step_type": "Oil Cleanser", "description": "Oil-based makeup remover"},
            {"step_order": 2, "step_type": "Cleanser", "description": "Water-based cleanser"},
            {"step_order": 3, "step_type": "Treatment", "description": "Retinol or treatment serum"},
            {"step_order": 4, "step_type": "Moisturizer", "description": "Rich night cream"},
        ]},
    ]
    for t in templates:
        doc = frappe.get_doc({"doctype": "Routine Template", **t})
        doc.insert(ignore_permissions=True)


def _create_default_subscription_plans():
    if frappe.db.exists("Subscription Plan", {"is_active": 1}):
        return
    plans = [
        {"plan_name": "Free", "price": 0, "billing_interval": "Monthly", "is_active": 1, "features": [
            {"feature_name": "Basic Profile", "feature_description": "Standard beauty profile"},
            {"feature_name": "Daily Routine", "feature_description": "Basic routine tracking"},
        ]},
        {"plan_name": "Aura Plus", "price": 9.99, "billing_interval": "Monthly", "is_active": 1, "features": [
            {"feature_name": "Everything in Free", "feature_description": "All free features"},
            {"feature_name": "AI Coach", "feature_description": "Personalized AI beauty coach"},
            {"feature_name": "Advanced Analytics", "feature_description": "Detailed skin & hair analytics"},
        ]},
        {"plan_name": "Aura Premium", "price": 19.99, "billing_interval": "Monthly", "is_active": 1, "features": [
            {"feature_name": "Everything in Aura Plus", "feature_description": "All plus features"},
            {"feature_name": "Ingredient Checker", "feature_description": "Full ingredient analysis"},
            {"feature_name": "Priority Support", "feature_description": "24/7 priority support"},
        ]},
    ]
    for p in plans:
        doc = frappe.get_doc({"doctype": "Subscription Plan", **p})
        doc.insert(ignore_permissions=True)


def _create_default_community_groups():
    if frappe.db.exists("Community Group", {"is_active": 1}):
        return
    groups = [
        {"group_name": "Skincare Enthusiasts", "description": "For everyone passionate about skincare", "is_active": 1},
        {"group_name": "Beauty Minimalists", "description": "Less is more — simple routines", "is_active": 1},
        {"group_name": "Ingredient Investigators", "description": "Deep dive into ingredients and formulations", "is_active": 1},
    ]
    for g in groups:
        doc = frappe.get_doc({"doctype": "Community Group", **g})
        doc.insert(ignore_permissions=True)
