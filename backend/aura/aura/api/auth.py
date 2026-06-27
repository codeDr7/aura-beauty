import frappe
from frappe import _
import re


@frappe.whitelist(allow_guest=True)
def register(email, password, full_name):
    if not email or not password or not full_name:
        frappe.throw(_("Email, password and full name are required"))

    if not re.match(r"[^@]+@[^@]+\.[^@]+", email):
        frappe.throw(_("Invalid email format"))

    if len(password) < 8:
        frappe.throw(_("Password must be at least 8 characters"))

    if frappe.db.exists("User", email):
        frappe.throw(_("User already exists with this email"))

    user = frappe.get_doc({
        "doctype": "User",
        "email": email,
        "first_name": full_name,
        "full_name": full_name,
        "send_welcome_email": 0,
        "user_type": "Website User",
    })
    user.insert(ignore_permissions=True)

    user.new_password = password
    user.save(ignore_permissions=True)

    frappe.db.commit()

    profile = frappe.get_doc({
        "doctype": "Beauty User Profile",
        "user": user.name,
        "full_name": full_name,
        "subscription_status": "Free",
        "created_date": frappe.utils.today(),
    })
    profile.insert(ignore_permissions=True)

    frappe.db.commit()

    return {
        "message": _("Registration successful"),
        "user": user.name,
        "profile": profile.name,
    }


@frappe.whitelist(allow_guest=True)
def login(usr, pwd):
    from frappe.auth import LoginManager

    if not usr or not pwd:
        frappe.throw(_("Username and password are required"))

    lm = LoginManager()
    lm.authenticate(user=usr, pwd=pwd)
    lm.post_login()

    frappe.db.commit()

    return {
        "message": _("Login successful"),
        "user": frappe.session.user,
        "full_name": frappe.db.get_value("User", frappe.session.user, "full_name"),
    }


@frappe.whitelist()
def onboarding_complete():
    user_email = frappe.session.user
    if user_email == "Guest":
        frappe.throw(_("Please login first"), frappe.PermissionError)

    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found. Please complete registration first."))

    profile = frappe.get_doc("Beauty User Profile", profile_name)
    profile.onboarding_completed = 1
    profile.save(ignore_permissions=True)

    frappe.db.commit()

    return {
        "message": _("Onboarding completed"),
        "profile": profile.name,
    }
