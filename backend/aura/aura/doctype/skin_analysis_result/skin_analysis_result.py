import frappe
from frappe.model.document import Document


class SkinAnalysisResult(Document):
    def validate(self):
        score_fields = ["hydration_score", "pore_visibility", "texture_score", "pigmentation_score", "redness_score", "overall_score"]
        for field in score_fields:
            val = getattr(self, field, None)
            if val is not None and (val < 0 or val > 100):
                frappe.throw(f"{field.replace('_', ' ').title()} must be between 0 and 100")

    def before_insert(self):
        if not self.analysis_date:
            self.analysis_date = frappe.utils.now()
