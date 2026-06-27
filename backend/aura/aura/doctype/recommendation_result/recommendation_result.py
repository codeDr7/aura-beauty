import frappe
from frappe.model.document import Document


class RecommendationResult(Document):
    def before_save(self):
        if not self.recommendation_date:
            self.recommendation_date = frappe.utils.today()
