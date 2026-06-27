import frappe
from frappe.model.document import Document


class UserSubscription(Document):
    def before_save(self):
        if not self.start_date:
            self.start_date = frappe.utils.today()

    def on_update(self):
        if self.is_active:
            plan = frappe.get_doc("Subscription Plan", self.plan)
            frappe.db.set_value("Beauty User Profile", self.user, "subscription_status", plan.plan_type)
