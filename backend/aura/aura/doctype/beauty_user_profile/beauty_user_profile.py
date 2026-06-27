import frappe
from frappe.model.document import Document


class BeautyUserProfile(Document):
    def before_save(self):
        if not self.created_date:
            self.created_date = frappe.utils.today()
        self.full_name = frappe.db.get_value("User", self.user, "full_name") or self.full_name

    def validate(self):
        if self.skin_score and (self.skin_score < 0 or self.skin_score > 100):
            frappe.throw("Skin score must be between 0 and 100")
        if self.hair_score and (self.hair_score < 0 or self.hair_score > 100):
            frappe.throw("Hair score must be between 0 and 100")
