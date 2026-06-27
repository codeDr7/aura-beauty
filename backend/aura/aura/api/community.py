import frappe
from frappe import _


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


@frappe.whitelist()
def get_feed(filters=None):
    if isinstance(filters, str):
        filters = frappe.parse_json(filters) if filters else {}

    conditions = {"is_published": 1}

    if filters.get("group"):
        conditions["group"] = filters["group"]
    if filters.get("post_type"):
        conditions["post_type"] = filters["post_type"]

    posts = frappe.get_all(
        "Community Post",
        filters=conditions,
        fields=["name", "user", "content", "image", "post_type", "group", "likes", "comments_count", "saves_count", "is_featured", "creation"],
        order_by="is_featured desc, creation desc",
        limit_page_length=filters.get("limit", 30),
    )

    for post in posts:
        post["user_details"] = frappe.db.get_value(
            "Beauty User Profile", post["user"],
            ["full_name"], as_dict=True
        )
        if post["group"]:
            post["group_details"] = frappe.db.get_value(
                "Community Group", post["group"],
                ["group_name", "category"], as_dict=True
            )

        post["comments"] = frappe.get_all(
            "Community Comment",
            filters={"post": post.name},
            fields=["name", "user", "content", "parent_comment", "likes", "creation"],
            order_by="creation asc",
            limit=5,
        )
        for c in post["comments"]:
            c["user_details"] = frappe.db.get_value(
                "Beauty User Profile", c["user"],
                ["full_name"], as_dict=True
            )

    return posts


@frappe.whitelist()
def create_post(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    profile = get_current_profile()

    if not data.get("content"):
        frappe.throw(_("Content is required"))

    post = frappe.get_doc({
        "doctype": "Community Post",
        "user": profile,
        "content": data["content"],
        "image": data.get("image"),
        "post_type": data.get("post_type", "Text"),
        "group": data.get("group"),
        "is_published": data.get("is_published", 1),
    })
    post.insert(ignore_permissions=True)
    frappe.db.commit()

    return post.as_dict()


@frappe.whitelist()
def like_post(post_id):
    if not frappe.db.exists("Community Post", post_id):
        frappe.throw(_("Post not found"))

    post = frappe.get_doc("Community Post", post_id)
    post.likes = (post.likes or 0) + 1
    post.save(ignore_permissions=True)
    frappe.db.commit()

    return {"likes": post.likes}


@frappe.whitelist()
def add_comment(post_id, content):
    if not frappe.db.exists("Community Post", post_id):
        frappe.throw(_("Post not found"))

    if not content or len(content.strip()) == 0:
        frappe.throw(_("Comment content is required"))

    profile = get_current_profile()

    comment = frappe.get_doc({
        "doctype": "Community Comment",
        "post": post_id,
        "user": profile,
        "content": content,
    })
    comment.insert(ignore_permissions=True)
    frappe.db.commit()

    return comment.as_dict()


@frappe.whitelist()
def get_groups():
    return frappe.get_all(
        "Community Group",
        filters={"is_active": 1},
        fields=["name", "group_name", "description", "cover_image", "category", "is_private", "members_count"],
        order_by="members_count desc",
    )


@frappe.whitelist()
def get_challenges():
    today = frappe.utils.today()
    return frappe.get_all(
        "Challenge",
        filters={"is_active": 1},
        fields=["name", "challenge_name", "description", "cover_image", "duration_days", "category", "start_date", "end_date"],
        order_by="start_date desc",
    )


@frappe.whitelist()
def join_challenge(challenge_id):
    if not frappe.db.exists("Challenge", challenge_id):
        frappe.throw(_("Challenge not found"))

    profile = get_current_profile()
    challenge = frappe.get_doc("Challenge", challenge_id)

    for p in challenge.participants:
        if p.user == profile:
            frappe.throw(_("Already joined this challenge"))

    challenge.append("participants", {
        "user": profile,
        "joined_date": frappe.utils.today(),
        "progress_percent": 0,
        "is_completed": 0,
    })
    challenge.save(ignore_permissions=True)
    frappe.db.commit()

    return {"message": _("Successfully joined the challenge"), "challenge": challenge.name}
