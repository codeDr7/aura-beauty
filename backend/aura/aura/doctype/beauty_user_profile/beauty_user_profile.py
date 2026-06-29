import frappe
from frappe.model.document import Document
from frappe.utils import now_datetime, today


class BeautyUserProfile(Document):
    def before_save(self):
        if not self.created_date:
            self.created_date = today()
        self.full_name = self.full_name or frappe.db.get_value("User", self.user, "full_name")
        self.last_active_date = now_datetime()

    def validate(self):
        self._capture_snapshot_olds()
        self._validate_scores()
        self._validate_percent_fields()
        self._validate_trend_fields()
        self._update_goal_statuses()

    def _capture_snapshot_olds(self):
        if self.is_new():
            return
        for field in ("skin_score", "hair_score", "overall_beauty_score"):
            setattr(self, f"_old_{field}", frappe.db.get_value("Beauty User Profile", self.name, field))

    def on_update(self):
        self._auto_snapshot()

    def _validate_scores(self):
        score_fields = ["skin_score", "hair_score", "overall_beauty_score"]
        for field in score_fields:
            val = self.get(field)
            if val is not None and (val < 0 or val > 100):
                frappe.throw(f"{field.replace('_', ' ').title()} must be between 0 and 100")

    def _validate_percent_fields(self):
        pct_fields = ["hydration_level", "barrier_health", "pigmentation_score",
                      "acne_score", "aging_score", "hair_damage_level",
                      "routine_consistency_score", "confidence_score"]
        for field in pct_fields:
            val = self.get(field)
            if val is not None and (val < 0 or val > 100):
                frappe.throw(f"{field.replace('_', ' ').title()} must be between 0 and 100")

    def _validate_trend_fields(self):
        trend_fields = ["hydration_trend", "barrier_health_trend", "pigmentation_trend",
                        "acne_trend", "aging_trend", "hair_damage_trend", "scalp_condition_trend"]
        valid = ["Improving", "Stable", "Worsening", "Unknown"]
        for field in trend_fields:
            val = self.get(field)
            if val and val not in valid:
                frappe.throw(f"Invalid trend value for {field}. Must be: Improving, Stable, Worsening, or Unknown")

    def _update_goal_statuses(self):
        for goal in self.goals:
            if goal.progress_percent and goal.progress_percent >= 100:
                goal.status = "Completed"
            elif goal.status == "Completed":
                pass
            elif goal.target_date and frappe.utils.date_diff(goal.target_date, frappe.utils.today()) < 0:
                if goal.status != "Completed":
                    goal.status = "At Risk"

    def _auto_snapshot(self):
        if frappe.flags.in_import or frappe.flags.in_patch:
            return
        for field in ("skin_score", "hair_score", "overall_beauty_score"):
            old_val = getattr(self, f"_old_{field}", None)
            new_val = self.get(field)
            if old_val is not None and old_val != new_val:
                self._record_snapshot(field, old_val, new_val, "System")

    def _record_snapshot(self, field_name, old_val, new_val, reason):
        if old_val == new_val:
            return
        self.append("profile_snapshots", {
            "snapshot_date": now_datetime(),
            "field_name": field_name,
            "previous_value": str(old_val or ""),
            "new_value": str(new_val or ""),
            "change_reason": reason,
            "action_type": "System",
        })
