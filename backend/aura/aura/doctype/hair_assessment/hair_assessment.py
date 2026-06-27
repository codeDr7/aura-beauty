import frappe
from frappe.model.document import Document


class HairAssessment(Document):
    def before_save(self):
        if not self.assessment_date:
            self.assessment_date = frappe.utils.today()
        self.calculate_overall_score()

    def calculate_overall_score(self):
        score = 70.0
        deductions = {
            "hair_loss": {"None": 0, "Mild": 5, "Moderate": 15, "Severe": 25},
            "dandruff": {"None": 0, "Mild": 3, "Moderate": 8, "Severe": 15},
            "dryness": {"None": 0, "Low": 3, "Medium": 8, "High": 12},
            "hair_damage": {"None": 0, "Low": 3, "Medium": 8, "High": 15, "Extreme": 25},
        }
        for field, mapping in deductions.items():
            value = self.get(field)
            if value:
                score -= mapping.get(value, 0)
        if self.chemical_treatments == "Frequent":
            score -= 10
        elif self.chemical_treatments == "Occasional":
            score -= 3
        self.overall_score = max(0, min(100, round(score, 1)))

    def after_save(self):
        profile = frappe.get_doc("Beauty User Profile", self.user)
        profile.hair_score = self.overall_score
        profile.save(ignore_permissions=True)
