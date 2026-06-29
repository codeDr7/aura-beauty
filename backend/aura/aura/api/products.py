import frappe
from frappe import _


@frappe.whitelist()
def get_products(filters=None):
    if isinstance(filters, str):
        filters = frappe.parse_json(filters) if filters else {}

    conditions = {"is_active": 1}

    if filters.get("category"):
        conditions["category"] = filters["category"]
    if filters.get("routine_step"):
        conditions["routine_step"] = filters["routine_step"]
    if filters.get("brand"):
        conditions["brand"] = filters["brand"]
    if filters.get("is_featured"):
        conditions["is_featured"] = 1
    if filters.get("is_subscription_exclusive"):
        conditions["is_subscription_exclusive"] = 1

    return frappe.get_all(
        "Beauty Product",
        filters=conditions,
        fields=["name", "product_name", "brand", "description", "price", "category", "routine_step", "product_score", "is_featured", "is_subscription_exclusive"],
        order_by="product_score desc",
        limit_page_length=filters.get("limit", 50),
    )


@frappe.whitelist()
def get_product(name):
    product = frappe.db.get_value("Beauty Product", {"name": name, "is_active": 1})
    if not product:
        frappe.throw(_("Product not found"))

    product = frappe.get_doc("Beauty Product", product)
    data = product.as_dict()

    data["concerns"] = [
        {"concern": c.concern, "concern_name": frappe.db.get_value("Concern Tag", c.concern, "concern_name") if c.concern else None}
        for c in product.concerns
    ]
    data["ingredients"] = [
        {"ingredient": i.ingredient, "ingredient_name": frappe.db.get_value("Product Ingredient", i.ingredient, "ingredient_name") if i.ingredient else None}
        for i in product.ingredients
    ]

    return data


@frappe.whitelist()
def get_featured_products():
    return frappe.get_all(
        "Beauty Product",
        filters={"is_featured": 1, "is_active": 1},
        fields=["name", "product_name", "brand", "price", "category", "images", "product_score"],
        order_by="product_score desc",
        limit=20,
    )


@frappe.whitelist()
def get_ingredients():
    return frappe.get_all(
        "Product Ingredient",
        filters={"is_active": 1},
        fields=["name", "ingredient_name", "description", "benefits"],
        order_by="ingredient_name asc",
    )


@frappe.whitelist()
def search_products(query):
    if not query or len(query.strip()) < 2:
        frappe.throw(_("Query must be at least 2 characters"))

    search_term = f"%{query}%"

    return frappe.db.sql("""
        SELECT name, product_name, brand, description, price, category, routine_step
        FROM `tabBeauty Product`
        WHERE is_active = 1
          AND (product_name LIKE %s OR brand LIKE %s OR description LIKE %s)
        ORDER BY product_score desc
        LIMIT 20
    """, (search_term, search_term, search_term), as_dict=True)


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


@frappe.whitelist()
def set_price_alert(product, target_price):
    profile = get_current_profile()

    if not frappe.db.exists("Beauty Product", product):
        frappe.throw(_("Product not found"))

    target_price = float(target_price)
    if target_price < 0:
        frappe.throw(_("Target price must be non-negative"))

    existing = frappe.db.exists("Price Alert", {
        "user": profile,
        "product": product,
        "is_triggered": 0
    })
    if existing:
        frappe.throw(_("An active price alert already exists for this product"))

    product_price = frappe.db.get_value("Beauty Product", product, "price") or 0

    doc = frappe.get_doc({
        "doctype": "Price Alert",
        "user": profile,
        "product": product,
        "target_price": target_price,
        "current_price": product_price,
        "is_triggered": 1 if product_price <= target_price else 0,
        "created_date": frappe.utils.today(),
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return doc.as_dict()


@frappe.whitelist()
def get_price_alerts():
    profile = get_current_profile()

    alerts = frappe.get_all(
        "Price Alert",
        filters={"user": profile},
        fields=["name", "product", "target_price", "current_price", "is_triggered", "created_date"],
        order_by="created_date desc"
    )

    for a in alerts:
        product_info = frappe.db.get_value("Beauty Product", a.product, ["product_name", "brand", "price", "images"], as_dict=True)
        a["product_name"] = product_info.product_name if product_info else None
        a["brand"] = product_info.brand if product_info else None
        a["product_price"] = product_info.price if product_info else None

    return alerts


@frappe.whitelist()
def remove_price_alert(alert_id):
    profile = get_current_profile()

    if not frappe.db.exists("Price Alert", alert_id):
        frappe.throw(_("Price alert not found"))

    alert = frappe.get_doc("Price Alert", alert_id)
    if alert.user != profile:
        frappe.throw(_("You can only remove your own price alerts"))

    alert.delete()
    frappe.db.commit()

    return {"message": _("Price alert removed successfully")}
