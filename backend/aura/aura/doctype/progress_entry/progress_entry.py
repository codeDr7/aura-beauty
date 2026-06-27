import frappe
from frappe.model.document import Document


class ProgressEntry(Document):
    def before_save(self):
        if not self.entry_date:
            self.entry_date = frappe.utils.today()

    def validate(self):
        if self.skin_score and (self.skin_score < 0 or self.skin_score > 100):
            frappe.throw("Skin score must be between 0 and 100")
        if self.hair_score and (self.hair_score < 0 or self.hair_score > 100):
            frappe.throw("Hair score must be between 0 and 100")
