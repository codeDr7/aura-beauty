import frappe
from frappe.model.document import Document


class AchievementBadge(Document):
    def validate(self):
        if self.requirement_value < 0:
            frappe.throw("Requirement value must be non-negative")
        if self.points < 0:
            frappe.throw("Points must be non-negative")
