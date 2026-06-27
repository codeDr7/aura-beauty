import frappe
from frappe.model.document import Document


class Challenge(Document):
    def before_save(self):
        if self.start_date and self.duration_days:
            from datetime import timedelta
            self.end_date = self.start_date + timedelta(days=self.duration_days)
