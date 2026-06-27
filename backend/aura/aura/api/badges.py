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
def get_user_badges():
    profile = get_current_profile()

    badges = frappe.get_all(
        "User Badge",
        filters={"user": profile},
        fields=["name", "badge", "earned_date", "progress", "is_earned"],
        order_by="is_earned desc, progress desc"
    )

    for b in badges:
        badge_info = frappe.db.get_value(
            "Achievement Badge",
            b.badge,
            ["badge_name", "badge_description", "icon", "category", "badge_color", "points", "requirement_type", "requirement_value"],
            as_dict=True
        )
        b.update(badge_info or {})

    return badges


@frappe.whitelist()
def get_all_badges():
    badges = frappe.get_all(
        "Achievement Badge",
        filters={"is_active": 1},
        fields=["name", "badge_name", "badge_description", "icon", "category", "requirement_type", "requirement_value", "badge_color", "points"],
        order_by="category asc, requirement_value asc"
    )

    profile = None
    try:
        profile = get_current_profile()
    except Exception:
        pass

    if profile:
        user_badges = frappe.get_all(
            "User Badge",
            filters={"user": profile},
            fields=["badge", "is_earned", "progress"]
        )
        user_badge_map = {b.badge: b for b in user_badges}

        for b in badges:
            if b.name in user_badge_map:
                b["is_earned"] = user_badge_map[b.name].is_earned
                b["progress"] = user_badge_map[b.name].progress
            else:
                b["is_earned"] = 0
                b["progress"] = 0
    else:
        for b in badges:
            b["is_earned"] = 0
            b["progress"] = 0

    return badges


@frappe.whitelist()
def check_and_award_badges():
    profile = get_current_profile()
    awarded = []

    all_badges = frappe.get_all(
        "Achievement Badge",
        filters={"is_active": 1},
        fields=["name", "badge_name", "requirement_type", "requirement_value", "points"]
    )

    existing_user_badges = frappe.get_all(
        "User Badge",
        filters={"user": profile, "is_earned": 1},
        fields=["badge"]
    )
    earned_badge_names = {b.badge for b in existing_user_badges}

    streak_days = calculate_streak_days(profile)
    assessments_completed = (
        frappe.db.count("Skin Assessment", {"user": profile})
        + frappe.db.count("Hair Assessment", {"user": profile})
        + frappe.db.count("Lifestyle Assessment", {"user": profile})
    )
    routines_completed = frappe.db.count("User Routine", {"user": profile, "is_active": 0})
    posts_created = frappe.db.count("Community Post", {"user": profile})
    profile_doc = frappe.get_doc("Beauty User Profile", profile)
    score_target = max(profile_doc.skin_score or 0, profile_doc.hair_score or 0)
    challenge_wins = frappe.db.count("Challenge Participant", {"user": profile, "is_completed": 1})

    current_counts = {
        "Streak Days": streak_days,
        "Assessments Completed": assessments_completed,
        "Routines Completed": routines_completed,
        "Posts Created": posts_created,
        "Score Target": score_target,
        "Challenge Wins": challenge_wins,
    }

    for badge in all_badges:
        if badge.name in earned_badge_names:
            continue

        req_type = badge.requirement_type
        req_value = badge.requirement_value
        current_val = current_counts.get(req_type, 0)
        progress = min(100, int((current_val / req_value) * 100)) if req_value > 0 else 0

        existing_entry = frappe.db.get_value("User Badge", {"user": profile, "badge": badge.name}, "name")
        if existing_entry:
            frappe.db.set_value("User Badge", existing_entry, "progress", progress)
            if current_val >= req_value:
                frappe.db.set_value("User Badge", existing_entry, {
                    "is_earned": 1,
                    "earned_date": frappe.utils.now(),
                    "progress": 100
                })
                awarded.append(badge.badge_name)
        else:
            doc = frappe.get_doc({
                "doctype": "User Badge",
                "user": profile,
                "badge": badge.name,
                "progress": progress,
                "is_earned": 1 if current_val >= req_value else 0,
                "earned_date": frappe.utils.now() if current_val >= req_value else None,
            })
            doc.insert(ignore_permissions=True)
            if current_val >= req_value:
                awarded.append(badge.badge_name)

    if awarded:
        frappe.db.commit()

    return {
        "awarded": awarded,
        "new_badges": len(awarded),
        "message": _("New badges awarded: {0}").format(", ".join(awarded)) if awarded else _("No new badges to award")
    }


def calculate_streak_days(profile):
    entries = frappe.get_all(
        "Progress Entry",
        filters={"user": profile},
        fields=["entry_date"],
        order_by="entry_date desc",
        limit=365
    )

    if not entries:
        return 0

    streak = 0
    check_date = frappe.utils.today()

    for entry in entries:
        if entry.entry_date == check_date:
            streak += 1
            check_date = (datetime.strptime(check_date, "%Y-%m-%d") - timedelta(days=1)).strftime("%Y-%m-%d")
        elif entry.entry_date < check_date:
            break

    return streak
