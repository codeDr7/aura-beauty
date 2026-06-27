import frappe
from frappe import _
from datetime import datetime, timedelta


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


@frappe.whitelist()
def create_progress_entry(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    existing = frappe.get_all(
        "Progress Entry",
        filters={"user": profile, "entry_date": frappe.utils.today()},
    )
    if existing:
        frappe.throw(_("Progress entry already exists for today"))

    doc = frappe.get_doc({
        "doctype": "Progress Entry",
        "user": profile,
        "entry_date": data.get("entry_date", frappe.utils.today()),
        "skin_score": data.get("skin_score"),
        "hair_score": data.get("hair_score"),
        "photos": data.get("photos"),
        "notes": data.get("notes"),
        "adherence_rate": data.get("adherence_rate"),
        "mood": data.get("mood"),
        "sleep_quality": data.get("sleep_quality"),
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return doc.as_dict()


@frappe.whitelist()
def get_progress_history(limit=30):
    profile = get_current_profile()

    entries = frappe.get_all(
        "Progress Entry",
        filters={"user": profile},
        fields=["name", "entry_date", "skin_score", "hair_score", "photos", "notes", "adherence_rate", "mood", "sleep_quality", "creation"],
        order_by="entry_date desc",
        limit=limit,
    )

    return entries


@frappe.whitelist()
def get_progress_chart(period="monthly"):
    profile = get_current_profile()
    today = frappe.utils.today()

    if period == "weekly":
        start_date = (datetime.strptime(today, "%Y-%m-%d") - timedelta(days=7)).strftime("%Y-%m-%d")
    elif period == "monthly":
        start_date = (datetime.strptime(today, "%Y-%m-%d") - timedelta(days=30)).strftime("%Y-%m-%d")
    else:
        start_date = (datetime.strptime(today, "%Y-%m-%d") - timedelta(days=90)).strftime("%Y-%m-%d")

    entries = frappe.db.sql("""
        SELECT entry_date, skin_score, hair_score, adherence_rate
        FROM `tabProgress Entry`
        WHERE user = %s AND entry_date >= %s
        ORDER BY entry_date asc
    """, (profile, start_date), as_dict=True)

    return {
        "period": period,
        "start_date": start_date,
        "end_date": today,
        "entries": entries,
    }


@frappe.whitelist()
def get_statistics():
    profile = get_current_profile()
    profile_doc = frappe.get_doc("Beauty User Profile", profile)

    total_entries = frappe.db.count("Progress Entry", {"user": profile})
    total_assessments = (
        frappe.db.count("Skin Assessment", {"user": profile})
        + frappe.db.count("Hair Assessment", {"user": profile})
        + frappe.db.count("Lifestyle Assessment", {"user": profile})
    )
    total_routines = frappe.db.count("User Routine", {"user": profile})
    total_posts = frappe.db.count("Community Post", {"user": profile})

    latest_skin = frappe.get_all(
        "Skin Assessment",
        filters={"user": profile},
        fields=["overall_score"],
        order_by="assessment_date desc",
        limit=1,
    )
    latest_hair = frappe.get_all(
        "Hair Assessment",
        filters={"user": profile},
        fields=["overall_score"],
        order_by="assessment_date desc",
        limit=1,
    )

    return {
        "total_progress_entries": total_entries,
        "total_assessments": total_assessments,
        "total_routines": total_routines,
        "total_community_posts": total_posts,
        "current_skin_score": profile_doc.skin_score,
        "current_hair_score": profile_doc.hair_score,
        "latest_skin_score": latest_skin[0].overall_score if latest_skin else None,
        "latest_hair_score": latest_hair[0].overall_score if latest_hair else None,
        "skin_score_trend": get_score_trend(profile, "Skin Assessment"),
        "hair_score_trend": get_score_trend(profile, "Hair Assessment"),
    }


def get_score_trend(profile, doctype):
    scores = frappe.get_all(
        doctype,
        filters={"user": profile},
        fields=["overall_score"],
        order_by="assessment_date asc",
        limit=5,
    )
    if len(scores) < 2:
        return "stable"
    if scores[-1].overall_score > scores[0].overall_score:
        return "improving"
    elif scores[-1].overall_score < scores[0].overall_score:
        return "declining"
    return "stable"


@frappe.whitelist()
def get_before_after():
    profile = get_current_profile()

    entries = frappe.get_all(
        "Progress Entry",
        filters={"user": profile, "photos": ["is", "set"]},
        fields=["name", "entry_date", "skin_score", "hair_score", "photos", "notes"],
        order_by="entry_date desc",
        limit=50,
    )

    if len(entries) < 2:
        return {
            "has_before_after": False,
            "entries": entries,
            "message": _("Not enough photo entries for before/after comparison"),
        }

    first = entries[-1]
    last = entries[0]

    return {
        "has_before_after": True,
        "before": first,
        "after": last,
        "skin_score_change": round((last.get("skin_score", 0) or 0) - (first.get("skin_score", 0) or 0), 1),
        "hair_score_change": round((last.get("hair_score", 0) or 0) - (first.get("hair_score", 0) or 0), 1),
        "all_entries": entries,
    }


@frappe.whitelist()
def create_diary_entry(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    if not data.get("entry_date"):
        frappe.throw(_("Entry date is required"))

    existing = frappe.db.exists("Beauty Diary Entry", {
        "user": profile,
        "entry_date": data["entry_date"]
    })
    if existing:
        frappe.throw(_("Diary entry already exists for this date"))

    doc = frappe.get_doc({
        "doctype": "Beauty Diary Entry",
        "user": profile,
        "entry_date": data["entry_date"],
        "mood": data.get("mood"),
        "sleep_hours": data.get("sleep_hours"),
        "water_intake": data.get("water_intake"),
        "stress_level": data.get("stress_level"),
        "skin_condition": data.get("skin_condition"),
        "breakout_location": data.get("breakout_location"),
        "notes": data.get("notes"),
        "photo": data.get("photo"),
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return doc.as_dict()


@frappe.whitelist()
def get_diary_entries(limit=30):
    profile = get_current_profile()

    entries = frappe.get_all(
        "Beauty Diary Entry",
        filters={"user": profile},
        fields=["name", "entry_date", "mood", "sleep_hours", "water_intake", "stress_level", "skin_condition", "breakout_location", "notes", "photo", "created_at"],
        order_by="entry_date desc",
        limit=limit,
    )

    return entries


@frappe.whitelist()
def get_diary_insights():
    profile = get_current_profile()

    entries = frappe.get_all(
        "Beauty Diary Entry",
        filters={"user": profile},
        fields=["entry_date", "mood", "sleep_hours", "water_intake", "stress_level", "skin_condition", "breakout_location"],
        order_by="entry_date asc",
        limit=90
    )

    if not entries or len(entries) < 3:
        return {
            "has_enough_data": False,
            "message": _("Need at least 3 diary entries to generate insights"),
            "total_entries": len(entries),
        }

    breakout_entries = [e for e in entries if e.skin_condition and "Breakout" in e.skin_condition]
    total_breakouts = len(breakout_entries)

    stress_breakout_correlation = 0
    if total_breakouts > 0:
        high_stress_breakout = sum(1 for e in breakout_entries if e.stress_level == "High")
        stress_breakout_correlation = round((high_stress_breakout / total_breakouts) * 100, 1)

    low_sleep_breakout = 0
    if total_breakouts > 0:
        low_sleep_breakout = sum(1 for e in breakout_entries if e.sleep_hours and e.sleep_hours < 6)

    low_water_breakout = 0
    if total_breakouts > 0:
        low_water_breakout = sum(1 for e in breakout_entries if e.water_intake == "Low")

    mood_trend = {}
    for e in entries:
        if e.mood:
            mood_trend[e.mood] = mood_trend.get(e.mood, 0) + 1

    common_breakout_locations = {}
    for e in breakout_entries:
        if e.breakout_location:
            locations = [loc.strip().lower() for loc in e.breakout_location.split(",")]
            for loc in locations:
                if loc:
                    common_breakout_locations[loc] = common_breakout_locations.get(loc, 0) + 1

    sorted_locations = sorted(common_breakout_locations.items(), key=lambda x: x[1], reverse=True)

    return {
        "has_enough_data": True,
        "total_entries": len(entries),
        "total_breakouts": total_breakouts,
        "breakout_frequency": round((total_breakouts / len(entries)) * 100, 1) if entries else 0,
        "stress_breakout_correlation_pct": stress_breakout_correlation,
        "low_sleep_breakout_count": low_sleep_breakout,
        "low_water_breakout_count": low_water_breakout,
        "mood_distribution": mood_trend,
        "common_breakout_locations": dict(sorted_locations[:5]),
        "recommendations": generate_diary_recommendations(stress_breakout_correlation, low_sleep_breakout, low_water_breakout, total_breakouts, entries)
    }


def generate_diary_recommendations(stress_corr, low_sleep, low_water, total_breakouts, entries):
    recommendations = []

    if stress_corr > 50:
        recommendations.append("Your breakouts strongly correlate with high stress. Consider incorporating stress-management techniques like meditation or yoga into your routine.")
    if low_sleep > total_breakouts * 0.4:
        recommendations.append("Many of your breakouts occur after less than 6 hours of sleep. Aim for 7-9 hours of quality sleep for better skin health.")
    if low_water > total_breakouts * 0.4:
        recommendations.append("Low water intake appears linked to your breakouts. Try to drink at least 8 glasses of water daily.")
    if not recommendations:
        recommendations.append("Keep up your routine! Your diary shows balanced lifestyle factors.")

    return recommendations
