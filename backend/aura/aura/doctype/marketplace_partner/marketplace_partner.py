import frappe
import secrets
from frappe.model.document import Document


class MarketplacePartner(Document):
    def before_insert(self):
        if not self.api_key:
            self.api_key = "apk_" + secrets.token_hex(16)
        if not self.api_secret:
            self.api_secret = "aps_" + secrets.token_hex(24)

    def validate(self):
        if self.commission_percent and (self.commission_percent < 0 or self.commission_percent > 100):
            frappe.throw("Commission percent must be between 0 and 100")
