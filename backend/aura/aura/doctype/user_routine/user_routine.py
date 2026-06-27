import frappe
from frappe.model.document import Document


class UserRoutine(Document):
    def before_save(self):
        if not self.start_date:
            self.start_date = frappe.utils.today()
        self.calculate_adherence()

    def calculate_adherence(self):
        if not self.steps:
            return
        completed = sum(1 for s in self.steps if s.is_completed)
        self.adherence_rate = round((completed / len(self.steps)) * 100, 1) if self.steps else 0

    def on_update(self):
        if self.is_active:
            existing = frappe.db.exists("User Routine", {
                "user": self.user,
                "is_active": 1,
                "name": ("!=", self.name)
            })
            if existing:
                frappe.db.set_value("User Routine", existing, "is_active", 0)
