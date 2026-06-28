import frappe
from frappe.utils import now_datetime, today


def get_profile(user=None):
    user = user or frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user}, "name")
    if not profile_name:
        frappe.throw("Beauty profile not found")
    return frappe.get_doc("Beauty User Profile", profile_name)


def record_action(action_type, payload=None):
    """Main entry point. Call this when any user action occurs.

    Args:
        action_type: One of the PROFILE_ACTIONS keys
        payload: dict with action-specific data
    """
    profile = get_profile()
    handler = PROFILE_ACTIONS.get(action_type)
    if not handler:
        frappe.log_error(f"Unknown profile action: {action_type}", "Profile Update Handler")
        return

    handler(profile, payload or {})
    profile.profile_version = (profile.profile_version or 1) + 1
    profile.save(ignore_permissions=True)
    return profile


# --- Action Handlers ---

def _handle_diary_entry(profile, payload):
    """Beauty diary entry logged → update mood trend, concern tracking, hydration estimate."""
    mood = payload.get("mood")
    concerns = payload.get("concerns", [])
    notes = payload.get("notes", "")

    if mood:
        _update_trend_field(profile, "mood_trend", mood)

    for concern in concerns:
        if "dry" in concern.lower() or "dehydrat" in concern.lower():
            _adjust_percent(profile, "hydration_level", -3)
        if "breakout" in concern.lower() or "acne" in concern.lower():
            _adjust_percent(profile, "acne_score", 2)
        if "pigment" in concern.lower() or "dark spot" in concern.lower():
            _adjust_percent(profile, "pigmentation_score", 2)

    # Update confidence score upward with more data
    _adjust_percent(profile, "confidence_score", 1)


def _handle_routine_complete(profile, payload):
    """User completed a routine step → update consistency, skin/hair scores."""
    steps_completed = payload.get("steps_completed", 1)
    routine_type = payload.get("routine_type", "")

    consistency = profile.routine_consistency_score or 0
    profile.routine_consistency_score = min(100, consistency + (2 * steps_completed))

    # Small score improvements for consistency
    boost = 0.5 * steps_completed
    profile.skin_score = min(100, (profile.skin_score or 50) + boost)
    profile.hair_score = min(100, (profile.hair_score or 50) + boost)

    _record_snapshot_with_reason(profile, "routine_consistency_score", consistency, profile.routine_consistency_score, "Routine Complete")


def _handle_skin_analysis(profile, payload):
    """Camera skin analysis completed → update skin intelligence fields."""
    analysis = payload.get("analysis", {})

    field_map = {
        "hydration": ("hydration_level", "hydration_trend"),
        "barrier_health": ("barrier_health", "barrier_health_trend"),
        "pigmentation": ("pigmentation_score", "pigmentation_trend"),
        "acne": ("acne_score", "acne_trend"),
        "aging": ("aging_score", "aging_trend"),
    }

    for key, (score_field, trend_field) in field_map.items():
        value = analysis.get(key)
        if value is not None:
            old_score = getattr(profile, score_field, None)
            setattr(profile, score_field, value)
            if old_score is not None:
                trend = "Improving" if value < old_score else ("Worsening" if value > old_score else "Stable")
                setattr(profile, trend_field, trend)

    # Recalculate overall skin score from components
    scores = [
        profile.hydration_level or 50,
        profile.barrier_health or 50,
        100 - (profile.pigmentation_score or 0),
        100 - (profile.acne_score or 0),
        100 - (profile.aging_score or 0),
    ]
    profile.skin_score = round(sum(scores) / len(scores), 1)

    _record_snapshot_with_reason(profile, "skin_score", None, profile.skin_score, "Skin Analysis")


def _handle_lifestyle_log(profile, payload):
    """User logged lifestyle data → update lifestyle fields."""
    field_map = {
        "sleep_quality": "sleep_quality",
        "stress_level": "stress_level",
        "diet_quality": "diet_quality",
        "water_intake": "water_intake",
        "exercise_frequency": "exercise_frequency",
        "sun_exposure": "sun_exposure_level",
    }

    for key, profile_field in field_map.items():
        value = payload.get(key)
        if value is not None:
            setattr(profile, profile_field, value)

    # Hydration level correlates with water intake
    water = payload.get("water_intake")
    if water is not None:
        target_hydration = min(100, water * 12)
        current = profile.hydration_level or 40
        profile.hydration_level = round((current + target_hydration) / 2)

    _record_snapshot_with_reason(profile, "hydration_level", None, profile.hydration_level, "Lifestyle Log")


def _handle_product_usage(profile, payload):
    """User rated/tracked a product → update sensitivity profile, preferences."""
    product = payload.get("product_name", "")
    rating = payload.get("rating")
    reaction = payload.get("reaction")

    if reaction and int(rating or 3) < 3:
        profile.append("sensitive_ingredients", {
            "ingredient_name": payload.get("ingredient", product),
            "reaction_type": reaction,
            "severity": "Mild" if int(rating or 3) == 2 else "Moderate",
            "confirmed_date": today(),
            "notes": f"Reaction reported after using {product}",
        })

    if rating and int(rating) >= 4:
        _adjust_percent(profile, "confidence_score", 2)


def _handle_ai_coach(profile, payload):
    """AI Coach conversation completed → extract concerns, update confidence."""
    concerns_detected = payload.get("concerns_detected", [])
    for concern in concerns_detected:
        concern_lower = concern.lower()
        if "dry" in concern_lower or "dehydrat" in concern_lower:
            _adjust_percent(profile, "hydration_level", -1)
        if "breakout" in concern_lower or "acne" in concern_lower:
            _adjust_percent(profile, "acne_score", 1)

    _adjust_percent(profile, "confidence_score", 3)


def _handle_assessment_complete(profile, payload):
    """User completed a reassessment → update all core fields."""
    assessment_type = payload.get("assessment_type", "")

    if assessment_type == "skin":
        profile.skin_type = payload.get("skin_type", profile.skin_type)
        profile.skin_sensitivity = payload.get("skin_sensitivity", profile.skin_sensitivity)
        profile.skin_score = payload.get("skin_score", profile.skin_score)

    if assessment_type == "hair":
        profile.hair_type = payload.get("hair_type", profile.hair_type)
        profile.hair_score = payload.get("hair_score", profile.hair_score)

    if assessment_type == "lifestyle":
        profile.sleep_quality = payload.get("sleep_quality", profile.sleep_quality)
        profile.stress_level = payload.get("stress_level", profile.stress_level)
        profile.diet_quality = payload.get("diet_quality", profile.diet_quality)
        profile.water_intake = payload.get("water_intake", profile.water_intake)

    profile.last_assessment_date = today()
    _adjust_percent(profile, "confidence_score", 5)


# --- Helpers ---

def _handle_profile_updated(profile, payload):
    """Profile fields updated → confidence boost, triggers recalculation."""
    _adjust_percent(profile, "confidence_score", 2)


PROFILE_ACTIONS = {
    "diary_entry": _handle_diary_entry,
    "routine_complete": _handle_routine_complete,
    "skin_analysis": _handle_skin_analysis,
    "lifestyle_log": _handle_lifestyle_log,
    "product_usage": _handle_product_usage,
    "ai_coach": _handle_ai_coach,
    "assessment_complete": _handle_assessment_complete,
    "profile_updated": _handle_profile_updated,
}


def _adjust_percent(profile, field, delta):
    """Adjust a percent field by delta, clamped to 0-100."""
    current = getattr(profile, field, None) or 50
    setattr(profile, field, min(100, max(0, current + delta)))


def _update_trend_field(profile, field, value):
    """Update a trend/categorical field."""
    setattr(profile, field, value)


def _record_snapshot_with_reason(profile, field_name, old_val, new_val, reason):
    """Append a snapshot entry to track changes."""
    if old_val is not None and old_val == new_val:
        return
    profile.append("profile_snapshots", {
        "snapshot_date": now_datetime(),
        "field_name": field_name,
        "previous_value": str(old_val or ""),
        "new_value": str(new_val or ""),
        "change_reason": reason,
        "action_type": reason,
    })


@frappe.whitelist()
def api_record_action(action_type, payload=None):
    """API endpoint for recording user actions from the frontend.

    POST /api/method/aura.api.profile_update_handler.api_record_action
    {"action_type": "diary_entry", "payload": {"mood": "good", ...}}
    """
    payload = payload or {}
    if isinstance(payload, str):
        payload = frappe.parse_json(payload)
    profile = record_action(action_type, payload)
    return {
        "status": "success",
        "profile_version": profile.profile_version,
        "updated_fields": list(payload.keys()) if payload else [],
    }
