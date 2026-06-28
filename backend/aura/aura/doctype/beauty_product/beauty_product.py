import frappe
from frappe.model.document import Document


class BeautyProduct(Document):
    def validate(self):
        if self.product_score is not None and (self.product_score < 0 or self.product_score > 100):
            frappe.throw("Product score must be between 0 and 100")
