import frappe
from frappe.model.document import Document


class UserBadge(Document):
    def before_insert(self):
        if self.is_earned and not self.earned_date:
            self.earned_date = frappe.utils.now()

    def validate(self):
        if self.is_earned and self.progress < 100:
            self.progress = 100
