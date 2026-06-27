import frappe
from frappe.model.document import Document


class LifestyleAssessment(Document):
    def before_save(self):
        if not self.assessment_date:
            self.assessment_date = frappe.utils.today()
        self.calculate_overall_score()

    def calculate_overall_score(self):
        score = 50.0
        mappings = {
            "sleep_quality": {"Poor": 0, "Fair": 5, "Good": 10, "Excellent": 15},
            "water_intake": {"Low": 0, "Medium": 5, "High": 10},
            "activity_level": {"Sedentary": 0, "Light": 5, "Moderate": 10, "Active": 15},
            "stress_level": {"Low": 15, "Medium": 10, "High": 5},
            "sun_exposure": {"Minimal": 5, "Moderate": 10, "Frequent": 5},
        }
        for field, mapping in mappings.items():
            value = self.get(field)
            if value:
                score += mapping.get(value, 0)
        self.overall_score = max(0, min(100, round(score, 1)))
