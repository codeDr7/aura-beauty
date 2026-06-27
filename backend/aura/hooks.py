from frappe import _

app_name = "aura"
app_title = "Aura Beauty Intelligence"
app_publisher = "Aura"
app_description = "Personalized Beauty Intelligence Platform"
app_icon = "octicon octicon-heart"
app_color = "#B89B72"
app_email = "hello@aurabeauty.ai"
app_license = "MIT"

required_apps = ["frappe/erpnext"]

before_install = ""
after_install = "aura.install.after_install"

before_migrate = []
after_migrate = []

app_doc_events = {}

doc_events = {
    "Beauty User Profile": {
        "on_update": "aura.api.profile.on_profile_update"
    }
}

scheduler_events = {
    "daily": [
        "aura.tasks.daily.regenerate_recommendations"
    ],
    "weekly": [
        "aura.tasks.weekly.send_progress_summary"
    ],
    "monthly": [
        "aura.tasks.monthly.archive_inactive_profiles"
    ]
}

doctype_js = {}
doctype_list_js = {}
doctype_tree_js ={}
doctype_dashboard_js = {}

permission_query_conditions = {
    "Beauty User Profile": "frappe.core.doctype.user.user.get_permission_query_conditions",
}

has_permission = {
    "Beauty User Profile": "frappe.core.doctype.user.user.has_permission",
}

doc_type_permissions = {
    "Beauty User Profile": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1, "submit": 0, "cancel": 0, "amend": 0},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0, "submit": 0, "cancel": 0, "amend": 0},
    ],
    "Skin Assessment": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 1, "delete": 0},
    ],
    "Hair Assessment": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 1, "delete": 0},
    ],
    "Lifestyle Assessment": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 1, "delete": 0},
    ],
    "Beauty Product": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "Item Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "User Routine": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 0},
    ],
    "Community Post": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
    ],
    "Community Comment": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
    ],
    "Community Group": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "AI Conversation": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 1, "delete": 0},
    ],
    "Recommendation Result": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "Subscription Plan": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "User Subscription": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "Beauty Diary Entry": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 0},
    ],
    "Ingredient Conflict": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "Achievement Badge": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "User Badge": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "Price Alert": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
    ],
    "Skin Analysis Result": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 0},
    ],
    "Marketplace Partner": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 0, "create": 0, "delete": 0},
    ],
    "Marketplace Order": [
        {"role": "System Manager", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 1},
        {"role": "All", "permlevel": 0, "read": 1, "write": 1, "create": 1, "delete": 0},
    ],
}

fixtures = [
    {"dt": "Subscription Plan", "filters": [["is_active", "=", 1]]},
    {"dt": "Concern Tag", "filters": [["is_active", "=", 1]]},
    {"dt": "Routine Template", "filters": [["is_active", "=", 1]]},
    {"dt": "Community Group", "filters": [["is_active", "=", 1]]},
]

navigation = [
    {
        "label": _("Beauty Profile"),
        "icon": "octicon octicon-person",
        "items": [
            {"type": "doctype", "name": "Beauty User Profile", "label": _("My Profile")},
        ]
    },
    {
        "label": _("Assessments"),
        "icon": "octicon octicon-checklist",
        "items": [
            {"type": "doctype", "name": "Skin Assessment", "label": _("Skin Assessment")},
            {"type": "doctype", "name": "Hair Assessment", "label": _("Hair Assessment")},
            {"type": "doctype", "name": "Lifestyle Assessment", "label": _("Lifestyle Assessment")},
        ]
    },
    {
        "label": _("Products"),
        "icon": "octicon octicon-package",
        "items": [
            {"type": "doctype", "name": "Beauty Product", "label": _("All Products")},
            {"type": "doctype", "name": "Product Ingredient", "label": _("Ingredients")},
            {"type": "doctype", "name": "Ingredient Conflict", "label": _("Ingredient Conflicts")},
            {"type": "doctype", "name": "Price Alert", "label": _("Price Alerts")},
        ]
    },
    {
        "label": _("Routines"),
        "icon": "octicon octicon-sync",
        "items": [
            {"type": "doctype", "name": "Routine Template", "label": _("Routine Templates")},
            {"type": "doctype", "name": "User Routine", "label": _("My Routines")},
        ]
    },
    {
        "label": _("Community"),
        "icon": "octicon octicon-people",
        "items": [
            {"type": "doctype", "name": "Community Post", "label": _("Feed")},
            {"type": "doctype", "name": "Community Group", "label": _("Groups")},
            {"type": "doctype", "name": "Challenge", "label": _("Challenges")},
        ]
    },
    {
        "label": _("Diary"),
        "icon": "octicon octicon-book",
        "items": [
            {"type": "doctype", "name": "Beauty Diary Entry", "label": _("Beauty Diary")},
        ]
    },
    {
        "label": _("Progress"),
        "icon": "octicon octicon-graph",
        "items": [
            {"type": "doctype", "name": "Progress Entry", "label": _("Track Progress")},
            {"type": "doctype", "name": "Achievement Badge", "label": _("Badges")},
        ]
    },
    {
        "label": _("Subscriptions"),
        "icon": "octicon octicon-credit-card",
        "items": [
            {"type": "doctype", "name": "Subscription Plan", "label": _("Plans")},
            {"type": "doctype", "name": "User Subscription", "label": _("My Subscription")},
        ]
    },
    {
        "label": _("AI Coach"),
        "icon": "octicon octicon-chip",
        "items": [
            {"type": "doctype", "name": "AI Conversation", "label": _("Chat History")},
        ]
    },
    {
        "label": _("Skin Analysis"),
        "icon": "octicon octicon-device-camera",
        "items": [
            {"type": "doctype", "name": "Skin Analysis Result", "label": _("Analysis Results")},
        ]
    },
    {
        "label": _("Marketplace"),
        "icon": "octicon octicon-rocket",
        "items": [
            {"type": "doctype", "name": "Marketplace Partner", "label": _("Partners")},
            {"type": "doctype", "name": "Marketplace Order", "label": _("Orders")},
        ]
    },
    {
        "label": _("Reports"),
        "icon": "octicon octicon-report",
        "items": [
            {"type": "report", "name": "User Engagement", "label": _("User Engagement")},
            {"type": "report", "name": "Product Performance", "label": _("Product Performance")},
            {"type": "report", "name": "Assessment Trends", "label": _("Assessment Trends")},
        ]
    },
]

setup_wizard_requires = {
    "complete": True,
    "data": {
        "app_name": "aura",
        "company_name": "Aura Beauty Intelligence",
        "currency": "USD",
        "country": "United States",
        "timezone": "America/New_York",
    }
}

website_context = {
    "top_bar_menu_items": [
        {"label": _("Profile"), "url": "/profile"},
        {"label": _("Assessments"), "url": "/assessments"},
        {"label": _("Products"), "url": "/products"},
        {"label": _("Routines"), "url": "/routines"},
        {"label": _("Community"), "url": "/community"},
        {"label": _("Progress"), "url": "/progress"},
        {"label": _("AI Coach"), "url": "/ai-coach"},
    ]
}
