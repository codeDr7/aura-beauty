import frappe
from frappe.model.document import Document


class IngredientConflict(Document):
    def validate(self):
        if self.ingredient_a == self.ingredient_b:
            frappe.throw("Cannot create a conflict between the same ingredient")

        existing = frappe.db.exists("Ingredient Conflict", {
            "ingredient_a": self.ingredient_b,
            "ingredient_b": self.ingredient_a,
            "is_active": 1,
            "name": ("!=", self.name)
        })
        if existing:
            frappe.throw("A conflict already exists for this pair in reverse order")
