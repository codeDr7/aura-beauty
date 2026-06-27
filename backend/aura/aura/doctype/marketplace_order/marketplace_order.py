import frappe
from frappe.model.document import Document


class MarketplaceOrder(Document):
    def before_insert(self):
        if not self.ordered_date:
            self.ordered_date = frappe.utils.now()
        if not self.order_id:
            self.order_id = self.name

    def validate(self):
        total = 0
        for item in self.items:
            if item.quantity and item.unit_price:
                item.total = item.quantity * item.unit_price
                total += item.total
        self.total_price = total

    def after_insert(self):
        self.send_webhook_to_partner()

    def send_webhook_to_partner(self):
        partner = frappe.get_doc("Marketplace Partner", self.partner)
        if not partner.webhook_url or not partner.is_active:
            return
        try:
            import requests
            payload = {
                "event": "order.created",
                "order_id": self.order_id,
                "partner_order_ref": self.partner_order_ref,
                "status": self.order_status,
                "items": [{"product": i.product, "quantity": i.quantity, "unit_price": i.unit_price, "total": i.total} for i in self.items],
                "total_price": self.total_price,
                "delivery_address": self.delivery_address,
            }
            headers = {
                "X-API-Key": partner.api_key,
                "X-API-Secret": partner.api_secret,
                "Content-Type": "application/json",
            }
            requests.post(partner.webhook_url, json=payload, headers=headers, timeout=10)
        except Exception:
            frappe.log_error(f"Webhook failed for partner {partner.name}", "Marketplace Webhook")
