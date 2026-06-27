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
    return _enrich_profile(profile)


def _enrich_profile(profile):
    """Add computed fields to the profile response."""
    data = profile.as_dict()

    # Add analyzed needs
    try:
        from .need_analyzer import analyze_profile
        needs_data = analyze_profile(profile)
        data["needs_analysis"] = needs_data
    except Exception:
        data["needs_analysis"] = {"needs": [], "overall_status": "unknown"}

    # Calculate improvement rate
    if profile.profile_snapshots:
        snapshots = sorted(profile.profile_snapshots, key=lambda s: s.snapshot_date, reverse=True)
        relevant = [s for s in snapshots if s.field_name in ("skin_score", "hair_score")]
        if len(relevant) >= 2:
            oldest = relevant[-1]
            newest = relevant[0]
            try:
                old_val = float(oldest.previous_value or 0)
                new_val = float(newest.new_value or 0)
                data["computed_improvement"] = round(new_val - old_val, 1)
            except (ValueError, TypeError):
                data["computed_improvement"] = 0
        else:
            data["computed_improvement"] = 0

    data["snapshot_count"] = len(profile.profile_snapshots) if profile.profile_snapshots else 0
    return data


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
        "season": data.get("season"),
        "skin_type": data.get("skin_type"),
        "skin_sensitivity": data.get("skin_sensitivity"),
        "hair_type": data.get("hair_type"),
        "hair_porosity": data.get("hair_porosity"),
        "sleep_quality": data.get("sleep_quality"),
        "stress_level": data.get("stress_level"),
        "diet_quality": data.get("diet_quality"),
        "water_intake": data.get("water_intake"),
        "exercise_frequency": data.get("exercise_frequency"),
        "sun_exposure_level": data.get("sun_exposure_level"),
        "created_date": frappe.utils.today(),
        "last_active_date": frappe.utils.now_datetime(),
    })
    profile.insert(ignore_permissions=True)
    frappe.db.commit()

    return _enrich_profile(profile)


@frappe.whitelist()
def update_profile(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    allowed_fields = [
        "full_name", "age_range", "gender", "country", "climate", "season",
        "skin_type", "skin_sensitivity", "hair_type", "hair_porosity",
        "sleep_quality", "stress_level", "diet_quality", "water_intake",
        "exercise_frequency", "sun_exposure_level", "pollution_level",
        "hydration_level", "barrier_health", "uv_index", "screen_time_hours",
    ]
    for field in allowed_fields:
        if field in data:
            setattr(profile, field, data[field])

    profile.save(ignore_permissions=True)
    frappe.db.commit()

    return _enrich_profile(profile)


@frappe.whitelist()
def get_intelligence_summary():
    """Return a compact intelligence summary for the home screen."""
    profile = get_current_profile()

    from .need_analyzer import analyze_profile
    needs = analyze_profile(profile)

    return {
        "profile_version": profile.profile_version,
        "scores": {
            "skin": profile.skin_score,
            "hair": profile.hair_score,
            "overall": profile.overall_beauty_score or round(((profile.skin_score or 0) + (profile.hair_score or 0)) / 2, 1),
            "consistency": profile.routine_consistency_score,
            "improvement": profile.improvement_rate or 0,
        },
        "skin_intelligence": {
            "hydration": profile.hydration_level,
            "barrier_health": profile.barrier_health,
            "pigmentation": profile.pigmentation_score,
            "acne": profile.acne_score,
            "aging": profile.aging_score,
        },
        "hair_intelligence": {
            "damage_level": profile.hair_damage_level,
            "scalp_condition": profile.scalp_condition,
        },
        "lifestyle": {
            "sleep_quality": profile.sleep_quality,
            "stress_level": profile.stress_level,
            "diet_quality": profile.diet_quality,
            "water_intake": profile.water_intake,
        },
        "needs": needs,
        "goals_count": len(profile.goals) if profile.goals else 0,
        "active_risks": len([r for r in (profile.risk_factors or []) if r.status == "Active"]),
    }


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
