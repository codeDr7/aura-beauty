import frappe
from frappe.model.document import Document


class RoutineTemplate(Document):
    def validate(self):
        if not self.steps:
            frappe.throw("At least one step is required in a routine template")
        step_numbers = [s.step_number for s in self.steps]
        if len(step_numbers) != len(set(step_numbers)):
            frappe.throw("Step numbers must be unique")
