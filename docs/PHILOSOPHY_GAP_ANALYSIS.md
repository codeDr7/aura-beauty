# Aura Philosophy Gap Analysis

Audit of the existing codebase against the Beauty Profile-centric philosophy.
Every item below identifies a gap, its severity, and the refactoring needed.

---

## 1. Beauty User Profile — Insufficient Intelligence Model

**Severity: CRITICAL**

The current `Beauty User Profile` doctype has only **15 fields**:
- Personal: user, full_name, age_range, gender, country, climate
- Basic skin/hair: skin_type, skin_sensitivity, hair_type
- Scores: skin_score, hair_score (singular, no history)
- Status: onboarding_completed, subscription_status, created_date, last_assessment_date

**Required by philosophy (30+ dimensions):**
- Skin: hydration_level, barrier_health, pigmentation_trend, acne_trend, aging_trend
- Hair: hair_density, hair_damage_level, scalp_condition
- Lifestyle: sleep_quality, stress_level, diet_quality, water_intake, exercise_frequency, sun_exposure
- Environmental: season, uv_index, humidity, pollution_level
- Sensitivity: sensitivity_score, reactive_ingredients list
- Progress: routine_consistency, improvement_rate, confidence_scores
- Goals: beauty_goals (multi), current_priorities (multi)
- Risk: risk_factors (multi), warnings
- Historical: historical_changes (child table tracking every field change)

**Action:**
- Expand Beauty User Profile doctype with all intelligence fields
- Add `Profile Snapshot` child table (timestamped field values for history tracking)
- Add `Beauty Goal` child table (goal, priority, target_date, status)
- Add `Risk Factor` child table (factor, severity, detected_date, resolved_date)
- Add `Sensitive Ingredient` child table (ingredient, reaction_type, severity)

---

## 2. Every Action Must Update The Profile — No Auto-Updates Exist

**Severity: CRITICAL**

Currently, completing a routine, writing a diary, taking a selfie, or any user action does NOT update the Beauty Profile. The profile is only set during onboarding and updated when the user manually reassesses.

**Required:** Every user action must trigger profile updates.

| Action | Should Update |
|--------|--------------|
| Complete a routine step | routine_consistency score, streak counter, last_active_date |
| Write a diary entry | mood trend, concern tracking, hydration estimate |
| Take a selfie (camera analysis) | skin_score, pigmentation_trend, acne_trend, hydration_level |
| Log sleep change | sleep_quality, improvement_rate |
| Log diet change | diet_quality, nutrition_score |
| Log water intake | hydration_level (skin) |
| Rate a product | compatible_products list, preferred_ingredients |
| Change climate/environment | environmental_profile, season |
| Complete reassessment | all scores recalculated, historical_changes appended |
| AI Coach conversation | confidence_scores, concern keywords extracted |
| Complete a challenge | achievement_score, consistency_bonus |

**Action:**
- Create `profile_update_handler.py` service that listens to all user actions
- Each action triggers a profile delta calculation and updates relevant fields
- All changes append to `Profile Snapshot` child table with timestamp
- Expose single API endpoint: `POST /api/method/aura.api.profile.record_action` that accepts action type + payload

---

## 3. Recommendation Engine Is Product-First, Not User-Need-First

**Severity: HIGH**

Current engine (`recommendations.py`):
```python
def get_personalized_products(user=None):
    products = frappe.get_all("Beauty Product", ...)
    for product in products:
        weighted_score = get_weighted_product_score(product, profile)
    return scored_products[:20]
```

Starts with products, then scores them against profile. This is the OPPOSITE of what's needed.

**Required flow:**
1. Analyze user's current Beauty Profile → identify needs
2. For each need, determine best intervention type (not just products)
3. Generate ranked interventions list: lifestyle changes, routines, products, professional consults, educational content
4. Products are only surfaced when they are the best intervention

**Action:**
- Rewrite `get_personalized_recommendations()` as:
  ```python
  def analyze_user_needs(profile):
      needs = []
      if profile.hydration_level < 40:
          needs.append({"need": "dehydration", "priority": 9, "best_intervention": "lifestyle+product"})
      if profile.sleep_quality < 3:
          needs.append({"need": "poor_sleep", "priority": 8, "best_intervention": "lifestyle"})
      if profile.pigmentation_trend == "worsening":
          needs.append({"need": "hyperpigmentation", "priority": 7, "best_intervention": "product+routine"})
      # ... 20+ need detectors
      return sorted(needs, key=lambda x: x["priority"], reverse=True)
  ```
- Generate intervention plan from needs, not from product catalog
- Add `Recommendation Reason` logic: for every recommendation, output what user data influenced it, confidence level, alternatives

---

## 4. No "Explain Every Recommendation" System

**Severity: HIGH**

The current recommendation simply returns:
```python
"reason": f"Recommended based on your {profile.skin_type or 'skin'} profile"
```

This is meaningless. Every recommendation must answer:
- Why was this recommended?
- What problem does it solve?
- What user data influenced it?
- How confident is Aura?
- What alternative exists?
- What will improve if followed?

**Action:**
- Create `recommendation_explainer.py` module
- Each recommendation carries a structured explanation object:
  ```json
  {
    "title": "Increase nightly hydration",
    "problem_solved": "Your skin barrier health score is 32/100 (low)",
    "influenced_by": {
      "hydration_level": 28,
      "climate": "dry",
      "sleep_quality": "poor",
      "water_intake": "2 glasses/day"
    },
    "confidence": 87,
    "alternatives": [
      {"type": "product", "name": "Hyaluronic Acid Serum", "why": "Boosts hydration"},
      {"type": "lifestyle", "description": "Increase water to 6+ glasses/day"}
    ],
    "expected_improvement": "Barrier health +15 points in 2 weeks"
  }
  ```

---

## 5. No Health-First Recommendation Ladder

**Severity: HIGH**

The system currently has no concept of intervention hierarchy. Products are mixed with everything else.

**Required intervention ladder (ordered by priority):**
1. **Lifestyle** — sleep, hydration, nutrition, stress, exercise, sun protection
2. **Routine optimization** — step order, frequency, technique
3. **Products** — only after lifestyle + routine are addressed
4. **Professional consultation** — flagged when severity warrants it

**Action:**
- Add `intervention_type` field to all recommendations with priority order
- Never recommend a product if a lifestyle change would have greater impact
- Create `lifestyle_recommendations()` module for sleep, hydration, nutrition, stress, sun

---

## 6. Home Screen Is Not Profile-Centric

**Severity: MEDIUM**

Current Home Screen:
```
- Greeting
- Skin Score + Hair Score gauges
- Today's Routine (product checklist)
- Quick Actions (cards)
- Daily Tip
- Recent Activity
```

Missing the profile intelligence dashboard. The home screen should be the **Beauty Profile Dashboard** showing the user's current state at a glance.

**Action:**
- Replace static scores with a **Profile Health Summary** card showing key intelligence dimensions (hydration, barrier, pigmentation, etc.) in a radar/ring chart
- Add **Priority Alerts** section ("Your hydration is low", "Sleep quality dropped")
- Add **Need-to-Intervention** flow: tap an alert → see explanation → get ranked interventions
- Add **Profile Trend** mini-chart (score over last 30 days)
- Move routine to a sub-section, not the primary focus

---

## 7. Profile Screen Is Not The Beauty Profile Dashboard

**Severity: MEDIUM**

Profile screen currently shows:
- User header (avatar, name)
- Beauty Profile card (skin type, hair type, concerns summary)
- Assessment scores
- Subscription card
- Settings list
- Sign out

This should be the **full Beauty Profile intelligence dashboard**.

**Action:**
- Expand to show all 30+ intelligence dimensions organized into sections:
  - **Personal** (existing)
  - **Skin Intelligence** (type, sensitivity, hydration, barrier, pigmentation trend, acne trend, aging trend)
  - **Hair Intelligence** (type, density, damage, scalp)
  - **Lifestyle Score** (sleep, stress, diet, water, exercise, sun)
  - **Environmental Context** (climate, season, UV)
  - **Goals & Priorities** (active goals, progress)
  - **Risk Factors** (active risks, warnings)
  - **History** (score timeline, milestone achievements)

---

## 8. Discover Screen Is a Product Catalog

**Severity: MEDIUM**

Current Discover screen has search, product cards with prices and compatibility badges. This reads like e-commerce.

**Action:**
- Reframe as **"Explore Your Needs"** — the screen should show:
  1. **Your Current Needs** (derived from Beauty Profile) with explanation
  2. **Solutions** grouped by intervention type (lifestyle first, routines second, products third)
  3. Products only shown after a user taps into a specific need
- Remove "New Arrivals", "Trending" — these are e-commerce concepts
- Keep Ingredient Analyzer (it improves profile understanding)
- Add "How to read a product label" educational content

---

## 9. Marketplace API Is Not Profile-Centric

**Severity: MEDIUM**

The marketplace module is built for B2B cosmetic companies (partner registration, API keys, webhooks). This doesn't improve the user's Beauty Profile directly.

**Action:**
- Reframe marketplace as **"Your Products"** portal: track owned products, usage, effectiveness ratings
- Owned products feed into recommendations (don't recommend what user already owns)
- Product ratings update the profile (which ingredients work best for this user)
- B2B partner portal becomes secondary — cosmetic companies can connect to offer products that match user needs, but the user stays central

---

## 10. No Long-Term Journey Tracking

**Severity: MEDIUM**

There's no concept of monthly/yearly comparisons, seasonal trend analysis, or permanent history.

**Action:**
- Add `Profile Comparison` API: compare current profile snapshot vs. any historical date
- Add `Seasonal Pattern` analysis: detect recurring issues by season
- Add `Annual Report` generation: yearly beauty journey summary
- All recommendations reference historical data: "This same concern appeared last winter and resolved when you used X"

---

## 11. Future Module Readiness

**Severity: LOW-MEDIUM**

The current architecture has no explicit extension points for:
- Dermatologist integration
- Wearable device data
- DNA analysis
- Lab results

**Action:**
- Add `External Data Source` child table to Beauty Profile (source_type, source_id, data_json, recorded_date)
- Add `Professional Connection` doctype (professional_type, professional_name, referral_date, status, notes)
- Create abstract `data_source_handler.py` interface that future modules implement
- This ensures new data sources just plug in without schema redesign

---

## 12. The Golden Rule Audit: Feature by Feature

| Feature | Improves Beauty Profile? | Verdict |
|---------|--------------------------|---------|
| Onboarding Assessment | ✅ Yes — initial profile creation | Keep |
| AI Coach | ✅ Yes — extracts concerns, updates confidence | Keep |
| Beauty Diary | ✅ Yes — feeds concern tracking, lifestyle | Keep, add profile auto-update |
| Ingredient Checker | ✅ Yes — informs sensitivity profile | Keep |
| Routine Timer | ✅ Yes — builds consistency data | Keep |
| Achievement Badges | ⚠️ Partial — motivation tool, no direct profile impact | Keep, link to profile milestones |
| Camera Skin Analysis | ✅ Yes — updates skin intelligence | Keep |
| Price Alerts | ❌ No — e-commerce concept | Redesign: "Effectiveness Alerts" when price drops on products your profile needs |
| Marketplace (B2B) | ⚠️ Partial — can improve if reframed | Redesign: "Your Products" tracking, owned inventory, effectiveness |
| Community | ✅ Yes — goals, challenges, motivation | Keep |
| Progress | ✅ Yes — core to profile evolution | Keep, expand |
| Subscription | ⚠️ No direct profile impact | Keep as monetization, never let it gate profile intelligence |

---

## Implementation Priority

| Priority | Area | Effort | Impact |
|----------|------|--------|--------|
| P0 | Expand Beauty Profile doctype + intelligence fields | Large | Transformative |
| P0 | Profile auto-update handler (every action updates profile) | Medium | Transformative |
| P1 | Rewrite recommendation engine (user-need-first) | Large | Transformative |
| P1 | Recommendation explanation system | Medium | High |
| P1 | Health-first intervention ladder | Medium | High |
| P2 | Refactor Home → Profile Health Dashboard | Medium | High |
| P2 | Refactor Profile → Full Intelligence Dashboard | Large | High |
| P2 | Refactor Discover → "Explore Your Needs" | Medium | Medium |
| P3 | Long-term journey tracking (monthly/yearly) | Medium | Medium |
| P3 | External data source abstraction | Small | Low (future-proofing) |
| P3 | Refactor Marketplace → User Product Hub | Medium | Medium |
| P3 | Refactor Price Alerts → Effectiveness Alerts | Small | Low |

---

## Architecture Impact

The refactored system will look like:

```
┌──────────────────────────────────────────────┐
│                 USER ACTIONS                   │
│  Onboarding │ Diary │ Routine │ Selfie │ ...  │
└──────────────┬───────┬────────┬───────────────┘
               │       │        │
               ▼       ▼        ▼
┌──────────────────────────────────────────────┐
│         Profile Update Handler                │
│  (processes every action → computes deltas)   │
└────────────────┬─────────────────────────────┘
                 │ updates
                 ▼
┌──────────────────────────────────────────────┐
│         Beauty Profile (Live Model)           │
│  30+ fields × history snapshots × trends     │
└──────────┬───────────────────────────────────┘
           │ reads
           ▼
┌──────────────────────────────────────────────┐
│         Dynamic Decision Engine               │
│  1. Analyze user needs from profile          │
│  2. Rank interventions by priority           │
│  3. Generate explained recommendations       │
│  4. Track outcomes → update profile          │
└──────────────────────────────────────────────┘
```

Everything flows from and back to the Beauty Profile. The profile is never static — every action enriches it, every recommendation consumes its latest state.
