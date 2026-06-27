# Aura - Beauty Intelligence Platform: Database Schema

---

## 1. Entity-Relationship Diagram (ASCII Art)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   DATABASE ENTITY RELATIONSHIP                               │
│                                                                                              │
│  ┌──────────────┐       ┌───────────────────┐       ┌──────────────────┐                   │
│  │    User      │ 1:1  │ BeautyUserProfile  │ 1:N  │ SkinAssessment   │                   │
│  │  (frappe)    │───────│  user (Link→User)  │───────│  user→Profile    │                   │
│  │              │       │  autoname: user    │       │  autoname: SKIN  │                   │
│  └──────────────┘       └─────────┬─────────┘       └──────────────────┘                   │
│                                   │                                                        │
│                                   │ 1:N                  ┌──────────────────┐              │
│                                   ├──────────────────────│ HairAssessment   │              │
│                                   │                      │  user→Profile    │              │
│                                   │                      └──────────────────┘              │
│                                   │                                                        │
│                                   │ 1:N                  ┌──────────────────┐              │
│                                   ├──────────────────────│ LifestyleAssess  │              │
│                                   │                      │  user→Profile    │              │
│                                   │                      └──────────────────┘              │
│                                   │                                                        │
│                                   │ 1:N                  ┌──────────────────┐              │
│                                   ├──────────────────────│ UserRoutine      │              │
│                                   │                      │  user→Profile    │              │
│                                   │                      └──────────────────┘              │
│                                   │                                                        │
│                                   │ 1:N                  ┌──────────────────┐              │
│                                   ├──────────────────────│ ProgressEntry    │              │
│                                   │                      │  user→Profile    │              │
│                                   │                      └──────────────────┘              │
│                                   │                                                        │
│                                   │ 1:N                  ┌──────────────────┐              │
│                                   ├──────────────────────│ CommunityPost    │              │
│                                   │                      │  user→Profile    │              │
│                                   │                      └────────┬─────────┘              │
│                                   │                               │                        │
│                                   │ 1:N               ┌──────────┴──────────┐              │
│                                   └───────────────────│ CommunityComment    │              │
│                                                        │  post→Post         │              │
│                                                        │  user→Profile      │              │
│                                                        └──────────────────┘              │
│                                                                                              │
│                                   ┌──────────────────┐      ┌──────────────────┐           │
│                                   │ BeautyProduct    │  M:N │ ConcernTag       │           │
│                                   │  autoname: name  │──────│  (via PC child)  │           │
│                                   │  concerns→PC     │      └──────────────────┘           │
│                                   │  ingredients→PI  │                                      │
│                                   │  skin_types→AG   │      ┌──────────────────┐           │
│                                   │  hair_types→AG   │      │ ProductConcern   │  Child    │
│                                   └────────┬─────────┘      │  parent→Product  │           │
│                                            │                │  concern→ConcTag │           │
│                                            │                └──────────────────┘           │
│                                            │                                                │
│                                            │                ┌──────────────────┐           │
│                                            │                │ ProductIngredient│  Child    │
│                                            │                │  parent→Product  │           │
│                                            │                │  ingredient→str  │           │
│                                            │                └──────────────────┘           │
│                                            │                                                │
│                                   ┌────────┴─────────┐      ┌──────────────────┐           │
│                                   │ RoutineTemplate  │      │ Recommendation   │           │
│                                   │  (Predefined)    │      │  Result          │           │
│                                   └──────────────────┘      │  user→Profile    │           │
│                                                              └──────────────────┘           │
│                                                                                              │
│  ┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐                   │
│  │ CommunityGroup   │ 1:N  │ Challenge        │      │ AIConversation   │                   │
│  │  created_by→User │      │  created_by→User │      │  user→Profile    │                   │
│  └──────────────────┘      └──────────────────┘      └──────────────────┘                   │
│                                                                                              │
│  ┌──────────────────┐      ┌──────────────────┐                                             │
│  │ SubscriptionPlan │ 1:N  │ UserSubscription │                                             │
│  │  (Predefined)    │──────│  user→Profile    │                                             │
│  └──────────────────┘      │  plan→SubPlan    │                                             │
│                            └──────────────────┘                                             │
│                                                                                              │
│  ┌──────────────────┐                                                                      │
│  │ AssessmentGoal   │  Child Table (used by SkinAssessment, HairAssessment, BeautyProduct) │
│  │  parent→parent   │                                                                      │
│  │  goal_name       │                                                                      │
│  └──────────────────┘                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. DocType Definitions

### 2.1 Beauty User Profile

**Table**: `tabBeauty User Profile`

**Naming**: `field:user` (matches the User email)

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (User) | Yes | - | Linked Frappe User (unique) |
| 2 | `full_name` | Data | Yes | - | User's display name |
| 3 | `age_range` | Select | Yes | - | `18-24`, `25-34`, `35-44`, `45-54`, `55+` |
| 4 | `gender` | Select | No | - | `Female`, `Male`, `Non-Binary`, `Prefer not to say` |
| 5 | `country` | Data | No | - | User's country |
| 6 | `climate` | Select | No | - | `Tropical`, `Dry`, `Temperate`, `Continental`, `Polar` |
| 7 | `skin_type` | Select | No | - | `Oily`, `Dry`, `Combination`, `Normal` |
| 8 | `skin_sensitivity` | Select | No | - | `Low`, `Medium`, `High` |
| 9 | `hair_type` | Select | No | - | `Straight`, `Wavy`, `Curly`, `Coily` |
| 10 | `skin_score` | Float | No | - | Overall skin health score (0-100) |
| 11 | `hair_score` | Float | No | - | Overall hair health score (0-100) |
| 12 | `onboarding_completed` | Check | No | `0` | Whether onboarding is complete |
| 13 | `subscription_status` | Select | No | `Free` | `Free`, `Aura Plus`, `Aura Premium` |
| 14 | `created_date` | Date | No | - | Profile creation date |
| 15 | `last_assessment_date` | Date | No | - | Last assessment submission date |

**Indexes**:
- Primary: `name` (auto-generated from user)
- Unique: `user`
- Indexed: `skin_type`, `subscription_status`, `onboarding_completed`

**Relationships** (via links):
- `Skin Assessment.user` → `Beauty User Profile`
- `Hair Assessment.user` → `Beauty User Profile`
- `Lifestyle Assessment.user` → `Beauty User Profile`
- `User Routine.user` → `Beauty User Profile`
- `Progress Entry.user` → `Beauty User Profile`
- `Community Post.user` → `Beauty User Profile`

**Python Validations**:
```python
def validate(self):
    if self.skin_score and (self.skin_score < 0 or self.skin_score > 100):
        frappe.throw("Skin score must be between 0 and 100")
    if self.hair_score and (self.hair_score < 0 or self.hair_score > 100):
        frappe.throw("Hair score must be between 0 and 100")
```

**Before Save**:
```python
def before_save(self):
    if not self.created_date:
        self.created_date = frappe.utils.today()
    self.full_name = frappe.db.get_value("User", self.user, "full_name")
```

---

### 2.2 Skin Assessment

**Table**: `tabSkin Assessment`

**Naming**: `format:SKIN-{####}` (e.g., `SKIN-0042`)

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | Linked beauty profile |
| 2 | `assessment_date` | Date | Yes | `Today` | Date of assessment |
| 3 | `skin_type` | Select | Yes | - | `Oily`, `Dry`, `Combination`, `Normal` |
| 4 | `sensitivity` | Select | No | - | `Low`, `Medium`, `High` |
| 5 | `acne_presence` | Select | No | - | `None`, `Mild`, `Moderate`, `Severe` |
| 6 | `pigmentation` | Select | No | - | `None`, `Low`, `Medium`, `High` |
| 7 | `dark_spots` | Select | No | - | `None`, `Few`, `Moderate`, `Many` |
| 8 | `wrinkles` | Select | No | - | `None`, `Fine`, `Moderate`, `Advanced` |
| 9 | `fine_lines` | Select | No | - | `None`, `Few`, `Moderate`, `Many` |
| 10 | `pore_visibility` | Select | No | - | `Minimal`, `Moderate`, `Visible`, `Large` |
| 11 | `redness` | Select | No | - | `None`, `Low`, `Medium`, `High` |
| 12 | `hydration_level` | Percent | No | - | Skin hydration percentage (0-100) |
| 13 | `main_goals` | Table MultiSelect | No | - | Goals via `Assessment Goal` child table |
| 14 | `overall_score` | Float | No | - | Computed skin health score (0-100) |
| 15 | `recommendations` | Text | No | - | AI-generated recommendations text |

**Indexes**:
- Primary: `name` (auto-incrementing SKIN-####)
- Indexed: `user`, `assessment_date`

---

### 2.3 Hair Assessment

**Table**: `tabHair Assessment`

**Naming**: `format:HAIR-{####}` (e.g., `HAIR-0021`)

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | Linked beauty profile |
| 2 | `assessment_date` | Date | Yes | `Today` | Date of assessment |
| 3 | `hair_type` | Select | Yes | - | `Straight`, `Wavy`, `Curly`, `Coily` |
| 4 | `hair_texture` | Select | No | - | `Fine`, `Medium`, `Coarse` |
| 5 | `hair_thickness` | Select | No | - | `Thin`, `Medium`, `Thick` |
| 6 | `hair_density` | Select | No | - | `Low`, `Medium`, `High` |
| 7 | `scalp_condition` | Select | No | - | `Normal`, `Dry`, `Oily`, `Sensitive`, `Dandruff` |
| 8 | `hair_loss` | Select | No | - | `None`, `Mild`, `Moderate`, `Severe` |
| 9 | `dandruff` | Select | No | - | `None`, `Mild`, `Moderate`, `Severe` |
| 10 | `dryness` | Select | No | - | `None`, `Low`, `Medium`, `High` |
| 11 | `chemical_treatments` | Select | No | - | `None`, `Occasional`, `Frequent` |
| 12 | `hair_damage` | Select | No | - | `None`, `Low`, `Medium`, `High`, `Extreme` |
| 13 | `main_goals` | Table MultiSelect | No | - | Goals via `Assessment Goal` child table |
| 14 | `overall_score` | Float | No | - | Computed hair health score (0-100) |
| 15 | `recommendations` | Text | No | - | AI-generated recommendations text |

---

### 2.4 Lifestyle Assessment

**Table**: `tabLifestyle Assessment`

**Naming**: `format:LIFE-{####}` (e.g., `LIFE-0015`)

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | Linked beauty profile |
| 2 | `assessment_date` | Date | Yes | `Today` | Date of assessment |
| 3 | `sleep_quality` | Select | No | - | `Poor`, `Fair`, `Good`, `Excellent` |
| 4 | `water_intake` | Select | No | - | `Low`, `Medium`, `High` |
| 5 | `activity_level` | Select | No | - | `Sedentary`, `Light`, `Moderate`, `Active` |
| 6 | `stress_level` | Select | No | - | `Low`, `Medium`, `High` |
| 7 | `sun_exposure` | Select | No | - | `Minimal`, `Moderate`, `Frequent` |
| 8 | `overall_score` | Float | No | - | Computed lifestyle score (0-100) |

---

### 2.5 Beauty Product

**Table**: `tabBeauty Product`

**Naming**: `field:product_name` (unique product name)

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `product_name` | Data | Yes | - | Unique product name |
| 2 | `brand` | Data | Yes | - | Brand/manufacturer name |
| 3 | `images` | Attach Image | No | - | Product image URL |
| 4 | `description` | Text | No | - | Product description |
| 5 | `price` | Currency | No | - | Product price (non-negative) |
| 6 | `category` | Select | Yes | - | `Skincare`, `Haircare`, `Body`, `Fragrance` |
| 7 | `routine_step` | Select | No | - | `Cleanser`, `Toner`, `Serum`, `Moisturizer`, `SPF`, `Shampoo`, `Conditioner`, `Hair Mask`, `Hair Serum`, `Treatment` |
| 8 | `skin_types` | Table MultiSelect | No | - | Compatible skin types via `Assessment Goal` |
| 9 | `hair_types` | Table MultiSelect | No | - | Compatible hair types via `Assessment Goal` |
| 10 | `concerns` | Table MultiSelect | No | - | Targeted concerns via `Product Concern` |
| 11 | `ingredients` | Table MultiSelect | No | - | Key ingredients via `Product Concern` |
| 12 | `ai_weight` | Float | No | - | AI confidence weight (0-1) |
| 13 | `product_score` | Float | No | - | Computed overall product score (0-100) |
| 14 | `is_featured` | Check | No | `0` | Show as featured product |
| 15 | `is_subscription_exclusive` | Check | No | `0` | Available only to subscribers |
| 16 | `is_active` | Check | No | `1` | Product is active in catalog |

**Indexes**:
- Primary: `name` (unique product_name)
- Unique: `product_name`
- Indexed: `brand`, `category`, `routine_step`, `is_active`, `is_featured`

---

### 2.6 Concern Tag

**Table**: `tabConcern Tag`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `concern_name` | Data | Yes | - | Name of concern (e.g., "Acne", "Dryness") |
| 2 | `category` | Select | No | - | `Skin`, `Hair`, `General` |
| 3 | `is_active` | Check | No | `1` | Whether this tag is in use |

---

### 2.7 Assessment Goal

**Table**: `tabAssessment Goal`

Child table used by `Skin Assessment`, `Hair Assessment`, and `Beauty Product`.

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `parent` | Data (parent) | Yes | - | Parent document name |
| 2 | `parenttype` | Data | Yes | - | Parent DocType |
| 3 | `parentfield` | Data | Yes | - | Parent field name |
| 4 | `goal_name` | Data | Yes | - | Goal or type name (e.g., "Reduce Acne") |
| 5 | `goal_type` | Data | No | - | Categorization of the goal |

---

### 2.8 Product Concern

**Table**: `tabProduct Concern`

Child table linking `Beauty Product` to `Concern Tag`.

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `parent` | Data (parent) | Yes | - | Product name |
| 2 | `parenttype` | Data | Yes | - | `Beauty Product` |
| 3 | `parentfield` | Data | Yes | - | `concerns` |
| 4 | `concern` | Data | Yes | - | Concern name (linked to Concern Tag) |

---

### 2.9 Product Ingredient

**Table**: `tabProduct Ingredient`

Child table listing a product's key ingredients.

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `parent` | Data (parent) | Yes | - | Product name |
| 2 | `parenttype` | Data | Yes | - | `Beauty Product` |
| 3 | `parentfield` | Data | Yes | - | `ingredients` |
| 4 | `ingredient` | Data | Yes | - | Ingredient name (e.g., "Niacinamide") |

---

### 2.10 Recommendation Result

**Table**: `tabRecommendation Result`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | User profile |
| 2 | `generated_date` | Datetime | Yes | - | When recommendations were generated |
| 3 | `type` | Select | No | - | `skin`, `hair`, `all` |
| 4 | `results` | JSON | No | - | JSON array of recommended products with scores |
| 5 | `expires_at` | Datetime | No | - | Cache expiry timestamp |

**Indexes**:
- Indexed: `user`, `generated_date`

---

### 2.11 Routine Template

**Table**: `tabRoutine Template`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `template_name` | Data | Yes | - | Template name |
| 2 | `description` | Text | No | - | Template description |
| 3 | `category` | Select | No | - | `Skincare`, `Haircare` |
| 4 | `skin_type` | Select | No | - | Target skin type |
| 5 | `hair_type` | Select | No | - | Target hair type |
| 6 | `concerns` | Table MultiSelect | No | - | Targeted concerns |
| 7 | `steps` | Table | No | - | Routine steps (child table) |
| 8 | `is_active` | Check | No | `1` | Template is available |

**Routine Step Child Table** (inline):

| # | Field Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `step_order` | Int | Yes | Step sequence number |
| 2 | `time_of_day` | Select | Yes | `Morning`, `Evening`, `Weekly` |
| 3 | `product_category` | Select | No | Category of product needed |
| 4 | `instructions` | Text | No | Usage instructions |

---

### 2.12 User Routine

**Table**: `tabUser Routine`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | User profile |
| 2 | `routine_name` | Data | Yes | - | Custom routine name |
| 3 | `date` | Date | No | `Today` | Routine date |
| 4 | `template` | Link (Routine Template) | No | - | Source template |
| 5 | `completion_percentage` | Percent | No | `0` | Daily completion rate |
| 6 | `steps` | Table | No | - | Routine step details |

**User Routine Step Child Table**:

| # | Field Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `step_order` | Int | Yes | Step number |
| 2 | `time_of_day` | Select | Yes | `Morning`, `Evening`, `Weekly` |
| 3 | `product` | Link (Beauty Product) | No | Product used in this step |
| 4 | `instructions` | Text | No | Custom instructions |
| 5 | `completed` | Check | No | Whether step is done |
| 6 | `completed_at` | Time | No | When step was completed |

---

### 2.13 Community Post

**Table**: `tabCommunity Post`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | Post author |
| 2 | `content` | Text | Yes | - | Post content (max 2000 chars) |
| 3 | `media` | Attach Image | No | - | Attached image/media URL |
| 4 | `post_type` | Select | No | `General` | `General`, `Progress`, `Review`, `Question` |
| 5 | `tags` | Table MultiSelect | No | - | Post tags via child table |
| 6 | `group` | Link (Community Group) | No | - | Associated community group |
| 7 | `product` | Link (Beauty Product) | No | - | Reviewed/recommended product |
| 8 | `is_anonymous` | Check | No | `0` | Hide author identity |
| 9 | `likes_count` | Int | No | `0` | Cached like count |
| 10 | `comments_count` | Int | No | `0` | Cached comment count |

---

### 2.14 Community Comment

**Table**: `tabCommunity Comment`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `post` | Link (Community Post) | Yes | - | Parent post |
| 2 | `user` | Link (Beauty User Profile) | Yes | - | Comment author |
| 3 | `content` | Text | Yes | - | Comment text (max 500 chars) |
| 4 | `created_at` | Datetime | No | `Now` | Timestamp |

---

### 2.15 Community Group

**Table**: `tabCommunity Group`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `title` | Data | Yes | - | Group name |
| 2 | `description` | Text | No | - | Group description |
| 3 | `cover_image` | Attach Image | No | - | Group cover photo |
| 4 | `created_by` | Link (User) | Yes | - | Group creator |
| 5 | `members_count` | Int | No | `0` | Member count |
| 6 | `posts_count` | Int | No | `0` | Total posts in group |
| 7 | `is_active` | Check | No | `1` | Group is active |

---

### 2.16 Challenge

**Table**: `tabChallenge`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `title` | Data | Yes | - | Challenge name |
| 2 | `description` | Text | No | - | Challenge description |
| 3 | `start_date` | Date | Yes | - | Challenge start |
| 4 | `end_date` | Date | Yes | - | Challenge end |
| 5 | `goal_type` | Select | No | - | `Skin`, `Hair`, `Lifestyle`, `General` |
| 6 | `goal_target` | Data | No | - | Specific goal (e.g., "Drink 8 cups water") |
| 7 | `reward` | Data | No | - | Completion reward description |
| 8 | `created_by` | Link (User) | Yes | - | Creator |
| 9 | `participants_count` | Int | No | `0` | Participant count |

---

### 2.17 Progress Entry

**Table**: `tabProgress Entry`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | User profile |
| 2 | `entry_date` | Date | No | `Today` | Entry date |
| 3 | `entry_type` | Select | Yes | - | `Skin`, `Hair`, `Lifestyle`, `General` |
| 4 | `score` | Float | Yes | - | Score (0-100) |
| 5 | `notes` | Text | No | - | User notes |
| 6 | `media` | Attach Image | No | - | Progress photo |

**Indexes**:
- Indexed: `user`, `entry_date`, `entry_type`

---

### 2.18 Subscription Plan

**Table**: `tabSubscription Plan`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `plan_name` | Data | Yes | - | `Free`, `Aura Plus`, `Aura Premium` |
| 2 | `description` | Text | No | - | Plan description |
| 3 | `price` | Currency | Yes | - | Price amount |
| 4 | `currency` | Data | No | `USD` | Currency code |
| 5 | `billing_cycle` | Select | Yes | - | `Monthly`, `Yearly` |
| 6 | `features` | Table | No | - | Feature list child table |
| 7 | `is_popular` | Check | No | `0` | Mark as popular choice |
| 8 | `is_active` | Check | No | `1` | Plan is available |

---

### 2.19 User Subscription

**Table**: `tabUser Subscription`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | User profile |
| 2 | `plan` | Link (Subscription Plan) | Yes | - | Subscribed plan |
| 3 | `status` | Select | No | `Active` | `Active`, `Cancelled`, `Expired`, `Pending` |
| 4 | `start_date` | Date | Yes | - | Subscription start |
| 5 | `end_date` | Date | Yes | - | Subscription end |
| 6 | `auto_renew` | Check | No | `1` | Auto-renewal enabled |
| 7 | `payment_provider` | Data | No | - | `Stripe`, `Apple Pay`, `Google Pay` |

---

### 2.20 AI Conversation

**Table**: `tabAI Conversation`

| # | Field Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `user` | Link (Beauty User Profile) | Yes | - | User profile |
| 2 | `messages` | JSON | No | - | Array of message objects |
| 3 | `started_at` | Datetime | No | `Now` | Conversation start |
| 4 | `last_message_at` | Datetime | No | - | Last activity |
| 5 | `message_count` | Int | No | `0` | Total messages |

---

## 3. Relationships Summary

| Source DocType | Relation | Target DocType | Via Field |
|---|---|---|---|
| Beauty User Profile | 1:1 | User (Frappe) | `user` |
| Beauty User Profile | 1:N | Skin Assessment | `user` |
| Beauty User Profile | 1:N | Hair Assessment | `user` |
| Beauty User Profile | 1:N | Lifestyle Assessment | `user` |
| Beauty User Profile | 1:N | User Routine | `user` |
| Beauty User Profile | 1:N | Progress Entry | `user` |
| Beauty User Profile | 1:N | Community Post | `user` |
| Beauty User Profile | 1:N | Recommendation Result | `user` |
| Beauty User Profile | 1:N | AI Conversation | `user` |
| Beauty User Profile | 1:N | User Subscription | `user` |
| Community Post | 1:N | Community Comment | `post` |
| Community Group | 1:N | Community Post | `group` |
| Subscription Plan | 1:N | User Subscription | `plan` |
| Beauty Product | M:N | Concern Tag | Product Concern (child) |
| Skin Assessment | M:N | Assessment Goal | `main_goals` (child) |
| Hair Assessment | M:N | Assessment Goal | `main_goals` (child) |

---

## 4. Indexes and Constraints

### Primary Indexes
- All DocTypes have auto-generated `name` as primary key
- `tabBeauty User Profile`: unique index on `user`
- `tabBeauty Product`: unique index on `product_name`

### Composite Indexes (recommended)
```sql
-- Progressive queries
CREATE INDEX idx_progress_user_date ON `tabProgress Entry`(user, entry_date);
CREATE INDEX idx_assessment_user_date ON `tabSkin Assessment`(user, assessment_date);
CREATE INDEX idx_posts_date ON `tabCommunity Post`(created_at DESC);
CREATE INDEX idx_products_category_active ON `tabBeauty Product`(category, is_active);
```

### Constraints
- `user` field in Beauty User Profile is unique (1:1 with Frappe User)
- `product_name` in Beauty Product is unique
- Price values are non-negative
- Score values are validated 0-100 in Python
- `routine_step` is constrained to predefined options

---

## 5. Data Flow Diagrams

### Assessment Data Flow
```
User Input → SkinAssessment Doc → Python validations → Save to DB
    ↓
Update BeautyUserProfile.skin_type
Update BeautyUserProfile.last_assessment_date
    ↓
Trigger: doc_events → on_profile_update → queue recommendation regen
    ↓
Daily Scheduler: regenerate_recommendations() → batch update scores
```

### Recommendation Data Flow
```
Recommendation Engine
    ↓
Fetch: User Profile (skin_type, hair_type, concerns)
Fetch: Latest Assessments (scores, goals)
Fetch: Active Products (catalog)
    ↓
Score each product against user profile:
  - Skin type compatibility
  - Concern match
  - Goal alignment
  - Ingredient compatibility
  - AI weight factor
    ↓
Sort by composite score → Top 20
    ↓
Save: RecommendationResult (cached, expires 24h)
    ↓
API: GET /recommendations → returns sorted list
```

### Community Interaction Data Flow
```
Create Post → CommunityPost → Update user's post count
    ↓
Add Comment → CommunityComment → Update post.comments_count
    ↓
Like Post → CommunityPost.likes_count +1
    ↓
Feed Generation: Query posts ordered by created_at DESC
    ↓
For You tab: posts from all groups, weighted by recency + engagement
Following tab: posts from user's joined groups only
```

---

## 6. Database Migration

### Adding a New Field
```bash
# Create a patch file
bench --site <sitename> console
# Then run:
bench --site <sitename> migrate
```

### Patch File Format (`patches.txt`)
```
aura.install.add_skin_type_index
aura.install.update_subscription_status
```

Frappe applies patches sequentially. Each patch is a Python function in `patches/` that runs during `bench migrate`.
