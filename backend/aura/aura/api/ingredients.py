import frappe
from frappe import _


def get_current_profile():
    user_email = frappe.session.user
    profile_name = frappe.db.get_value("Beauty User Profile", {"user": user_email}, "name")
    if not profile_name:
        frappe.throw(_("Beauty profile not found"))
    return profile_name


@frappe.whitelist()
def check_product_conflicts(product_names):
    if isinstance(product_names, str):
        product_names = frappe.parse_json(product_names)

    if not product_names or len(product_names) < 2:
        return {"conflicts": [], "message": _("Need at least 2 products to check")}

    ingredient_pairs = []
    product_ingredients = {}

    for pname in product_names:
        if not frappe.db.exists("Beauty Product", pname):
            continue
        ing = frappe.get_all(
            "Product Concern",
            filters={"parent": pname, "parenttype": "Beauty Product"},
            fields=["concern"]
        )
        product_ingredients[pname] = [i.concern for i in ing if i.concern]

    all_ingredients = set()
    for ing_list in product_ingredients.values():
        all_ingredients.update(ing_list)

    all_ingredients = list(all_ingredients)
    for i in range(len(all_ingredients)):
        for j in range(i + 1, len(all_ingredients)):
            ingredient_pairs.append((all_ingredients[i], all_ingredients[j]))

    if not ingredient_pairs:
        return {"conflicts": [], "message": _("No ingredient data found for these products")}

    conflicts = []
    for ing_a, ing_b in ingredient_pairs:
        conflict = frappe.db.get_value(
            "Ingredient Conflict",
            {
                "ingredient_a": ing_a,
                "ingredient_b": ing_b,
                "is_active": 1
            },
            ["name", "severity", "conflict_type", "description", "recommendation"],
            as_dict=True
        )
        if not conflict:
            conflict = frappe.db.get_value(
                "Ingredient Conflict",
                {
                    "ingredient_a": ing_b,
                    "ingredient_b": ing_a,
                    "is_active": 1
                },
                ["name", "severity", "conflict_type", "description", "recommendation"],
                as_dict=True
            )
        if conflict:
            ing_a_name = frappe.db.get_value("Product Ingredient", ing_a, "ingredient_name")
            ing_b_name = frappe.db.get_value("Product Ingredient", ing_b, "ingredient_name")
            found_in_products = []
            for pname, ing_list in product_ingredients.items():
                if ing_a in ing_list or ing_b in ing_list:
                    found_in_products.append(pname)
            conflict["ingredient_a_name"] = ing_a_name
            conflict["ingredient_b_name"] = ing_b_name
            conflict["found_in_products"] = list(set(found_in_products))
            conflicts.append(conflict)

    return {
        "conflicts": conflicts,
        "total_conflicts": len(conflicts),
        "products_checked": product_names,
    }


@frappe.whitelist()
def get_ingredient_conflicts(ingredient):
    if not frappe.db.exists("Product Ingredient", ingredient):
        frappe.throw(_("Ingredient not found"))

    conflicts = frappe.db.sql("""
        SELECT ic.name, ic.severity, ic.conflict_type, ic.description, ic.recommendation,
               ic.ingredient_a, ic.ingredient_b,
               ia.ingredient_name as ingredient_a_name,
               ib.ingredient_name as ingredient_b_name
        FROM `tabIngredient Conflict` ic
        LEFT JOIN `tabProduct Ingredient` ia ON ia.name = ic.ingredient_a
        LEFT JOIN `tabProduct Ingredient` ib ON ib.name = ic.ingredient_b
        WHERE (ic.ingredient_a = %s OR ic.ingredient_b = %s)
          AND ic.is_active = 1
        ORDER BY CASE ic.severity WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 WHEN 'Low' THEN 4 END
    """, (ingredient, ingredient), as_dict=True)

    return conflicts


@frappe.whitelist()
def check_routine_conflicts(routine_id):
    if not frappe.db.exists("User Routine", routine_id):
        frappe.throw(_("Routine not found"))

    steps = frappe.get_all(
        "User Routine Step",
        filters={"parent": routine_id},
        fields=["step_number", "step_name", "product"]
    )

    products_with_ingredients = {}
    for step in steps:
        if not step.product:
            continue
        ing = frappe.get_all(
            "Product Concern",
            filters={"parent": step.product, "parenttype": "Beauty Product"},
            fields=["concern"]
        )
        products_with_ingredients[step.product] = {
            "step_number": step.step_number,
            "step_name": step.step_name,
            "ingredients": [i.concern for i in ing if i.concern]
        }

    product_names = list(products_with_ingredients.keys())
    if len(product_names) < 2:
        return {"conflicts": [], "message": _("Not enough products with ingredients to check")}

    result = check_product_conflicts(product_names)
    result["routine_id"] = routine_id
    result["steps"] = steps
    return result
