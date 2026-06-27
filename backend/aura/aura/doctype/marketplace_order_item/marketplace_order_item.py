import frappe
from frappe.model.document import Document


class MarketplaceOrderItem(Document):
    def validate(self):
        if self.quantity and self.unit_price:
            self.total = self.quantity * self.unit_price
