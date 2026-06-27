import frappe
from frappe import _
import json


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


def build_context_for_profile(profile_name):
    profile = frappe.get_doc("Beauty User Profile", profile_name)

    latest_skin = frappe.get_all(
        "Skin Assessment",
        filters={"user": profile_name},
        fields=["skin_type", "acne_presence", "sensitivity", "overall_score"],
        order_by="assessment_date desc",
        limit=1,
    )
    latest_hair = frappe.get_all(
        "Hair Assessment",
        filters={"user": profile_name},
        fields=["hair_type", "scalp_condition", "hair_loss", "overall_score"],
        order_by="assessment_date desc",
        limit=1,
    )

    context_parts = [
        f"User profile: {profile.full_name}",
        f"Skin type: {profile.skin_type or 'Not assessed'}",
        f"Hair type: {profile.hair_type or 'Not assessed'}",
        f"Sensitivity: {profile.skin_sensitivity or 'Not assessed'}",
        f"Climate: {profile.climate or 'Not specified'}",
    ]

    if latest_skin:
        s = latest_skin[0]
        context_parts.extend([
            f"Latest skin score: {s.overall_score}",
            f"Acne level: {s.acne_presence}",
            f"Sensitivity: {s.sensitivity}",
        ])

    if latest_hair:
        h = latest_hair[0]
        context_parts.extend([
            f"Latest hair score: {h.overall_score}",
            f"Scalp condition: {h.scalp_condition}",
            f"Hair loss: {h.hair_loss}",
        ])

    return ". ".join(context_parts)


def generate_ai_response(message, context_type="General"):
    message_lower = message.lower()

    if "acne" in message_lower or "pimple" in message_lower or "breakout" in message_lower:
        return (
            "For acne-prone skin, I recommend:\n\n"
            "1. Use a gentle salicylic acid cleanser twice daily\n"
            "2. Apply a non-comedogenic moisturizer to maintain barrier\n"
            "3. Use benzoyl peroxide or niacinamide for active breakouts\n"
            "4. Always wear oil-free SPF during the day\n"
            "5. Consider adding a retinol serum (start with low concentration 2-3x/week)\n\n"
            "Would you like product recommendations for acne-prone skin?"
        )

    if "routine" in message_lower:
        return (
            "A balanced skincare routine should include:\n\n"
            "**Morning:**\n"
            "- Gentle cleanser\n"
            "- Vitamin C serum (antioxidant protection)\n"
            "- Moisturizer\n"
            "- SPF 30+ (essential!)\n\n"
            "**Evening:**\n"
            "- Oil-based cleanser (if wearing makeup/SPF)\n"
            "- Water-based cleanser\n"
            "- Treatment (retinol, exfoliant, or serum)\n"
            "- Moisturizer or night cream\n\n"
            "Your routine should be tailored to your skin type and concerns. "
            "Would you like a personalized routine?"
        )

    if "dry" in message_lower and ("skin" in message_lower or "hair" not in message_lower):
        return (
            "For dry skin management:\n\n"
            "1. Use a creamy, hydrating cleanser (avoid foaming cleansers)\n"
            "2. Apply hyaluronic acid serum on damp skin\n"
            "3. Use a rich moisturizer with ceramides\n"
            "4. Add a facial oil to lock in moisture\n"
            "5. Use a humidifier in dry environments\n"
            "6. Exfoliate gently only 1-2 times per week\n\n"
            "Avoid products with alcohol, sulfates, or high concentrations of exfoliating acids."
        )

    if "oily" in message_lower and "skin" in message_lower:
        return (
            "For oily skin management:\n\n"
            "1. Cleanse twice daily with a gentle foaming cleanser\n"
            "2. Use a lightweight, gel-based moisturizer\n"
            "3. Niacinamide helps regulate oil production\n"
            "4. Clay masks 1-2 times per week\n"
            "5. Blotting papers for mid-day shine\n"
            "6. Use salicylic acid exfoliant 2-3x/week\n\n"
            "Don't skip moisturizer - dehydrated oily skin produces even more oil!"
        )

    if "hair" in message_lower:
        if "loss" in message_lower or "fall" in message_lower or "thinning" in message_lower:
            return (
                "For hair loss concerns:\n\n"
                "1. Check your nutrition - iron, zinc, biotin, and vitamin D are crucial\n"
                "2. Avoid tight hairstyles that pull on the scalp\n"
                "3. Use a gentle, sulfate-free shampoo\n"
                "4. Consider a caffeine-based scalp treatment\n"
                "5. Reduce heat styling and chemical treatments\n"
                "6. Scalp massage can improve blood circulation\n\n"
                "If shedding persists, consult a dermatologist or trichologist."
            )
        return (
            "For healthy hair care:\n\n"
            "1. Choose shampoo based on your scalp type, not hair type\n"
            "2. Condition mid-lengths to ends only (not scalp)\n"
            "3. Use a hair mask weekly for extra nourishment\n"
            "4. Limit heat styling to 2-3 times per week max\n"
            "5. Use a silk or satin pillowcase\n"
            "6. Trim ends every 6-8 weeks\n"
            "7. Protect hair from sun and chlorine\n\n"
            "What specific hair concern are you dealing with?"
        )

    if "product" in message_lower or "recommend" in message_lower:
        return (
            "I can help recommend products! To give you the best suggestions, let me check your profile.\n\n"
            "I'll consider:\n"
            "- Your skin type and concerns\n"
            "- Your hair type\n"
            "- Your budget\n"
            "- Any specific goals you have\n\n"
            "Visit the Products section for personalized recommendations, or tell me more about what you're looking for!"
        )

    if "ingredient" in message_lower or "what is" in message_lower:
        return (
            "Here are some key beauty ingredients to know:\n\n"
            "**Hydrators:** Hyaluronic Acid, Glycerin, Panthenol\n"
            "**Antioxidants:** Vitamin C, Vitamin E, Niacinamide, Ferulic Acid\n"
            "**Exfoliants:** Glycolic Acid (AHA), Salicylic Acid (BHA), Lactic Acid\n"
            "**Anti-aging:** Retinol/Retinoids, Peptides, Bakuchiol\n"
            "**Soothing:** Centella Asiatica, Aloe Vera, Green Tea\n"
            "**Brightening:** Vitamin C, Kojic Acid, Azelaic Acid, Tranexamic Acid\n\n"
            "Which ingredient would you like to learn more about?"
        )

    return (
        "Thanks for your question about beauty and skincare! I'm your AI Beauty Coach.\n\n"
        "I can help you with:\n"
        "- Skincare routines and product recommendations\n"
        "- Ingredient information and education\n"
        "- Hair care advice\n"
        "- Understanding your assessment results\n"
        "- Lifestyle tips for better skin and hair\n\n"
        f"You mentioned: '{message}'\n\n"
        "Could you provide more details so I can give you a more specific answer?"
    )


@frappe.whitelist()
def ask_question(message, context="General"):
    if not message or len(message.strip()) == 0:
        frappe.throw(_("Message is required"))

    profile = get_current_profile()

    profile_context = build_context_for_profile(profile)

    ai_response = generate_ai_response(message, context)

    doc = frappe.get_doc({
        "doctype": "AI Conversation",
        "user": profile,
        "message": message,
        "response": ai_response,
        "conversation_date": frappe.utils.now_datetime(),
        "context": context if context in ["General", "Routine", "Product", "Skin Concern", "Hair Concern"] else "General",
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return {
        "message": message,
        "response": ai_response,
        "conversation_id": doc.name,
        "context": doc.context,
    }


@frappe.whitelist()
def get_conversation_history(limit=20):
    profile = get_current_profile()

    convos = frappe.get_all(
        "AI Conversation",
        filters={"user": profile},
        fields=["name", "message", "response", "conversation_date", "context", "is_helpful"],
        order_by="conversation_date desc",
        limit=limit,
    )

    return convos


@frappe.whitelist()
def clear_conversation():
    profile = get_current_profile()

    convos = frappe.get_all(
        "AI Conversation",
        filters={"user": profile},
        pluck="name",
    )

    for name in convos:
        frappe.delete_doc("AI Conversation", name, ignore_permissions=True)

    frappe.db.commit()

    return {"message": _("Conversation history cleared"), "deleted": len(convos)}
