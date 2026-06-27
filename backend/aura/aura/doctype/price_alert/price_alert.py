import frappe
from frappe.model.document import Document


class PriceAlert(Document):
    def validate(self):
        if self.target_price and self.current_price and self.target_price >= self.current_price:
            self.is_triggered = 1

    def before_insert(self):
        if not self.created_date:
            self.created_date = frappe.utils.today()
