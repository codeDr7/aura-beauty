import frappe
from frappe.model.document import Document


class AIConversation(Document):
    def before_save(self):
        if not self.conversation_date:
            self.conversation_date = frappe.utils.now_datetime()
