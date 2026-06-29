import frappe
from frappe import _
from frappe.utils import formatdate


def execute(filters=None):
    columns = [
        {"label": _("Month"), "fieldname": "month", "fieldtype": "Data", "width": 120},
        {"label": _("Total Orders"), "fieldname": "total_orders", "fieldtype": "Int", "width": 120},
        {"label": _("Total Revenue"), "fieldname": "revenue", "fieldtype": "Currency", "width": 140},
        {"label": _("Avg Order Value"), "fieldname": "avg_order", "fieldtype": "Currency", "width": 140},
        {"label": _("Top Partner"), "fieldname": "top_partner", "fieldtype": "Data", "width": 200},
        {"label": _("Partner Revenue"), "fieldname": "top_revenue", "fieldtype": "Currency", "width": 140},
        {"label": _("Partner Share %"), "fieldname": "top_share", "fieldtype": "Percent", "width": 110},
    ]

    data = frappe.db.sql("""
        SELECT
            DATE_FORMAT(o.ordered_date, '%%Y-%%m') AS month,
            COUNT(o.name) AS total_orders,
            SUM(CASE WHEN o.order_status NOT IN ('Cancelled') THEN o.total_price ELSE 0 END) AS revenue
        FROM `tabMarketplace Order` o
        WHERE o.ordered_date IS NOT NULL
        GROUP BY DATE_FORMAT(o.ordered_date, '%%Y-%%m')
        ORDER BY month DESC
        LIMIT 12
    """, as_dict=True)

    for row in data:
        row.avg_order = round((row.revenue or 0) / row.total_orders, 2) if row.total_orders else 0

        top = frappe.db.sql("""
            SELECT p.company_name, SUM(o.total_price) AS rev
            FROM `tabMarketplace Order` o
            JOIN `tabMarketplace Partner` p ON p.name = o.partner
            WHERE DATE_FORMAT(o.ordered_date, '%%Y-%%m') = %s AND o.order_status NOT IN ('Cancelled')
            GROUP BY o.partner
            ORDER BY rev DESC
            LIMIT 1
        """, row.month, as_dict=True)

        row.top_partner = top[0].company_name if top else "-"
        row.top_revenue = top[0].rev if top else 0
        row.top_share = round((row.top_revenue or 0) / (row.revenue or 1) * 100, 1) if row.revenue else 0

        row.month = formatdate(row.month + "-01", "MMM YYYY")

    chart = {
        "data": {
            "labels": [row.month for row in data],
            "datasets": [{"name": "Revenue", "values": [row.revenue or 0 for row in data]}],
        },
        "type": "line",
    }

    return columns, data, None, chart
