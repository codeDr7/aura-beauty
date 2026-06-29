import frappe
from frappe import _


def execute(filters=None):
    columns = [
        {"label": _("Partner"), "fieldname": "partner", "fieldtype": "Link", "options": "Marketplace Partner", "width": 200},
        {"label": _("Total Orders"), "fieldname": "total_orders", "fieldtype": "Int", "width": 120},
        {"label": _("Pending"), "fieldname": "pending", "fieldtype": "Int", "width": 90},
        {"label": _("Confirmed"), "fieldname": "confirmed", "fieldtype": "Int", "width": 100},
        {"label": _("Processing"), "fieldname": "processing", "fieldtype": "Int", "width": 100},
        {"label": _("Shipped"), "fieldname": "shipped", "fieldtype": "Int", "width": 90},
        {"label": _("Delivered"), "fieldname": "delivered", "fieldtype": "Int", "width": 90},
        {"label": _("Cancelled"), "fieldname": "cancelled", "fieldtype": "Int", "width": 100},
        {"label": _("Total Revenue"), "fieldname": "revenue", "fieldtype": "Currency", "width": 130},
        {"label": _("Revenue %"), "fieldname": "revenue_pct", "fieldtype": "Percent", "width": 100},
    ]

    data = frappe.db.sql("""
        SELECT
            p.name AS partner,
            p.company_name,
            COUNT(o.name) AS total_orders,
            SUM(CASE WHEN o.order_status = 'Pending' THEN 1 ELSE 0 END) AS pending,
            SUM(CASE WHEN o.order_status = 'Confirmed' THEN 1 ELSE 0 END) AS confirmed,
            SUM(CASE WHEN o.order_status = 'Processing' THEN 1 ELSE 0 END) AS processing,
            SUM(CASE WHEN o.order_status = 'Shipped' THEN 1 ELSE 0 END) AS shipped,
            SUM(CASE WHEN o.order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
            SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
            SUM(CASE WHEN o.order_status NOT IN ('Cancelled') THEN o.total_price ELSE 0 END) AS revenue
        FROM `tabMarketplace Partner` p
        LEFT JOIN `tabMarketplace Order` o ON o.partner = p.name
        GROUP BY p.name
        ORDER BY revenue DESC
    """, as_dict=True)

    total_revenue = sum(row.revenue or 0 for row in data)

    chart = {
        "data": {
            "labels": [row.company_name for row in data],
            "datasets": [{"name": "Revenue", "values": [row.revenue or 0 for row in data]}],
        },
        "type": "bar",
    }

    for row in data:
        row.revenue_pct = round((row.revenue or 0) / total_revenue * 100, 1) if total_revenue else 0

    return columns, data, None, chart
