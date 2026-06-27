import frappe
import secrets
import json
from frappe import _


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


def authenticate_partner():
    api_key = frappe.get_request_header("X-API-Key")
    api_secret = frappe.get_request_header("X-API-Secret")

    if not api_key or not api_secret:
        frappe.throw(_("Missing API credentials"), frappe.AuthenticationError)

    partner = frappe.db.get_value(
        "Marketplace Partner",
        {"api_key": api_key, "api_secret": api_secret, "is_active": 1, "status": "Active"},
        "name"
    )
    if not partner:
        frappe.throw(_("Invalid or inactive API credentials"), frappe.AuthenticationError)

    return partner


# ---- Partner-facing APIs ----

@frappe.whitelist(allow_guest=True)
def partner_register(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)

    if not data.get("company_name") or not data.get("contact_email"):
        frappe.throw(_("Company name and contact email are required"))

    existing = frappe.db.exists("Marketplace Partner", {"company_name": data["company_name"]})
    if existing:
        frappe.throw(_("A partner with this company name already exists"))

    doc = frappe.get_doc({
        "doctype": "Marketplace Partner",
        "company_name": data["company_name"],
        "contact_email": data.get("contact_email"),
        "contact_person": data.get("contact_person"),
        "webhook_url": data.get("webhook_url"),
        "commission_percent": data.get("commission_percent", 0),
        "integration_type": data.get("integration_type", "Custom API"),
        "country": data.get("country"),
        "status": "Pending",
        "is_active": 0,
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return {
        "message": _("Registration submitted for approval"),
        "partner_id": doc.name,
        "api_key": doc.api_key,
        "api_secret": doc.api_secret,
    }


@frappe.whitelist()
def partner_get_orders():
    partner = authenticate_partner()

    orders = frappe.get_all(
        "Marketplace Order",
        filters={"partner": partner},
        fields=["name", "order_id", "user", "total_price", "order_status", "partner_order_ref", "ordered_date", "delivery_address", "payment_status", "notes"],
        order_by="ordered_date desc"
    )

    for o in orders:
        items = frappe.get_all(
            "Marketplace Order Item",
            filters={"parent": o.name},
            fields=["product", "quantity", "unit_price", "total"]
        )
        for item in items:
            product_info = frappe.db.get_value("Beauty Product", item.product, ["product_name", "brand"], as_dict=True)
            item["product_name"] = product_info.product_name if product_info else None
            item["brand"] = product_info.brand if product_info else None
        o["items"] = items

    return orders


@frappe.whitelist()
def partner_update_order_status(order_id, status, invoice_url=None):
    partner = authenticate_partner()

    valid_statuses = ["Confirmed", "Processing", "Shipped", "Delivered", "Cancelled"]
    if status not in valid_statuses:
        frappe.throw(_("Invalid status. Must be one of: {0}").format(", ".join(valid_statuses)))

    order_name = frappe.db.get_value("Marketplace Order", {"order_id": order_id, "partner": partner}, "name")
    if not order_name:
        frappe.throw(_("Order not found for this partner"))

    doc = frappe.get_doc("Marketplace Order", order_name)
    doc.order_status = status
    if invoice_url:
        doc.invoice_url = invoice_url
    doc.save(ignore_permissions=True)
    frappe.db.commit()

    return {"message": _("Order status updated to {0}").format(status), "order_id": order_id, "status": status}


@frappe.whitelist()
def partner_get_products():
    authenticate_partner()

    products = frappe.get_all(
        "Beauty Product",
        filters={"is_active": 1},
        fields=["name", "product_name", "brand", "description", "price", "category", "routine_step"],
        order_by="brand asc, product_name asc"
    )

    return products


# ---- User-facing APIs ----

@frappe.whitelist()
def place_order(product_id, quantity=1):
    profile = get_current_profile()

    if not frappe.db.exists("Beauty Product", product_id):
        frappe.throw(_("Product not found"))

    product = frappe.get_doc("Beauty Product", product_id)

    partners = frappe.get_all(
        "Marketplace Partner",
        filters={"is_active": 1, "status": "Active"},
        fields=["name"],
        limit=1
    )
    if not partners:
        frappe.throw(_("No active marketplace partner available"))

    doc = frappe.get_doc({
        "doctype": "Marketplace Order",
        "partner": partners[0].name,
        "user": profile,
        "order_status": "Pending",
        "payment_status": "Pending",
        "ordered_date": frappe.utils.now(),
        "delivery_address": frappe.db.get_value("Beauty User Profile", profile, "country") or "",
    })
    doc.append("items", {
        "product": product_id,
        "quantity": int(quantity),
        "unit_price": product.price or 0,
    })
    doc.insert(ignore_permissions=True)
    frappe.db.commit()

    return {
        "message": _("Order placed successfully"),
        "order_id": doc.order_id,
        "status": doc.order_status,
    }


@frappe.whitelist()
def get_order_history():
    profile = get_current_profile()

    orders = frappe.get_all(
        "Marketplace Order",
        filters={"user": profile},
        fields=["name", "order_id", "partner", "total_price", "order_status", "payment_status", "ordered_date"],
        order_by="ordered_date desc"
    )

    for o in orders:
        partner_name = frappe.db.get_value("Marketplace Partner", o.partner, "company_name")
        o["partner_name"] = partner_name

        items = frappe.get_all(
            "Marketplace Order Item",
            filters={"parent": o.name},
            fields=["product", "quantity", "unit_price", "total"]
        )
        for item in items:
            product_info = frappe.db.get_value("Beauty Product", item.product, ["product_name", "brand"], as_dict=True)
            item["product_name"] = product_info.product_name if product_info else None
            item["brand"] = product_info.brand if product_info else None
        o["items"] = items

    return orders


@frappe.whitelist()
def track_order(order_id):
    profile = get_current_profile()

    order = frappe.db.get_value(
        "Marketplace Order",
        {"order_id": order_id, "user": profile},
        ["name", "order_id", "partner", "total_price", "order_status", "payment_status", "ordered_date", "delivery_address", "invoice_url", "notes"],
        as_dict=True
    )
    if not order:
        frappe.throw(_("Order not found"))

    partner_name = frappe.db.get_value("Marketplace Partner", order.partner, "company_name")
    order["partner_name"] = partner_name

    items = frappe.get_all(
        "Marketplace Order Item",
        filters={"parent": order.name},
        fields=["product", "quantity", "unit_price", "total"]
    )
    for item in items:
        product_info = frappe.db.get_value("Beauty Product", item.product, ["product_name", "brand"], as_dict=True)
        item["product_name"] = product_info.product_name if product_info else None
        item["brand"] = product_info.brand if product_info else None
    order["items"] = items

    return order


# ---- Admin APIs ----

@frappe.whitelist()
def get_marketplace_stats():
    total_partners = frappe.db.count("Marketplace Partner", {"is_active": 1})
    total_orders = frappe.db.count("Marketplace Order")
    pending_orders = frappe.db.count("Marketplace Order", {"order_status": "Pending"})
    completed_orders = frappe.db.count("Marketplace Order", {"order_status": "Delivered"})
    total_revenue = frappe.db.sql("""
        SELECT COALESCE(SUM(total_price), 0) FROM `tabMarketplace Order`
        WHERE order_status NOT IN ('Cancelled')
    """)[0][0]

    orders_by_status = frappe.db.sql("""
        SELECT order_status, COUNT(*) as count
        FROM `tabMarketplace Order`
        GROUP BY order_status
    """, as_dict=True)

    top_partners = frappe.db.sql("""
        SELECT p.company_name, COUNT(o.name) as order_count, COALESCE(SUM(o.total_price), 0) as revenue
        FROM `tabMarketplace Order` o
        JOIN `tabMarketplace Partner` p ON p.name = o.partner
        WHERE o.order_status NOT IN ('Cancelled')
        GROUP BY o.partner
        ORDER BY revenue DESC
        LIMIT 10
    """, as_dict=True)

    return {
        "total_active_partners": total_partners,
        "total_orders": total_orders,
        "pending_orders": pending_orders,
        "completed_orders": completed_orders,
        "total_revenue": total_revenue,
        "orders_by_status": orders_by_status,
        "top_partners": top_partners,
    }


@frappe.whitelist()
def get_partner_performance(partner_id):
    if not frappe.db.exists("Marketplace Partner", partner_id):
        frappe.throw(_("Partner not found"))

    total_orders = frappe.db.count("Marketplace Order", {"partner": partner_id})
    total_revenue = frappe.db.sql("""
        SELECT COALESCE(SUM(total_price), 0) FROM `tabMarketplace Order`
        WHERE partner = %s AND order_status NOT IN ('Cancelled')
    """, partner_id)[0][0]

    orders_by_status = frappe.db.sql("""
        SELECT order_status, COUNT(*) as count
        FROM `tabMarketplace Order`
        WHERE partner = %s
        GROUP BY order_status
    """, partner_id, as_dict=True)

    recent_orders = frappe.get_all(
        "Marketplace Order",
        filters={"partner": partner_id},
        fields=["order_id", "order_status", "total_price", "ordered_date"],
        order_by="ordered_date desc",
        limit=20
    )

    partner = frappe.get_doc("Marketplace Partner", partner_id)

    return {
        "partner": partner.as_dict(),
        "total_orders": total_orders,
        "total_revenue": total_revenue,
        "orders_by_status": orders_by_status,
        "recent_orders": recent_orders,
    }
