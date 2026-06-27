import frappe
from frappe.model.document import Document


class CommunityPost(Document):
    def after_insert(self):
        if self.group:
            group = frappe.get_doc("Community Group", self.group)
            group.members_count = (group.members_count or 0) + 1
            group.save(ignore_permissions=True)
