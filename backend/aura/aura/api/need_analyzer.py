import frappe
from frappe import _


def analyze_profile(profile):
    """Analyze a Beauty Profile and return prioritized needs.

    Output:
    {
        "needs": [
            {
                "id": "dehydration",
                "label": "Increase hydration",
                "priority": 9,
                "category": "lifestyle",
                "current_state": {"hydration_level": 28},
                "target": "> 60",
                "why": "Your skin hydration is critically low at 28%",
                "confidence": 88,
                "interventions": [
                    {"type": "lifestyle", "label": "Drink 6+ glasses of water daily", "impact": "High"},
                    {"type": "product", "label": "Hyaluronic Acid Serum", "impact": "Medium"},
                ],
                "expected_improvement": "Barrier health +15 points in 2 weeks",
            },
        ],
        "overall_status": "attention_needed",
        "profile_version": profile.profile_version,
    }
    """
    needs = []

    # --- Skin Needs ---
    hydration = profile.hydration_level
    if hydration is not None and hydration < 40:
        needs.append(_build_need(
            profile, "dehydration",
            label="Increase skin hydration",
            priority=9,
            category="lifestyle",
            current={"hydration_level": hydration},
            target="> 60",
            why=f"Your skin hydration is {'critically' if hydration < 25 else 'very'} low at {hydration}%",
            interventions=[
                {"type": "lifestyle", "label": "Drink 6+ glasses of water daily", "impact": "High"},
                {"type": "product", "label": "Hyaluronic Acid or Glycerin-based serum", "impact": "Medium"},
                {"type": "lifestyle", "label": "Use a humidifier in dry environments", "impact": "Medium"},
            ],
            improvement="Barrier health +15 points in 2 weeks",
        ))
    elif hydration is not None and hydration < 60:
        needs.append(_build_need(
            profile, "suboptimal_hydration",
            label="Boost skin hydration",
            priority=5,
            category="lifestyle",
            current={"hydration_level": hydration},
            target="> 60",
            why=f"Your skin hydration is at {hydration}% — room for improvement",
            interventions=[
                {"type": "lifestyle", "label": "Increase water intake to 6+ glasses daily", "impact": "Medium"},
                {"type": "product", "label": "Maintain with a light moisturizer", "impact": "Low"},
            ],
            improvement="Reach optimal hydration in 3-4 weeks",
        ))

    barrier = profile.barrier_health
    if barrier is not None and barrier < 40:
        needs.append(_build_need(
            profile, "barrier_damage",
            label="Repair skin barrier",
            priority=9,
            category="routine",
            current={"barrier_health": barrier},
            target="> 60",
            why=f"Your skin barrier health is only {barrier}% — this causes sensitivity and water loss",
            interventions=[
                {"type": "lifestyle", "label": "Avoid harsh cleansers and exfoliants", "impact": "High"},
                {"type": "product", "label": "Use ceramide and niacinamide-based products", "impact": "High"},
                {"type": "lifestyle", "label": "Reduce stress — cortisol damages barrier function", "impact": "Medium"},
            ],
            improvement="Barrier strength +20 points in 3-4 weeks with consistent care",
        ))

    pigmentation = profile.pigmentation_score
    if pigmentation is not None and pigmentation > 50:
        needs.append(_build_need(
            profile, "hyperpigmentation",
            label="Reduce pigmentation and dark spots",
            priority=7,
            category="product",
            current={"pigmentation_score": pigmentation},
            target="< 30",
            why=f"Pigmentation level is {pigmentation}% — {'severe' if pigmentation > 70 else 'moderate'} concern",
            interventions=[
                {"type": "lifestyle", "label": "Apply SPF 50+ daily — UV worsens pigmentation", "impact": "Critical"},
                {"type": "product", "label": "Vitamin C serum in the morning", "impact": "High"},
                {"type": "product", "label": "Niacinamide or Tranexamic acid at night", "impact": "High"},
                {"type": "routine", "label": "Consider professional consultation for persistent spots", "impact": "Medium"},
            ],
            improvement="Visible reduction in 8-12 weeks with consistent sun protection + active ingredients",
        ))

    acne = profile.acne_score
    if acne is not None and acne > 40:
        needs.append(_build_need(
            profile, "acne_management",
            label="Manage breakouts",
            priority=8,
            category="routine",
            current={"acne_score": acne},
            target="< 20",
            why=f"Acne activity level is {acne}% — {'active breakout phase' if acne > 60 else 'mild but present'}",
            interventions=[
                {"type": "lifestyle", "label": "Clean pillowcases twice weekly", "impact": "Medium"},
                {"type": "product", "label": "Salicylic acid cleanser (2%)", "impact": "High"},
                {"type": "product", "label": "Non-comedogenic moisturizer", "impact": "High"},
                {"type": "lifestyle", "label": "Track diet — dairy and sugar can trigger breakouts", "impact": "Medium"},
            ],
            improvement="Reduced breakouts in 4-6 weeks with consistent routine",
        ))

    aging = profile.aging_score
    if aging is not None and aging > 50:
        needs.append(_build_need(
            profile, "aging_concerns",
            label="Address aging signs",
            priority=6,
            category="product",
            current={"aging_score": aging},
            target="< 35",
            why=f"Aging indicators are at {aging}% — early intervention is most effective",
            interventions=[
                {"type": "lifestyle", "label": "SPF 50+ daily — sun causes 80% of visible aging", "impact": "Critical"},
                {"type": "product", "label": "Retinol (start low, 0.25%) 2-3x per week", "impact": "High"},
                {"type": "lifestyle", "label": "Prioritize 7-8 hours sleep — skin repairs overnight", "impact": "High"},
                {"type": "product", "label": "Peptide and antioxidant-rich moisturizer", "impact": "Medium"},
            ],
            improvement="Visible improvement in fine lines in 8-12 weeks with consistent routine",
        )}

    # --- Hair Needs ---
    hair_damage = profile.hair_damage_level
    if hair_damage is not None and hair_damage > 50:
        needs.append(_build_need(
            profile, "hair_damage",
            label="Repair damaged hair",
            priority=7,
            category="routine",
            current={"hair_damage_level": hair_damage},
            target="< 30",
            why=f"Hair damage level is {hair_damage}% — {'severely' if hair_damage > 70 else 'moderately'} damaged",
            interventions=[
                {"type": "lifestyle", "label": "Reduce heat styling temperature and frequency", "impact": "High"},
                {"type": "product", "label": "Bond-repairing treatment (Olaplex or similar)", "impact": "High"},
                {"type": "routine", "label": "Weekly deep conditioning mask", "impact": "Medium"},
                {"type": "lifestyle", "label": "Silk pillowcase to reduce friction", "impact": "Low"},
            ],
            improvement="Noticeable repair in 4-6 weeks with consistent bond repair treatment",
        ))

    scalp = profile.scalp_condition
    poor_scalp = ["Dry", "Oily", "Flaky", "Irritated"]
    if scalp in poor_scalp:
        needs.append(_build_need(
            profile, "scalp_health",
            label=f"Improve scalp condition ({scalp.lower()})",
            priority=6,
            category="routine",
            current={"scalp_condition": scalp},
            target="Healthy",
            why=f"Your scalp is currently {scalp.lower()} — healthy scalp is the foundation of healthy hair",
            interventions=[
                {"type": "product", "label": f"Use a scalp-specific treatment for {scalp.lower()} scalp", "impact": "High"},
                {"type": "lifestyle", "label": "Wash hair with lukewarm water, not hot", "impact": "Medium"},
                {"type": "routine", "label": "Gentle scalp massage during washing", "impact": "Medium"},
            ],
            improvement="Scalp health improvement in 2-3 weeks with targeted care",
        ))

    # --- Lifestyle Needs ---
    sleep = profile.sleep_quality
    if sleep in ["Poor", "Fair"]:
        needs.append(_build_need(
            profile, "sleep_quality",
            label=f"Improve sleep quality ({sleep.lower()})",
            priority=8,
            category="lifestyle",
            current={"sleep_quality": sleep},
            target="Good or Excellent",
            why=f"Your sleep quality is {sleep.lower()} — poor sleep directly impacts skin repair and hair health",
            interventions=[
                {"type": "lifestyle", "label": "Aim for 7-8 hours of uninterrupted sleep", "impact": "High"},
                {"type": "lifestyle", "label": "No screens 1 hour before bed", "impact": "Medium"},
                {"type": "lifestyle", "label": "Consistent sleep schedule (same time ±30 min)", "impact": "Medium"},
            ],
            improvement="Visible skin improvement in 2 weeks + better energy levels",
        ))

    stress = profile.stress_level
    if stress in ["High", "Very High"]:
        needs.append(_build_need(
            profile, "stress_management",
            label=f"Manage stress level ({stress.lower()})",
            priority=8,
            category="lifestyle",
            current={"stress_level": stress},
            target="Moderate or Low",
            why=f"Your stress level is {stress.lower()} — cortisol accelerates aging and triggers breakouts",
            interventions=[
                {"type": "lifestyle", "label": "10-minute daily mindfulness or meditation", "impact": "High"},
                {"type": "lifestyle", "label": "Regular exercise (3-4x per week)", "impact": "High"},
                {"type": "lifestyle", "label": "Reduce caffeine after 2 PM", "impact": "Medium"},
            ],
            improvement="Reduced cortisol levels in 1-2 weeks with consistent practice",
        ))

    water = profile.water_intake
    if water is not None and water < 4:
        needs.append(_build_need(
            profile, "water_intake",
            label="Increase daily water intake",
            priority=7,
            category="lifestyle",
            current={"water_intake": water},
            target="6+ glasses",
            why=f"You're drinking only {water} glasses daily — dehydration directly affects skin plumpness",
            interventions=[
                {"type": "lifestyle", "label": "Keep a 1L water bottle at your desk", "impact": "High"},
                {"type": "lifestyle", "label": "Set hourly hydration reminders", "impact": "Medium"},
                {"type": "product", "label": "Hydrating mist for midday refresh", "impact": "Low"},
            ],
            improvement="Skin hydration +15 points and reduced dullness in 1 week",
        ))

    diet = profile.diet_quality
    if diet in ["Poor", "Fair"]:
        needs.append(_build_need(
            profile, "nutrition",
            label=f"Improve diet quality ({diet.lower()})",
            priority=7,
            category="lifestyle",
            current={"diet_quality": diet},
            target="Good or Excellent",
            why=f"Your diet quality is {diet.lower()} — skin and hair need proper nutrition to thrive",
            interventions=[
                {"type": "lifestyle", "label": "Add omega-3 rich foods (salmon, walnuts, flaxseed)", "impact": "High"},
                {"type": "lifestyle", "label": "Include antioxidant-rich berries and leafy greens", "impact": "High"},
                {"type": "lifestyle", "label": "Reduce processed sugar — it triggers inflammation", "impact": "Medium"},
            ],
            improvement="Brighter skin and stronger hair in 3-4 weeks with improved nutrition",
        ))

    sun = profile.sun_exposure_level
    if sun in ["Frequent", "Extended"]:
        needs.append(_build_need(
            profile, "sun_protection",
            label="Improve sun protection",
            priority=9,
            category="lifestyle",
            current={"sun_exposure": sun},
            target="SPF 50+ daily",
            why=f"You have {sun.lower()} sun exposure — UV damage is the #1 cause of premature aging",
            interventions=[
                {"type": "lifestyle", "label": "Apply SPF 50+ every morning, reapply every 2 hours outdoors", "impact": "Critical"},
                {"type": "product", "label": "Lightweight SPF 50+ that works under makeup", "impact": "High"},
                {"type": "lifestyle", "label": "Wear a wide-brim hat during peak hours (10 AM - 4 PM)", "impact": "Medium"},
            ],
            improvement="Prevents 90% of UV damage — single most impactful habit for skin health",
        ))

    # --- Consistency ---
    consistency = profile.routine_consistency_score
    if consistency is not None and consistency < 40:
        needs.append(_build_need(
            profile, "routine_consistency",
            label="Build routine consistency",
            priority=6,
            category="routine",
            current={"routine_consistency": consistency},
            target="> 70",
            why=f"Your routine consistency score is {consistency}% — consistency matters more than products",
            interventions=[
                {"type": "lifestyle", "label": "Start with a simple 3-step routine (cleanse, treat, moisturize)", "impact": "High"},
                {"type": "routine", "label": "Use the Routine Timer feature to build the habit", "impact": "Medium"},
                {"type": "lifestyle", "label": "Keep products visible on your bathroom counter as a reminder", "impact": "Medium"},
            ],
            improvement="Visible results in 4 weeks once routine is consistent",
        ))

    # --- Sort by priority ---
    needs.sort(key=lambda n: n["priority"], reverse=True)

    # --- Overall status ---
    highest_priority = needs[0]["priority"] if needs else 0
    if highest_priority >= 8:
        overall_status = "attention_needed"
    elif highest_priority >= 5:
        overall_status = "monitoring"
    else:
        overall_status = "good"

    return {
        "needs": needs,
        "overall_status": overall_status,
        "needs_count": len(needs),
        "critical_count": len([n for n in needs if n["priority"] >= 8]),
        "profile_version": profile.profile_version,
    }


def _build_need(profile, need_id, label, priority, category, current, target, why, interventions, improvement):
    return {
        "id": need_id,
        "label": label,
        "priority": priority,
        "category": category,
        "current_state": current,
        "target": target,
        "why": why,
        "confidence": _calculate_need_confidence(profile),
        "interventions": interventions,
        "expected_improvement": improvement,
    }


def _calculate_need_confidence(profile):
    """Confidence increases with more data."""
    base = 70
    snapshots = len(profile.profile_snapshots) if profile.profile_snapshots else 0
    return min(99, base + (snapshots // 5))


@frappe.whitelist()
def api_get_needs(user=None):
    """API endpoint to get analyzed needs for the current user.

    GET /api/method/aura.api.need_analyzer.api_get_needs
    """
    from .profile_update_handler import get_profile
    profile = get_profile(user)
    return analyze_profile(profile)
