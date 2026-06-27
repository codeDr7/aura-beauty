import frappe
from frappe.model.document import Document


class BeautyDiaryEntry(Document):
    def validate(self):
        if self.sleep_hours and (self.sleep_hours < 0 or self.sleep_hours > 24):
            frappe.throw("Sleep hours must be between 0 and 24")

    def before_insert(self):
        if not self.created_at:
            self.created_at = frappe.utils.now()
