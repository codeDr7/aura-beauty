# Aura - Beauty Intelligence Platform: API Contracts

---

**Base URL**: `https://api.aurabeauty.ai`

**Content-Type**: `application/json`

**Authentication**: Bearer token via `Authorization: token <api_key>:<api_secret>` or Frappe cookie-based session.

---

## 1. Authentication APIs

### 1.1 Register

Creates a new user account and automatically creates a Beauty User Profile.

```
POST /api/method/aura.api.auth.register
```

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "email": "string (required, valid email)",
  "password": "string (required, min 8 chars)",
  "full_name": "string (required)",
  "age_range": "string (optional, one of: 18-24|25-34|35-44|45-54|55+)",
  "gender": "string (optional, one of: Female|Male|Non-Binary|Prefer not to say)"
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Account created successfully",
  "data": {
    "user": "string",
    "api_key": "string",
    "api_secret": "string",
    "profile_name": "string",
    "onboarding_completed": false
  }
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `USER_EXISTS` | Email already registered | 409 |
| `INVALID_EMAIL` | Invalid email format | 400 |
| `WEAK_PASSWORD` | Password too weak | 400 |
| `VALIDATION_ERROR` | Missing required fields | 400 |

**Authentication Required**: No

**Rate Limiting**: 5 requests per IP per minute

**Example**:
```bash
curl -X POST "https://api.aurabeauty.ai/api/method/aura.api.auth.register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sarah@example.com",
    "password": "SecurePass123!",
    "full_name": "Sarah Ahmed",
    "age_range": "25-34",
    "gender": "Female"
  }'
```

```json
{
  "message": "Account created successfully",
  "data": {
    "user": "sarah@example.com",
    "api_key": "4f8a3b2c1d",
    "api_secret": "e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0",
    "profile_name": "BUP-001",
    "onboarding_completed": false
  }
}
```

---

### 1.2 Login

Authenticates user and returns API credentials.

```
POST /api/method/aura.api.auth.login
```

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Login successful",
  "data": {
    "api_key": "string",
    "api_secret": "string",
    "user": "string",
    "full_name": "string",
    "profile_exists": "boolean",
    "onboarding_completed": "boolean",
    "subscription_status": "string (Free|Aura Plus|Aura Premium)"
  }
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `INVALID_CREDENTIALS` | Invalid email or password | 401 |
| `ACCOUNT_DISABLED` | Account has been disabled | 403 |
| `RATE_LIMITED` | Too many login attempts | 429 |

**Authentication Required**: No

**Rate Limiting**: 10 requests per IP per minute

**Example**:
```bash
curl -X POST "https://api.aurabeauty.ai/api/method/aura.api.auth.login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sarah@example.com",
    "password": "SecurePass123!"
  }'
```

```json
{
  "message": "Login successful",
  "data": {
    "api_key": "4f8a3b2c1d",
    "api_secret": "e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0",
    "user": "sarah@example.com",
    "full_name": "Sarah Ahmed",
    "profile_exists": true,
    "onboarding_completed": true,
    "subscription_status": "Free"
  }
}
```

---

### 1.3 Logout

Invalidates the current session.

```
POST /api/method/aura.api.auth.logout
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**: None

**Response Body (200 OK)**:
```json
{
  "message": "Logged out successfully"
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `INVALID_TOKEN` | Invalid or expired token | 401 |

**Authentication Required**: Yes

---

### 1.4 Reset Password

Sends password reset link to the registered email.

```
POST /api/method/aura.api.auth.reset_password
```

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "email": "string (required)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Password reset link sent to your email"
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `EMAIL_NOT_FOUND` | No account with this email | 404 |
| `RESET_FAILED` | Failed to send reset email | 500 |

**Authentication Required**: No

**Rate Limiting**: 3 requests per email per hour

---

## 2. User Profile APIs

### 2.1 Get Profile

Retrieves the authenticated user's beauty profile.

```
GET /api/method/aura.api.profile.get_profile
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
```

**Response Body (200 OK)**:
```json
{
  "message": "Profile retrieved",
  "data": {
    "name": "string (profile ID)",
    "user": "string",
    "full_name": "string",
    "age_range": "string",
    "gender": "string",
    "country": "string",
    "climate": "string",
    "skin_type": "string",
    "skin_sensitivity": "string",
    "hair_type": "string",
    "skin_score": "number (0-100)",
    "hair_score": "number (0-100)",
    "onboarding_completed": "boolean",
    "subscription_status": "string",
    "created_date": "string (date)",
    "last_assessment_date": "string (date)"
  }
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `NOT_FOUND` | Profile not found | 404 |
| `UNAUTHORIZED` | Invalid credentials | 401 |

**Authentication Required**: Yes

---

### 2.2 Update Profile

Updates specific fields of the user's profile.

```
PUT /api/method/aura.api.profile.update_profile
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "full_name": "string (optional)",
  "age_range": "string (optional, 18-24|25-34|35-44|45-54|55+)",
  "gender": "string (optional)",
  "country": "string (optional)",
  "climate": "string (optional, Tropical|Dry|Temperate|Continental|Polar)",
  "skin_type": "string (optional, Oily|Dry|Combination|Normal)",
  "skin_sensitivity": "string (optional, Low|Medium|High)",
  "hair_type": "string (optional, Straight|Wavy|Curly|Coily)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Profile updated successfully",
  "data": {
    "name": "string",
    "full_name": "string",
    "skin_type": "string"
  }
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `VALIDATION_ERROR` | Invalid field value | 400 |
| `NOT_FOUND` | Profile not found | 404 |

**Authentication Required**: Yes

---

## 3. Assessment APIs

### 3.1 Submit Skin Assessment

Submits a new skin assessment and triggers recommendation regeneration.

```
POST /api/method/aura.api.assessments.submit_skin
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "skin_type": "string (required, Oily|Dry|Combination|Normal)",
  "sensitivity": "string (optional, Low|Medium|High)",
  "acne_presence": "string (optional, None|Mild|Moderate|Severe)",
  "pigmentation": "string (optional, None|Low|Medium|High)",
  "dark_spots": "string (optional, None|Few|Moderate|Many)",
  "wrinkles": "string (optional, None|Fine|Moderate|Advanced)",
  "fine_lines": "string (optional, None|Few|Moderate|Many)",
  "pore_visibility": "string (optional, Minimal|Moderate|Visible|Large)",
  "redness": "string (optional, None|Low|Medium|High)",
  "hydration_level": "number (optional, 0-100)",
  "main_goals": ["string (optional, goal names)"]
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Skin assessment submitted",
  "data": {
    "name": "string (assessment ID: SKIN-0001)",
    "assessment_date": "string (date)",
    "overall_score": "number (0-100)",
    "main_goals": ["string"],
    "recommendations": "string"
  }
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `VALIDATION_ERROR` | Invalid data | 400 |
| `PROFILE_NOT_FOUND` | Beauty profile does not exist | 404 |

**Authentication Required**: Yes

**Example**:
```bash
curl -X POST "https://api.aurabeauty.ai/api/method/aura.api.assessments.submit_skin" \
  -H "Authorization: token 4f8a3b2c1d:e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0" \
  -H "Content-Type: application/json" \
  -d '{
    "skin_type": "Combination",
    "sensitivity": "Medium",
    "acne_presence": "Mild",
    "pigmentation": "Low",
    "hydration_level": 65,
    "main_goals": ["Reduce Acne", "Even Skin Tone"]
  }'
```

```json
{
  "message": "Skin assessment submitted",
  "data": {
    "name": "SKIN-0042",
    "assessment_date": "2025-06-25",
    "overall_score": 72,
    "main_goals": ["Reduce Acne", "Even Skin Tone"],
    "recommendations": "Focus on gentle cleansing, niacinamide serum for pore refinement, and lightweight moisturizer."
  }
}
```

---

### 3.2 Submit Hair Assessment

```
POST /api/method/aura.api.assessments.submit_hair
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "hair_type": "string (required, Straight|Wavy|Curly|Coily)",
  "hair_texture": "string (optional, Fine|Medium|Coarse)",
  "hair_thickness": "string (optional, Thin|Medium|Thick)",
  "hair_density": "string (optional, Low|Medium|High)",
  "scalp_condition": "string (optional, Normal|Dry|Oily|Sensitive|Dandruff)",
  "hair_loss": "string (optional, None|Mild|Moderate|Severe)",
  "dandruff": "string (optional, None|Mild|Moderate|Severe)",
  "dryness": "string (optional, None|Low|Medium|High)",
  "chemical_treatments": "string (optional, None|Occasional|Frequent)",
  "hair_damage": "string (optional, None|Low|Medium|High|Extreme)",
  "main_goals": ["string (optional)"]
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Hair assessment submitted",
  "data": {
    "name": "string (HAIR-####)",
    "assessment_date": "string (date)",
    "overall_score": "number (0-100)",
    "main_goals": ["string"],
    "recommendations": "string"
  }
}
```

**Authentication Required**: Yes

---

### 3.3 Submit Lifestyle Assessment

```
POST /api/method/aura.api.assessments.submit_lifestyle
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "sleep_quality": "string (optional, Poor|Fair|Good|Excellent)",
  "water_intake": "string (optional, Low|Medium|High)",
  "activity_level": "string (optional, Sedentary|Light|Moderate|Active)",
  "stress_level": "string (optional, Low|Medium|High)",
  "sun_exposure": "string (optional, Minimal|Moderate|Frequent)"
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Lifestyle assessment submitted",
  "data": {
    "name": "string (LIFE-####)",
    "assessment_date": "string (date)",
    "overall_score": "number (0-100)"
  }
}
```

**Authentication Required**: Yes

---

### 3.4 Get Assessment History

```
GET /api/method/aura.api.assessments.get_history?type=skin&limit=10&offset=0
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `type` | string | No | Filter by type: skin, hair, lifestyle |
| `limit` | integer | No | Results per page (default: 10, max: 50) |
| `offset` | integer | No | Pagination offset (default: 0) |

**Response Body (200 OK)**:
```json
{
  "message": "Assessment history retrieved",
  "data": {
    "assessments": [
      {
        "name": "string",
        "type": "string (skin|hair|lifestyle)",
        "assessment_date": "string (date)",
        "overall_score": "number",
        "main_goals": ["string"]
      }
    ],
    "total_count": "integer",
    "has_more": "boolean"
  }
}
```

**Authentication Required**: Yes

---

## 4. Product APIs

### 4.1 List Products

```
GET /api/method/aura.api.products.list?category=Skincare&limit=20&offset=0
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `category` | string | No | Filter: Skincare, Haircare, Body, Fragrance |
| `brand` | string | No | Filter by brand name |
| `routine_step` | string | No | Filter: Cleanser, Toner, Serum, Moisturizer, SPF, etc. |
| `min_price` | number | No | Minimum price filter |
| `max_price` | number | No | Maximum price filter |
| `featured` | boolean | No | Show featured only |
| `sort_by` | string | No | price_asc, price_desc, name, score |
| `limit` | integer | No | Default: 20 |
| `offset` | integer | No | Default: 0 |

**Response Body (200 OK)**:
```json
{
  "message": "Products retrieved",
  "data": {
    "products": [
      {
        "name": "string",
        "product_name": "string",
        "brand": "string",
        "description": "string",
        "price": "number",
        "category": "string",
        "routine_step": "string",
        "images": "string (URL)",
        "product_score": "number (0-100)",
        "is_featured": "boolean",
        "is_subscription_exclusive": "boolean",
        "skin_types": ["string"],
        "hair_types": ["string"],
        "concerns": ["string"],
        "ingredients": ["string"]
      }
    ],
    "total_count": "integer",
    "has_more": "boolean"
  }
}
```

**Authentication Required**: Yes

---

### 4.2 Get Product Detail

```
GET /api/method/aura.api.products.get?product_name=<name>
```

**Response Body (200 OK)**:
```json
{
  "message": "Product retrieved",
  "data": {
    "name": "string",
    "product_name": "string",
    "brand": "string",
    "description": "string",
    "price": "number",
    "category": "string",
    "routine_step": "string",
    "images": "string (URL)",
    "product_score": "number (0-100)",
    "is_featured": "boolean",
    "ai_weight": "number (0-1)",
    "skin_types": [
      {"goal_name": "string", "goal_type": "string"}
    ],
    "concerns": [
      {"concern": "string"}
    ],
    "ingredients": [
      {"ingredient": "string"}
    ]
  }
}
```

**Authentication Required**: Yes

---

### 4.3 Search Products

```
GET /api/method/aura.api.products.search?q=vitamin+c&category=Skincare
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `q` | string | Yes | Search query |
| `category` | string | No | Category filter |
| `limit` | integer | No | Default: 20 |

**Response Body (200 OK)**:
```json
{
  "message": "Search results",
  "data": {
    "products": [<Product Object>],
    "total_count": "integer"
  }
}
```

**Authentication Required**: Yes

---

## 5. Recommendation APIs

### 5.1 Get Recommendations

Retrieves personalized product recommendations for the user.

```
GET /api/method/aura.api.recommendations.get?type=skin&limit=10
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `type` | string | No | skin, hair, or all (default) |
| `limit` | integer | No | Number of results (default: 10, max: 30) |

**Response Body (200 OK)**:
```json
{
  "message": "Recommendations retrieved",
  "data": {
    "recommendations": [
      {
        "product": {
          "name": "string",
          "product_name": "string",
          "brand": "string",
          "price": "number",
          "category": "string",
          "routine_step": "string",
          "images": "string (URL)",
          "product_score": "number"
        },
        "match_score": "number (0-100)",
        "match_reasons": [
          "string (e.g., 'Matches your Combination skin type')",
          "string (e.g., 'Contains Niacinamide for acne concerns')"
        ],
        "rank": "integer"
      }
    ],
    "generated_date": "string (datetime)",
    "expires_in_hours": "integer"
  }
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `NO_ASSESSMENTS` | Complete assessments first | 400 |
| `RE_GENERATING` | Recommendations are being regenerated | 202 |
| `NOT_FOUND` | No recommendations available | 404 |

**Authentication Required**: Yes

---

### 5.2 Regenerate Recommendations

Triggers immediate recommendation regeneration.

```
POST /api/method/aura.api.recommendations.regenerate
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
```

**Response Body (202 Accepted)**:
```json
{
  "message": "Recommendation regeneration started",
  "data": {
    "estimated_completion_seconds": 30
  }
}
```

**Authentication Required**: Yes

**Rate Limiting**: 3 requests per user per hour

---

## 6. Routine APIs

### 6.1 Get User Routine

```
GET /api/method/aura.api.routines.get_routine?date=2025-06-25
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `date` | string | No | Date to get routine for (default: today) |

**Response Body (200 OK)**:
```json
{
  "message": "Routine retrieved",
  "data": {
    "name": "string",
    "user": "string",
    "date": "string (date)",
    "steps": [
      {
        "step_order": "integer",
        "time_of_day": "string (Morning|Evening|Weekly)",
        "product": {
          "name": "string",
          "product_name": "string",
          "brand": "string",
          "routine_step": "string"
        },
        "notes": "string",
        "completed": "boolean"
      }
    ],
    "completion_percentage": "number (0-100)"
  }
}
```

**Authentication Required**: Yes

---

### 6.2 Create Routine

Creates a new routine from a template or generated recommendations.

```
POST /api/method/aura.api.routines.create
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "name": "string (optional, routine name)",
  "template": "string (optional, template ID)",
  "from_recommendations": "boolean (optional, default: false)",
  "products": [
    {
      "product": "string (product name)",
      "time_of_day": "string (Morning|Evening|Weekly)",
      "step_order": "integer"
    }
  ]
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Routine created",
  "data": {
    "name": "string",
    "steps_count": "integer",
    "date": "string (date)"
  }
}
```

**Authentication Required**: Yes

---

### 6.3 Update Routine Step

Marks a routine step as completed or updates its details.

```
PUT /api/method/aura.api.routines.update_step
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "routine_name": "string (required)",
  "step_index": "integer (required)",
  "completed": "boolean (optional)",
  "notes": "string (optional)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Step updated",
  "data": {
    "completion_percentage": "number (0-100)"
  }
}
```

**Authentication Required**: Yes

---

## 7. Community APIs

### 7.1 Create Post

```
POST /api/method/aura.api.community.create_post
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "content": "string (required, max 2000 chars)",
  "media": "string (optional, image URL)",
  "post_type": "string (optional, general|progress|review|question, default: general)",
  "tags": ["string (optional)"],
  "group": "string (optional, group name)",
  "product": "string (optional, related product name)",
  "is_anonymous": "boolean (optional, default: false)"
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Post created",
  "data": {
    "name": "string",
    "content": "string",
    "user": "string",
    "created_at": "string (datetime)",
    "likes_count": 0,
    "comments_count": 0,
    "post_type": "string"
  }
}
```

**Authentication Required**: Yes

**Rate Limiting**: 10 posts per user per hour

---

### 7.2 Get Feed

```
GET /api/method/aura.api.community.get_feed?tab=for_you&limit=20&offset=0
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `tab` | string | No | for_you or following (default: for_you) |
| `group` | string | No | Filter by group |
| `post_type` | string | No | general, progress, review, question |
| `limit` | integer | No | Default: 20 |
| `offset` | integer | No | Default: 0 |

**Response Body (200 OK)**:
```json
{
  "message": "Feed retrieved",
  "data": {
    "posts": [
      {
        "name": "string",
        "user": "string",
        "user_full_name": "string",
        "content": "string",
        "media": "string (URL)",
        "post_type": "string",
        "tags": ["string"],
        "likes_count": "integer",
        "comments_count": "integer",
        "is_liked_by_user": "boolean",
        "created_at": "string (datetime)",
        "group_name": "string",
        "product_name": "string"
      }
    ],
    "total_count": "integer",
    "has_more": "boolean"
  }
}
```

**Authentication Required**: Yes

---

### 7.3 Add Comment

```
POST /api/method/aura.api.community.add_comment
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "post": "string (required, post name)",
  "content": "string (required, max 500 chars)"
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Comment added",
  "data": {
    "name": "string",
    "content": "string",
    "user": "string",
    "created_at": "string (datetime)"
  }
}
```

**Authentication Required**: Yes

---

### 7.4 Like/Unlike Post

```
POST /api/method/aura.api.community.like_post
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "post": "string (required, post name)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Post liked",
  "data": {
    "likes_count": "integer",
    "is_liked": "boolean"
  }
}
```

---

### 7.5 Get Groups

```
GET /api/method/aura.api.community.get_groups?limit=20&offset=0
```

**Response Body (200 OK)**:
```json
{
  "message": "Groups retrieved",
  "data": {
    "groups": [
      {
        "name": "string",
        "title": "string",
        "description": "string",
        "members_count": "integer",
        "posts_count": "integer",
        "cover_image": "string (URL)",
        "is_joined": "boolean"
      }
    ],
    "total_count": "integer",
    "has_more": "boolean"
  }
}
```

**Authentication Required**: Yes

---

### 7.6 Get Challenges

```
GET /api/method/aura.api.community.get_challenges?status=active&limit=10
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `status` | string | No | active, upcoming, completed (default: active) |

**Response Body (200 OK)**:
```json
{
  "message": "Challenges retrieved",
  "data": {
    "challenges": [
      {
        "name": "string",
        "title": "string",
        "description": "string",
        "start_date": "string (date)",
        "end_date": "string (date)",
        "goal_type": "string",
        "participants_count": "integer",
        "is_participating": "boolean",
        "reward": "string"
      }
    ],
    "total_count": "integer"
  }
}
```

**Authentication Required**: Yes

---

## 8. Progress Tracking APIs

### 8.1 Add Progress Entry

```
POST /api/method/aura.api.progress.add_entry
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "entry_type": "string (required, skin|hair|lifestyle|general)",
  "score": "number (required, 0-100)",
  "notes": "string (optional)",
  "media": "string (optional, progress photo URL)",
  "metadata": {
    "hydration_level": "number (optional)",
    "sleep_hours": "number (optional)",
    "water_cups": "number (optional)"
  }
}
```

**Response Body (201 Created)**:
```json
{
  "message": "Progress entry added",
  "data": {
    "name": "string",
    "entry_date": "string (date)",
    "score": "number",
    "entry_type": "string"
  }
}
```

**Authentication Required**: Yes

---

### 8.2 Get Progress History

```
GET /api/method/aura.api.progress.get_history?type=skin&from=2025-01-01&to=2025-06-25&limit=30
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `type` | string | No | skin, hair, lifestyle, general |
| `from` | string (date) | No | Start date |
| `to` | string (date) | No | End date |
| `limit` | integer | No | Default: 30 |

**Response Body (200 OK)**:
```json
{
  "message": "Progress history retrieved",
  "data": {
    "entries": [
      {
        "entry_date": "string (date)",
        "score": "number",
        "entry_type": "string",
        "notes": "string",
        "media": "string (URL)"
      }
    ],
    "trend": "string (improving|stable|declining)",
    "average_score": "number",
    "score_change": "number (change from first to last)"
  }
}
```

**Authentication Required**: Yes

---

### 8.3 Get Charts Data

```
GET /api/method/aura.api.progress.get_charts?period=month&type=skin
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `period` | string | No | week, month, quarter, year (default: month) |
| `type` | string | No | skin, hair, lifestyle, all (default: all) |

**Response Body (200 OK)**:
```json
{
  "message": "Charts data retrieved",
  "data": {
    "charts": {
      "skin_scores": {
        "labels": ["string (dates)"],
        "datasets": [
          {
            "label": "Overall Score",
            "data": ["number"]
          }
        ]
      },
      "breakdown": {
        "acne": ["number"],
        "hydration": ["number"],
        "pigmentation": ["number"]
      }
    },
    "insights": [
      "string (e.g., 'Your skin hydration improved 15% this month')"
    ]
  }
}
```

**Authentication Required**: Yes

---

## 9. Subscription APIs

### 9.1 Get Plans

```
GET /api/method/aura.api.subscriptions.get_plans
```

**Response Body (200 OK)**:
```json
{
  "message": "Plans retrieved",
  "data": {
    "plans": [
      {
        "name": "string",
        "plan_name": "string",
        "description": "string",
        "price": "number",
        "currency": "string (USD)",
        "billing_cycle": "string (Monthly|Yearly)",
        "features": ["string"],
        "is_popular": "boolean",
        "is_active": "boolean"
      }
    ]
  }
}
```

**Authentication Required**: Yes

---

### 9.2 Subscribe

```
POST /api/method/aura.api.subscriptions.subscribe
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "plan": "string (required, plan name)",
  "billing_cycle": "string (required, Monthly|Yearly)",
  "payment_method": "string (required, stripe|apple_pay|google_pay)",
  "payment_token": "string (required, token from payment processor)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Subscription activated",
  "data": {
    "subscription_id": "string",
    "plan_name": "string",
    "status": "string (Active)",
    "start_date": "string (date)",
    "end_date": "string (date)",
    "auto_renew": "boolean"
  }
}
```

**Authentication Required**: Yes

---

### 9.3 Cancel Subscription

```
POST /api/method/aura.api.subscriptions.cancel
```

**Request Body**:
```json
{
  "reason": "string (optional)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Subscription will end on <end_date>",
  "data": {
    "status": "string (Cancelled)",
    "end_date": "string (date)"
  }
}
```

**Authentication Required**: Yes

---

### 9.4 Get Subscription Status

```
GET /api/method/aura.api.subscriptions.get_status
```

**Response Body (200 OK)**:
```json
{
  "message": "Subscription status retrieved",
  "data": {
    "status": "string (Free|Aura Plus|Aura Premium|Cancelled|Expired)",
    "plan_name": "string",
    "start_date": "string (date)",
    "end_date": "string (date)",
    "auto_renew": "boolean",
    "days_remaining": "integer",
    "features": ["string"]
  }
}
```

**Authentication Required**: Yes

---

## 10. AI Coach APIs

### 10.1 Send Message

Sends a message to the AI Beauty Coach and gets a response.

```
POST /api/method/aura.api.ai_coach.send_message
```

**Request Headers**:
```
Authorization: token <api_key>:<api_secret>
Content-Type: application/json
```

**Request Body**:
```json
{
  "message": "string (required, max 1000 chars)",
  "context": "string (optional, skin|hair|lifestyle|routine|product|general, default: general)"
}
```

**Response Body (200 OK)**:
```json
{
  "message": "Response received",
  "data": {
    "user_message": {
      "content": "string",
      "timestamp": "string (datetime)"
    },
    "coach_response": {
      "content": "string",
      "timestamp": "string (datetime)",
      "recommended_products": [
        {
          "product_name": "string",
          "reason": "string"
        }
      ],
      "tips": ["string"]
    },
    "conversation_id": "string"
  }
}
```

**Error Codes**:
| Code | Message | HTTP Status |
|---|---|---|
| `QUOTA_EXCEEDED` | Daily AI message limit reached | 429 |
| `PREMIUM_FEATURE` | AI Coach requires Aura Plus | 403 |
| `CONTENT_FILTERED` | Message violates guidelines | 400 |

**Authentication Required**: Yes

**Rate Limiting**: Free: 10 messages/day | Aura Plus: 50 messages/day | Premium: 200 messages/day

**Example**:
```bash
curl -X POST "https://api.aurabeauty.ai/api/method/aura.api.ai_coach.send_message" \
  -H "Authorization: token 4f8a3b2c1d:e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What night serum would you recommend for combination skin with hyperpigmentation?",
    "context": "skin"
  }'
```

```json
{
  "message": "Response received",
  "data": {
    "user_message": {
      "content": "What night serum would you recommend for combination skin with hyperpigmentation?",
      "timestamp": "2025-06-25T14:30:00Z"
    },
    "coach_response": {
      "content": "For combination skin with hyperpigmentation, I recommend a Vitamin C serum in the morning and a Niacinamide + Tranexamic Acid serum at night. These ingredients work synergistically to brighten dark spots while balancing your combination skin.",
      "timestamp": "2025-06-25T14:30:02Z",
      "recommended_products": [
        {
          "product_name": "Brightening Niacinamide Serum",
          "reason": "Contains 10% Niacinamide + Tranexamic Acid for hyperpigmentation"
        },
        {
          "product_name": "Vitamin C Brightening Cream",
          "reason": "L-ascorbic acid for antioxidant protection and brightening"
        }
      ],
      "tips": [
        "Always wear SPF when using brightening ingredients",
        "Start with every other night to build tolerance",
        "Apply serum to damp skin for better absorption"
      ]
    },
    "conversation_id": "AIC-0042"
  }
}
```

---

### 10.2 Get Conversation History

```
GET /api/method/aura.api.ai_coach.get_conversation?conversation_id=AIC-0042
```

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `conversation_id` | string | No | Specific conversation (default: latest) |
| `limit` | integer | No | Messages per page (default: 50) |

**Response Body (200 OK)**:
```json
{
  "message": "Conversation retrieved",
  "data": {
    "conversation_id": "string",
    "messages": [
      {
        "role": "string (user|coach)",
        "content": "string",
        "timestamp": "string (datetime)"
      }
    ],
    "total_messages": "integer",
    "has_more": "boolean"
  }
}
```

**Authentication Required**: Yes

---

### 10.3 Clear Chat History

```
DELETE /api/method/aura.api.ai_coach.clear_chat
```

**Response Body (200 OK)**:
```json
{
  "message": "Chat history cleared"
}
```

**Authentication Required**: Yes
