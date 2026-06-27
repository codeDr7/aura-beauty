import frappe
from frappe.model.document import Document


class SkinAssessment(Document):
    def before_save(self):
        if not self.assessment_date:
            self.assessment_date = frappe.utils.today()
        self.calculate_overall_score()

    def calculate_overall_score(self):
        score = 70.0
        deductions = {
            "acne_presence": {"None": 0, "Mild": 5, "Moderate": 15, "Severe": 25},
            "pigmentation": {"None": 0, "Low": 3, "Medium": 8, "High": 15},
            "dark_spots": {"None": 0, "Few": 3, "Moderate": 8, "Many": 15},
            "wrinkles": {"None": 0, "Fine": 5, "Moderate": 12, "Advanced": 20},
            "fine_lines": {"None": 0, "Few": 3, "Moderate": 8, "Many": 12},
            "pore_visibility": {"Minimal": 0, "Moderate": 3, "Visible": 8, "Large": 12},
            "redness": {"None": 0, "Low": 3, "Medium": 8, "High": 15},
        }
        for field, mapping in deductions.items():
            value = self.get(field)
            if value:
                score -= mapping.get(value, 0)
        if self.hydration_level:
            if self.hydration_level < 30:
                score -= 10
            elif self.hydration_level < 50:
                score -= 5
            elif self.hydration_level > 80:
                score += 5
        self.overall_score = max(0, min(100, round(score, 1)))

    def after_save(self):
        profile = frappe.get_doc("Beauty User Profile", self.user)
        profile.skin_score = self.overall_score
        profile.last_assessment_date = self.assessment_date
        profile.save(ignore_permissions=True)
