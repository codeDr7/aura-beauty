import frappe
from frappe import _
from collections import defaultdict


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return frappe.get_doc("Beauty User Profile", profile_name)


def get_weighted_product_score(product, profile):
    """Calculate a weighted match score between a product and a user's profile."""
    score = product.get("product_score", 50) or 50
    ai_weight = product.get("ai_weight", 0.5) or 0.5

    match_bonus = 0

    product_doc = frappe.get_doc("Beauty Product", product.name)

    skin_type_match = False
    for st in product_doc.skin_types:
        if st.skin_type and st.skin_type.lower() == (profile.skin_type or "").lower():
            skin_type_match = True
            break

    if skin_type_match:
        match_bonus += 15

    hair_type_match = False
    for ht in product_doc.hair_types:
        if ht.hair_type and ht.hair_type.lower() == (profile.hair_type or "").lower():
            hair_type_match = True
            break

    if hair_type_match:
        match_bonus += 10

    final_score = (score * (1 - ai_weight)) + (match_bonus * ai_weight)
    return min(100, round(final_score, 1))


@frappe.whitelist()
def get_personalized_products(user=None):
    profile = get_current_profile()

    products = frappe.get_all(
        "Beauty Product",
        filters={"is_active": 1},
        fields=["name", "product_name", "brand", "price", "category", "routine_step", "product_score", "ai_weight"],
    )

    scored_products = []
    for product in products:
        weighted_score = get_weighted_product_score(product, profile)
        scored_products.append({
            "name": product.name,
            "product_name": product.product_name,
            "brand": product.brand,
            "price": product.price,
            "category": product.category,
            "routine_step": product.routine_step,
            "score": weighted_score,
        })

    scored_products.sort(key=lambda x: x["score"], reverse=True)

    return scored_products[:20]


@frappe.whitelist()
def get_personalized_routine(user=None):
    profile = get_current_profile()

    templates = frappe.get_all(
        "Routine Template",
        filters={"is_active": 1},
        fields=["name", "template_name", "routine_type", "description"],
    )

    routines = []
    for template in templates:
        template_doc = frappe.get_doc("Routine Template", template.name)
        steps_data = []
        for step in template_doc.steps:
            steps_data.append({
                "step_number": step.step_number,
                "step_name": step.step_name,
                "step_description": step.step_description,
                "duration_minutes": step.duration_minutes,
                "product_category": step.product_category,
            })

        routines.append({
            "name": template.name,
            "template_name": template.template_name,
            "routine_type": template.routine_type,
            "description": template.description,
            "steps": steps_data,
        })

    morning = [r for r in routines if r["routine_type"] == "Morning"]
    evening = [r for r in routines if r["routine_type"] == "Evening"]
    weekly = [r for r in routines if r["routine_type"] == "Weekly"]

    result = {}

    if profile.skin_type == "Oily":
        result["recommended_routines"] = morning[:1] + evening[:1] + weekly[:1]
    elif profile.skin_type == "Dry":
        result["recommended_routines"] = morning[:1] + evening[:1] + weekly[:1]
    else:
        result["recommended_routines"] = routines[:3]

    result["all_templates"] = routines
    result["profile_context"] = {
        "skin_type": profile.skin_type,
        "hair_type": profile.hair_type,
        "skin_score": profile.skin_score,
        "hair_score": profile.hair_score,
    }

    return result


@frappe.whitelist()
def generate_recommendations(user=None):
    if user:
        profile = frappe.get_doc("Beauty User Profile", user)
    else:
        profile = get_current_profile()

    products = get_personalized_products()
    routine = get_personalized_routine()

    rec = frappe.get_doc({
        "doctype": "Recommendation Result",
        "user": profile.name,
        "recommendation_date": frappe.utils.today(),
        "recommendation_type": "Products",
        "score": profile.skin_score or 0,
    })

    for p in products[:5]:
        rec.append("products", {
            "product": p["name"],
            "score": p["score"] / 100 if p["score"] else 0,
            "reason": f"Recommended based on your {profile.skin_type or 'skin'} profile",
            "routine_step": p["routine_step"],
        })

    rec.insert(ignore_permissions=True)
    frappe.db.commit()

    return {
        "recommendation": rec.name,
        "products": products[:5],
        "routines": routine,
    }


@frappe.whitelist()
def get_recommendation_history():
    profile = get_current_profile()
    recs = frappe.get_all(
        "Recommendation Result",
        filters={"user": profile.name},
        fields=["name", "recommendation_date", "recommendation_type", "score", "is_applied", "feedback"],
        order_by="recommendation_date desc",
        limit=20,
    )

    for rec in recs:
        products = frappe.get_all(
            "Recommended Product",
            filters={"parent": rec.name},
            fields=["product", "score", "reason", "routine_step"],
        )
        rec["products"] = products

    return recs


@frappe.whitelist()
def submit_feedback(recommendation_id, feedback):
    if not frappe.db.exists("Recommendation Result", recommendation_id):
        frappe.throw(_("Recommendation not found"))

    valid_feedback = ["Not Rated", "Helpful", "Not Helpful"]
    if feedback not in valid_feedback:
        frappe.throw(_("Invalid feedback. Must be one of: " + ", ".join(valid_feedback)))

    doc = frappe.get_doc("Recommendation Result", recommendation_id)
    doc.feedback = feedback
    doc.save(ignore_permissions=True)
    frappe.db.commit()

    return {"message": _("Feedback submitted"), "feedback": feedback}
