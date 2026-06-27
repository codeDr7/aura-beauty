import frappe
from frappe.model.document import Document


class CommunityComment(Document):
    def after_insert(self):
        post = frappe.get_doc("Community Post", self.post)
        post.comments_count = frappe.db.count("Community Comment", {"post": self.post})
        post.save(ignore_permissions=True)
