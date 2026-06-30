# Aura Beauty Intelligence — Complete API Reference

Base URL: `http://102.213.180.186:8000`
Host header: `aura-beauty.erpnext.local`
Auth: `token <api_key>:<api_secret>`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Error Handling](#2-error-handling)
3. [Data Models](#3-data-models)
4. [API Endpoints](#4-api-endpoints)
5. [Standard REST Endpoints](#5-standard-rest-endpoints)
6. [Pagination, Sorting & Filtering](#6-pagination-sorting--filtering)

---

## 1. Authentication

ERPNext/Frappe supports two authentication mechanisms.

### 1.1 Token-Based Authentication (Preferred)

Send `Authorization: token <api_key>:<api_secret>` on every request.

```
Authorization: token 6fbac06ac30fcf9b2584:49da51bef74e34bf6a068ecca16b2763233f8cae
```

Every **User** in ERPNext can have an `api_key` and `api_secret`. The secret is hashed with SHA-256 and verified server-side. No session cookies needed — ideal for mobile apps.

**Admin** can generate keys for any user:

```http
POST /api/resource/User/{email}
Host: aura-beauty.erpnext.local
Authorization: token <admin-api-key>:<admin-api-secret>
Content-Type: application/json

{"api_key": "newkey123", "api_secret": "newsecret456"}
```

Or programmatically:

```python
user = frappe.get_doc("User", email)
user.api_key = frappe.generate_hash(length=20)
user.api_secret = frappe.generate_hash(length=40)
user.save(ignore_permissions=True)
frappe.db.commit()
```

**Security:** Keep `api_secret` on device keychain — never log it. Rotate keys periodically.

### 1.2 Session-Based Authentication (Cookie)

Used only for web login flows. Not recommended for mobile.

```http
POST /api/method/login
Host: aura-beauty.erpnext.local
Content-Type: application/json

{"usr": "email@example.com", "pwd": "password"}
```

```json
{
  "message": "Logged In",
  "home_page": "/me",
  "full_name": "Jane Doe"
}
```

A session cookie (`sid`) is set. Include it on subsequent requests. Website Users (created via `register`) receive `"No App"` as `home_page` — this is normal.

To log out:

```http
POST /api/method/logout
Host: aura-beauty.erpnext.local
```

### 1.3 Google Login (OAuth)

```http
POST /api/method/aura.api.auth.google_login
Host: aura-beauty.erpnext.local
Content-Type: application/json

{"token": "<google-id-token>"}
```

The backend validates the token with Google's `tokeninfo` endpoint, creates the User and Beauty User Profile if new, then logs the user in.

```json
{
  "message": "Login successful",
  "user": "user@gmail.com",
  "full_name": "Jane Doe"
}
```

A session cookie is set.

### 1.4 Registration (New User)

Creates both a Frappe **User** and a **Beauty User Profile** in one call.

```http
POST /api/method/aura.api.auth.register
Host: aura-beauty.erpnext.local
Content-Type: application/json

{
  "email": "jane@example.com",
  "password": "Str0ng!Pass#2026",
  "first_name": "Jane",
  "last_name": "Doe"
}
```

**Field reference:**

| Field | Type | Required | Notes |
|---|---|---|---|
| `email` | string | Yes | Unique |
| `password` | string | Yes | Min 8 chars, uppercase, lowercase, digit |
| `full_name` | string | No | Alternative to first_name+last_name |
| `first_name` | string | No | Concatenated with last_name if full_name not given |
| `last_name` | string | No | |

Success:

```json
{
  "message": "Registration successful",
  "user": "jane@example.com"
}
```

The user is assigned the **Customer** role.

### 1.5 Partner Authentication (Marketplace)

Partners authenticate with their own API key/secret sent as custom headers:

```
X-API-Key: <partner-api-key>
X-API-Secret: <partner-api-secret>
```

These are issued at partner registration time and stored on the **Marketplace Partner** doctype. They are separate from Frappe User tokens.

| Endpoint | Auth |
|---|---|
| `partner_register` | Guest (allow_guest) |
| `partner_get_orders` | Partner API headers |
| `partner_update_order_status` | Partner API headers |

### 1.6 Authentication Flow (Flutter)

```
1. Check if user has stored api_key/api_secret
   ├── YES → Use token auth on every request
   └── NO  →
        a. Show Login/Register screen
        b. On success, call backend to generate api_key/api_secret
        c. Persist to secure storage
        d. Use token auth from then on
```

**Recommended Flutter package:** `dio` with an interceptor that attaches the `Authorization` header.

---

## 2. Error Handling

### 2.1 Error Response Format

All errors follow a consistent JSON structure:

```json
{
  "exception": "<ExceptionType>",
  "exc_type": "<PythonExceptionClass>",
  "_exc_source": "aura (app)",
  "exc": ["<full-traceback-array>"],
  "_server_messages": "[\"{\\\"message\\\": \\\"Human-readable error\\\", \\\"title\\\": \\\"Message\\\", \\\"indicator\\\": \\\"red\\\", \\\"raise_exception\\\": 1}\"]",
  "http_status_code": 400
}
```

When possible, parse `_server_messages` (JSON-encoded array) to extract the user-facing `message`.

### 2.2 HTTP Status Codes

| Code | Meaning | When |
|---|---|---|
| **200** | OK | Success response |
| **400** | Bad Request | Missing or invalid parameters |
| **403** | Forbidden | Authentication failure or permission denied |
| **404** | Not Found | Resource does not exist |
| **409** | Conflict | Duplicate entry (e.g. email already registered) |
| **500** | Internal Server Error | Unexpected server error |

### 2.3 Error Types by Endpoint

#### Authentication (`aura.api.auth.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.AuthenticationError` | 403 | Wrong email or password |
| `frappe.exceptions.ValidationError: Email already registered` | 400 | Duplicate registration |
| `frappe.exceptions.AuthenticationError: Invalid API credentials` | 403 | Wrong partner X-API-Key/Secret |
| `frappe.exceptions.ValidationError: Profile not found` | 400 | Session user has no Beauty User Profile |

#### Profile (`aura.api.profile.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.ValidationError: Profile not found` | 400 | Session user has no Beauty User Profile |
| `frappe.exceptions.ValidationError: Hair Type cannot be "X"` | 400 | Value not in allowed select options |
| `frappe.exceptions.ValidationError: Skin Type cannot be "X"` | 400 | Value not in allowed select options |

#### Products (`aura.api.products.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.ValidationError: Query must be at least 2 characters` | 400 | Search query too short |
| `frappe.exceptions.DoesNotExistError` | 404 | Product not found by name |
| `frappe.exceptions.ValidationError: Profile not found` | 400 | No profile for session user |

#### Assessments (`aura.api.assessments.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.ValidationError: Invalid assessment type` | 400 | Must be "skin", "hair", or "lifestyle" |

#### Marketplace (`aura.api.marketplace.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.ValidationError: This product is not available for ordering` | 400 | Product has no partner assigned |
| `frappe.exceptions.AuthenticationError: Invalid API credentials` | 403 | Missing/wrong X-API-Key/Secret headers |
| `frappe.exceptions.ValidationError: Order does not belong to this partner` | 400 | Partner mismatch |
| `frappe.exceptions.ValidationError: Invalid status. Valid: ...` | 400 | Status not in allowed list |
| `frappe.exceptions.ValidationError: company_name is required` | 400 | Missing required field |

#### Subscriptions (`aura.api.subscriptions.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.ValidationError: No active subscription` | 400 | No active subscription to cancel |
| `frappe.exceptions.ValidationError: Profile not found` | 400 | No profile for session user |

#### Community (`aura.api.community.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.ValidationError: Profile not found` | 400 | No profile for session user |

#### Routines (`aura.api.routines.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.DoesNotExistError` | 404 | Routine template not found |

#### AI Coach (`aura.api.ai_coach.*`)

| Error | HTTP | Cause |
|---|---|---|
| `frappe.exceptions.ValidationError: Profile not found` | 400 | No profile for session user |

### 2.4 ERPNext Standard Errors

| Error | Cause |
|---|---|
| `frappe.exceptions.ValidationError` | Generic validation failure (check `_server_messages`) |
| `frappe.exceptions.PermissionError` | User lacks required role |
| `frappe.exceptions.DoesNotExistError` | Document not found |
| `frappe.exceptions.MandatoryError` | Required field missing |
| `frappe.exceptions.LinkValidationError` | Linked document does not exist |

### 2.5 Validation Error Detail

Select-field validation fails with the allowed values in the message:

```json
{
  "exception": "frappe.exceptions.ValidationError: Hair Type cannot be \"Normal\". It should be one of \"Straight\", \"Wavy\", \"Curly\", \"Coily\""
}
```

### 2.6 Best Practices for Error Handling

1. Always parse `_server_messages` first — it contains the user-friendly message.
2. Fall back to `exception` for developer debugging.
3. On HTTP 403, redirect to login.
4. On HTTP 400 with `"Profile not found"`, redirect to registration completion.
5. On HTTP 500, log the full response and show a generic error.

---

## 3. Data Models

All API responses wrap data in a `message` envelope. REST resource endpoints wrap in `data`.

### 3.1 Beauty User Profile

**DocType:** `Beauty User Profile` | **Autoname:** `field:user` | **Track Changes:** Yes

```json
{
  "name": "user@example.com",
  "full_name": "Jane Doe",
  "age_range": "25-34",
  "gender": "Female",
  "country": "US",
  "date_of_birth": "1995-06-15",
  "climate": "Tropical",
  "skin_type": "Combination",
  "skin_sensitivity": "Medium",
  "skin_score": 7,
  "hair_type": "Curly",
  "hair_score": 6,
  "overall_beauty_score": 6,
  "subscription_status": "Free",
  "hydration_level": 65,
  "barrier_health": 70,
  "created_date": "2026-01-15",
  "last_active_date": "2026-06-29T12:00:00.000000",
  "goals": [],
  "profile_snapshots": []
}
```

| Field | Type | Nullable | Default | Options |
|---|---|---|---|---|
| `name` | string | No | — | Email (from User link) |
| `full_name` | string | No | — | |
| `age_range` | string | Yes | — | `18-24`, `25-34`, `35-44`, `45-54`, `55+` |
| `gender` | string | Yes | — | `Female`, `Male`, `Non-binary`, `Prefer not to say` |
| `country` | string | Yes | — | |
| `date_of_birth` | string (date) | Yes | — | `YYYY-MM-DD` |
| `climate` | string | Yes | — | `Tropical`, `Dry`, `Temperate`, `Continental`, `Polar` |
| `skin_type` | string | Yes | — | `Oily`, `Dry`, `Combination`, `Normal`, `Sensitive` |
| `skin_sensitivity` | string | Yes | — | `Low`, `Medium`, `High` |
| `skin_score` | integer | Yes | — | 0–10 |
| `hair_type` | string | Yes | — | `Straight`, `Wavy`, `Curly`, `Coily` |
| `hair_score` | integer | Yes | — | 0–10 |
| `overall_beauty_score` | integer | Yes | — | 0–10 |
| `subscription_status` | string | No | `Free` | `Free`, `Basic`, `Premium`, `Enterprise` |
| `hydration_level` | integer | Yes | — | 0–100 |
| `barrier_health` | integer | Yes | — | 0–100 |
| `created_date` | string (date) | Yes | — | |
| `last_active_date` | string (datetime) | Yes | — | |
| `goals` | array | — | `[]` | Array of Beauty Goal |
| `profile_snapshots` | array | — | `[]` | Array of Profile Snapshot |

**Relationships:**

| Child Table | Via Field | Type |
|---|---|---|
| Beauty Goal | `goals` | Table (inline child) |
| Profile Snapshot | `profile_snapshots` | Table (inline child) |

---

### 3.2 Beauty Goal (Child Table)

**DocType:** `Beauty Goal` | **Child of:** Beauty User Profile

```json
{
  "goal": "Acne",
  "is_primary": 1,
  "target_date": "2026-09-01",
  "progress_percent": 40,
  "status": "Active"
}
```

| Field | Type | Options |
|---|---|---|
| `goal` | Link → Concern Tag | |
| `is_primary` | boolean | 0/1 |
| `target_date` | string (date) | |
| `progress_percent` | integer | 0–100 |
| `status` | string | `Active`, `Completed`, `At Risk`, `Paused` |

---

### 3.3 Profile Snapshot (Child Table)

**DocType:** `Profile Snapshot` | **Child of:** Beauty User Profile

```json
{
  "snapshot_date": "2026-06-29T12:00:00.000000",
  "field_name": "skin_score",
  "previous_value": "5",
  "new_value": "7",
  "change_reason": "Assessment",
  "action_type": "Assessment"
}
```

| Field | Type | Options |
|---|---|---|
| `snapshot_date` | string (datetime) | |
| `field_name` | string | |
| `previous_value` | string | |
| `new_value` | string | |
| `change_reason` | string | |
| `action_type` | string | `Assessment`, `Diary Entry`, `Routine Complete`, `System`, `Manual` |

---

### 3.4 Beauty Product

**DocType:** `Beauty Product` | **Autoname:** `field:product_name`

```json
{
  "name": "PRD-001",
  "product_name": "Hydrating Serum",
  "brand": "GlowLab",
  "partner": "PARTNER-001",
  "description": "<p>Lightweight serum for daily hydration</p>",
  "price": 34.99,
  "category": "Skincare",
  "routine_step": "Treat",
  "ai_weight": 1.5,
  "product_score": 88.5,
  "is_featured": 1,
  "is_active": 1,
  "skin_types": ["Dry", "Combination"],
  "hair_types": [],
  "concerns": ["Dryness", "Aging"],
  "ingredients": ["Hyaluronic Acid", "Vitamin C"]
}
```

| Field | Type | Required | Options |
|---|---|---|---|
| `name` | string | Auto | |
| `product_name` | string | Yes | Unique |
| `brand` | string | Yes | |
| `partner` | Link → Marketplace Partner | No | |
| `description` | string (HTML) | No | |
| `price` | number | No | |
| `category` | string | Yes | `Skincare`, `Haircare`, `Body`, `Fragrance` |
| `routine_step` | string | No | `Cleanse`, `Tone`, `Treat`, `Moisturize`, `Protect`, `Other` |
| `ai_weight` | number | No | |
| `product_score` | number | No | 0–100 |
| `is_featured` | boolean | No | |
| `is_active` | boolean | No | Default: 1 |
| `skin_types` | array | — | Strings: `Oily`, `Dry`, `Combination`, `Normal`, `Sensitive` |
| `hair_types` | array | — | Strings: `Straight`, `Wavy`, `Curly`, `Coily` |
| `concerns` | array | — | Strings (concern names) |
| `ingredients` | array | — | Strings (ingredient names) |

---

### 3.5 Skin Assessment

**DocType:** `Skin Assessment`

```json
{
  "name": "ASM-001",
  "user": "user@example.com",
  "assessment_date": "2026-06-29T12:00:00.000000",
  "skin_type": "Combination",
  "skin_sensitivity": "Medium",
  "concerns": [],
  "overall_score": 7
}
```

| Field | Type | Options |
|---|---|---|
| `user` | Link → Beauty User Profile | |
| `assessment_date` | string (datetime) | |
| `skin_type` | string | `Oily`, `Dry`, `Combination`, `Normal`, `Sensitive` |
| `skin_sensitivity` | string | `Low`, `Medium`, `High` |
| `concerns` | array (Table MultiSelect) | |
| `overall_score` | integer | 0–10 |

---

### 3.6 Hair Assessment

**DocType:** `Hair Assessment`

```json
{
  "name": "ASM-002",
  "user": "user@example.com",
  "assessment_date": "2026-06-29T12:00:00.000000",
  "hair_type": "Curly",
  "hair_density": "Medium",
  "scalp_condition": "Normal",
  "overall_score": 8
}
```

| Field | Type | Options |
|---|---|---|
| `user` | Link → Beauty User Profile | |
| `assessment_date` | string (datetime) | |
| `hair_type` | string | `Straight`, `Wavy`, `Curly`, `Coily` |
| `hair_density` | string | `Low`, `Medium`, `High` |
| `scalp_condition` | string | `Normal`, `Dry`, `Oily`, `Sensitive`, `Dandruff` |
| `overall_score` | integer | 0–10 |

---

### 3.7 Lifestyle Assessment

**DocType:** `Lifestyle Assessment`

```json
{
  "name": "ASM-003",
  "user": "user@example.com",
  "assessment_date": "2026-06-29T12:00:00.000000",
  "sleep_quality": "Good",
  "stress_level": "Medium",
  "diet_quality": "Good",
  "overall_score": 7
}
```

| Field | Type | Options |
|---|---|---|
| `user` | Link → Beauty User Profile | |
| `assessment_date` | string (datetime) | |
| `sleep_quality` | string | `Poor`, `Fair`, `Good`, `Excellent` |
| `stress_level` | string | `Low`, `Medium`, `High` |
| `diet_quality` | string | `Poor`, `Fair`, `Good`, `Excellent` |
| `overall_score` | integer | 0–10 |

---

### 3.8 Recommendation Result

**DocType:** `Recommendation Result`

```json
{
  "name": "REC-001",
  "user": "user@example.com",
  "confidence_score": 0.75,
  "reasoning": "Generated based on profile goals and product scores",
  "generated_date": "2026-06-29T12:00:00.000000",
  "expires_date": "2026-07-29",
  "products": [
    {
      "product_name": "Hydrating Serum",
      "brand": "GlowLab",
      "price": 34.99,
      "category": "Skincare",
      "confidence": 0.88,
      "reason": "Top rated product"
    }
  ]
}
```

| Field | Type | Notes |
|---|---|---|
| `user` | Link → Beauty User Profile | |
| `confidence_score` | number | 0–1 |
| `reasoning` | string | |
| `generated_date` | string (datetime) | |
| `expires_date` | string (date) | Optional |
| `products` | array | Array of Recommended Product |

---

### 3.9 Recommended Product (Child Table)

**DocType:** `Recommended Product`

```json
{
  "product": "PRD-001",
  "confidence": 0.88,
  "reason": "Top rated product"
}
```

| Field | Type |
|---|---|
| `product` | Link → Beauty Product |
| `confidence` | number (0–1) |
| `reason` | string |

---

### 3.10 Aura Subscription Plan

**DocType:** `Aura Subscription Plan` | **Autoname:** `field:plan_name`

```json
{
  "name": "Premium",
  "plan_name": "Premium",
  "plan_type": "Premium",
  "price_monthly": 19.99,
  "price_yearly": 199.99,
  "is_active": 1,
  "features": ["AI Coach Access", "Advanced Analytics"]
}
```

| Field | Type | Options |
|---|---|---|
| `plan_name` | string | Unique |
| `plan_type` | string | `Free`, `Basic`, `Premium`, `Enterprise` |
| `price_monthly` | number | |
| `price_yearly` | number | |
| `is_active` | boolean | Default: 1 |
| `features` | array | Strings (Plan Feature child table) |

---

### 3.11 User Subscription

**DocType:** `User Subscription`

```json
{
  "name": "SUB-001",
  "user": "user@example.com",
  "plan": "Premium",
  "start_date": "2026-06-01",
  "end_date": "2026-07-01",
  "is_active": 1,
  "auto_renew": 1,
  "subscription_type": "Monthly"
}
```

| Field | Type | Options |
|---|---|---|
| `user` | Link → Beauty User Profile | |
| `plan` | Link → Aura Subscription Plan | |
| `start_date` | string (date) | |
| `end_date` | string (date) | |
| `is_active` | boolean | Default: 1 |
| `auto_renew` | boolean | Default: 1 |
| `subscription_type` | string | `Monthly`, `Yearly` |

---

### 3.12 Marketplace Order

**DocType:** `Marketplace Order`

```json
{
  "name": "ORD-001",
  "partner": "PARTNER-001",
  "user": "user@example.com",
  "total_price": 69.98,
  "order_status": "Pending",
  "payment_status": "Pending",
  "invoice_url": null,
  "ordered_date": "2026-06-29T12:00:00.000000",
  "delivery_address": null,
  "items": [
    {
      "product": "PRD-001",
      "quantity": 2,
      "unit_price": 34.99,
      "total": 69.98
    }
  ]
}
```

| Field | Type | Options |
|---|---|---|
| `partner` | Link → Marketplace Partner | |
| `user` | Link → Beauty User Profile | |
| `total_price` | number | |
| `order_status` | string | `Pending`, `Confirmed`, `Processing`, `Shipped`, `Delivered`, `Cancelled` |
| `payment_status` | string | `Pending`, `Paid`, `Refunded` |
| `invoice_url` | string | |
| `ordered_date` | string (datetime) | |
| `delivery_address` | string | |
| `items` | array | Array of Marketplace Order Item |

---

### 3.13 Marketplace Order Item (Child Table)

**DocType:** `Marketplace Order Item`

```json
{
  "product": "PRD-001",
  "quantity": 2,
  "unit_price": 34.99,
  "total": 69.98
}
```

| Field | Type |
|---|---|
| `product` | Link → Beauty Product |
| `quantity` | integer |
| `unit_price` | number |
| `total` | number |

---

### 3.14 Marketplace Partner

**DocType:** `Marketplace Partner` | **Autoname:** `field:company_name`

```json
{
  "name": "GlowLab Inc.",
  "company_name": "GlowLab Inc.",
  "contact_email": "partner@glowlab.com",
  "contact_person": "Jane Doe",
  "api_key": "abc123...",
  "api_secret": "***",
  "webhook_url": "https://glowlab.com/webhook",
  "commission_percent": 15,
  "is_active": 1,
  "integration_type": "Shopify",
  "status": "Active"
}
```

| Field | Type | Options |
|---|---|---|
| `company_name` | string | Unique |
| `contact_email` | string | |
| `contact_person` | string | |
| `api_key` | string | Generated |
| `api_secret` | string (password) | Generated, masked in API |
| `webhook_url` | string | |
| `commission_percent` | integer | 0–100 |
| `is_active` | boolean | Default: 1 |
| `integration_type` | string | `ERPNext`, `Odoo`, `Shopify`, `Custom API`, `Manual` |
| `status` | string | `Active`, `Suspended`, `Pending` |

---

### 3.15 Community Post

**DocType:** `Community Post`

```json
{
  "name": "POST-001",
  "title": "My skincare journey",
  "content": "<p>Story content here...</p>",
  "author": "user@example.com",
  "group": "GROUP-001",
  "likes": 5,
  "tags": "skincare,routine",
  "image": "/files/photo.jpg"
}
```

| Field | Type | Notes |
|---|---|---|
| `title` | string | |
| `content` | string (HTML) | |
| `author` | Link → Beauty User Profile | |
| `group` | Link → Community Group | |
| `likes` | integer | |
| `tags` | string | Comma-separated |
| `image` | string (URL) | Attached image |

**Feed response adds:**

| Field | Type | Notes |
|---|---|---|
| `author_name` | string | Resolved from author profile |
| `comment_count` | integer | Count of comments |

---

### 3.16 Community Comment

**DocType:** `Community Comment`

```json
{
  "name": "CMT-001",
  "post": "POST-001",
  "author": "user@example.com",
  "content": "Great progress!",
  "parent_comment": null
}
```

---

### 3.17 Community Group

**DocType:** `Community Group` | **Autoname:** `field:group_name`

```json
{
  "name": "GROUP-001",
  "group_name": "Skincare Enthusiasts",
  "description": "For anyone passionate about skincare",
  "members_count": 150,
  "is_public": 1,
  "created_by": "user@example.com"
}
```

---

### 3.18 User Routine

**DocType:** `User Routine`

```json
{
  "name": "RTN-001",
  "user": "user@example.com",
  "routine_template": "TMPL-001",
  "is_active": 1,
  "start_date": "2026-06-01",
  "progress_percent": 60.0,
  "steps": [
    {
      "step_name": "Cleanse",
      "step_number": 1,
      "duration_minutes": 2,
      "is_completed": 1,
      "completed_date": "2026-06-29T08:00:00.000000",
      "product": "PRD-001"
    }
  ]
}
```

---

### 3.19 Routine Template

**DocType:** `Routine Template` | **Autoname:** `field:template_name`

```json
{
  "name": "TMPL-001",
  "template_name": "30-Day Glow Up",
  "description": "A complete 30-day skincare transformation",
  "is_active": 1,
  "steps": [
    {
      "step_name": "Cleanse",
      "step_number": 1,
      "duration_minutes": 2,
      "description": "Use a gentle cleanser",
      "product_category": "Skincare"
    }
  ]
}
```

---

### 3.20 Progress Entry

**DocType:** `Progress Entry`

```json
{
  "name": "PRG-001",
  "user": "user@example.com",
  "entry_date": "2026-06-29",
  "entry_type": "Diary",
  "value": 7,
  "notes": "Skin feels hydrated today",
  "image": null
}
```

| Field | Type | Options |
|---|---|---|
| `entry_type` | string | `Assessment`, `Diary`, `Routine`, `Photo`, `Note` |
| `value` | integer | |
| `notes` | string | |
| `image` | string (URL) | |

---

### 3.21 Concern Tag

**DocType:** `Concern Tag` | **Autoname:** `field:concern_name`

```json
{
  "name": "Acne",
  "concern_name": "Acne",
  "category": "Skin"
}
```

| Field | Type | Options |
|---|---|---|
| `concern_name` | string | Unique |
| `category` | string | `Skin`, `Hair`, `Lifestyle`, `Environment` |

---

### 3.22 Achievement Badge

**DocType:** `Achievement Badge` | **Autoname:** `field:badge_name`

```json
{
  "name": "BDG-001",
  "badge_name": "Early Adopter",
  "icon": "star",
  "description": "Joined Aura in the first month",
  "criteria": "Register in the first 30 days",
  "points": 50
}
```

---

### 3.23 User Badge

**DocType:** `User Badge`

```json
{
  "badge": "BDG-001",
  "earned_date": "2026-06-15",
  "badge_name": "Early Adopter",
  "icon": "star",
  "description": "Joined Aura in the first month",
  "points": 50
}
```

---

### 3.24 Product Ingredient

**DocType:** `Product Ingredient` | **Autoname:** `field:ingredient_name`

```json
{
  "name": "ING-001",
  "ingredient_name": "Hyaluronic Acid",
  "description": "A humectant that holds 1000x its weight in water",
  "benefits": "Deep hydration, plumping effect"
}
```

---

### 3.25 Ingredient Conflict

**DocType:** `Ingredient Conflict`

```json
{
  "name": "CONF-001",
  "ingredient_a": "ING-001",
  "ingredient_b": "ING-002",
  "severity": "High",
  "description": "Can cause irritation when used together",
  "ingredient_a_name": "Retinol",
  "ingredient_b_name": "Vitamin C"
}
```

| Field | Type | Options |
|---|---|---|
| `ingredient_a` | Link → Product Ingredient | |
| `ingredient_b` | Link → Product Ingredient | |
| `severity` | string | `Low`, `Medium`, `High` |
| `description` | string | |

The `ingredient_a_name` and `ingredient_b_name` fields are resolved by the API and added to the response.

---

### 3.26 Price Alert

**DocType:** `Price Alert`

```json
{
  "name": "PA-001",
  "user": "user@example.com",
  "product": "PRD-001",
  "target_price": 29.99,
  "current_price": 34.99,
  "is_triggered": 0,
  "created_date": "2026-06-29T12:00:00.000000"
}
```

---

### 3.27 AI Conversation

**DocType:** `AI Conversation`

```json
{
  "name": "CONV-001",
  "user": "user@example.com",
  "timestamp": "2026-06-29T12:00:00.000000",
  "message": "What should I do about my dry skin?",
  "response": "Thanks for your message! ...",
  "context": null,
  "sentiment": "Neutral"
}
```

| Field | Type | Options |
|---|---|---|
| `sentiment` | string | `Positive`, `Neutral`, `Negative` |

---

### 3.28 Need Analyzer Response

```json
{
  "message": {
    "needs": [
      {
        "area": "hydration",
        "priority": "high",
        "message": "Skin hydration is low"
      }
    ],
    "profile_complete": true
  }
}
```

| Field | Type | Notes |
|---|---|---|
| `needs` | array | Priority areas requiring attention |
| `area` | string | Concern category or specific area |
| `priority` | string | `high` or `medium` |
| `message` | string | Human-readable description |
| `profile_complete` | boolean | Whether skin/hair type is set |

---

## 4. API Endpoints

All endpoints follow: `/api/method/aura.api.<module>.<method>`

### 4.1 Account Management

#### `POST /api/method/aura.api.auth.register`

Create a new user + beauty profile.

**Auth:** Guest

**Body:**
```json
{
  "email": "jane@example.com",
  "password": "Str0ng!Pass#2026",
  "first_name": "Jane",
  "last_name": "Doe"
}
```

**Response 200:**
```json
{
  "message": "Registration successful",
  "user": "jane@example.com"
}
```

#### `POST /api/method/aura.api.auth.google_login`

Login or register with Google ID token.

**Auth:** Guest

**Body:**
```json
{ "token": "<google-id-token>" }
```

**Response 200:**
```json
{
  "message": "Login successful",
  "user": "user@gmail.com",
  "full_name": "Jane Doe"
}
```

---

### 4.2 Profile

#### `GET /api/method/aura.api.profile.get_profile`

Get the current user's beauty profile.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": {
    "name": "jane@example.com",
    "full_name": "Jane Doe",
    "age_range": "25-34",
    "gender": "Female",
    "country": "US",
    "skin_type": "Combination",
    "skin_score": 7,
    "hair_type": "Curly",
    "hair_score": 6,
    "overall_beauty_score": 6,
    "subscription_status": "Free",
    "goals": [
      {
        "goal": "Acne",
        "is_primary": 1,
        "status": "Active",
        "progress_percent": 40
      }
    ]
  }
}
```

#### `POST /api/method/aura.api.profile.update_profile`

Update profile fields. Only allowed fields are accepted.

**Auth:** Token/Session

**Body:**
```json
{
  "skin_type": "Combination",
  "hair_type": "Curly",
  "age_range": "25-34",
  "gender": "Female",
  "country": "US",
  "climate": "Tropical"
}
```

**Allowed fields:** `full_name`, `age_range`, `gender`, `country`, `date_of_birth`, `climate`, `skin_type`, `skin_sensitivity`, `hair_type`

**Select options:**

| Field | Options |
|---|---|
| `age_range` | `18-24`, `25-34`, `35-44`, `45-54`, `55+` |
| `gender` | `Female`, `Male`, `Non-binary`, `Prefer not to say` |
| `skin_type` | `Oily`, `Dry`, `Combination`, `Normal`, `Sensitive` |
| `skin_sensitivity` | `Low`, `Medium`, `High` |
| `hair_type` | `Straight`, `Wavy`, `Curly`, `Coily` |
| `climate` | `Tropical`, `Dry`, `Temperate`, `Continental`, `Polar` |

**Response 200:**
```json
{
  "message": "Profile updated",
  "profile": "jane@example.com"
}
```

---

### 4.3 Products

#### `GET /api/method/aura.api.products.get_products`

Get all active products, optionally filtered.

**Auth:** Token/Session

**Query params:** `filters` (optional JSON)

```
/api/method/aura.api.products.get_products?filters={"category":"Skincare"}
```

**Response 200:**
```json
{
  "message": [
    {
      "name": "PRD-001",
      "product_name": "Hydrating Serum",
      "brand": "GlowLab",
      "price": 34.99,
      "category": "Skincare",
      "routine_step": "Treat",
      "product_score": 88.5,
      "is_featured": 1,
      "description": "<p>A lightweight hydrating serum...</p>"
    }
  ]
}
```

#### `GET /api/method/aura.api.products.get_product`

Get full product details.

**Auth:** Token/Session

**Query params:** `name` (string, required)

**Response 200:**
```json
{
  "message": {
    "name": "PRD-001",
    "product_name": "Hydrating Serum",
    "brand": "GlowLab",
    "price": 34.99,
    "category": "Skincare",
    "description": "<p>A lightweight hydrating serum...</p>",
    "routine_step": "Treat",
    "product_score": 88.5,
    "is_featured": 1,
    "concerns": ["Dryness", "Aging"],
    "ingredients": ["Hyaluronic Acid", "Vitamin C"],
    "skin_types": ["Dry", "Combination"],
    "hair_types": []
  }
}
```

#### `GET /api/method/aura.api.products.search_products`

Search products by name, brand, or description.

**Auth:** Token/Session

**Query params:** `query` (string, min 2 chars)

**Response 200:**
```json
{
  "message": [
    {
      "name": "PRD-001",
      "product_name": "Hydrating Serum",
      "brand": "GlowLab",
      "description": "<p>A lightweight hydrating serum...</p>",
      "price": 34.99
    }
  ]
}
```

#### `POST /api/method/aura.api.products.set_price_alert`

Set a price-drop alert for a product.

**Auth:** Token/Session

**Body:**
```json
{
  "product": "PRD-001",
  "target_price": 29.99
}
```

**Response 200:**
```json
{
  "message": {
    "name": "PA-001",
    "user": "jane@example.com",
    "product": "PRD-001",
    "target_price": 29.99,
    "current_price": 34.99,
    "is_triggered": 0,
    "created_date": "2026-06-29 12:00:00.000000",
    "doctype": "Price Alert"
  }
}
```

---

### 4.4 Assessments

#### `POST /api/method/aura.api.assessments.submit_assessment`

Submit a skin, hair, or lifestyle assessment.

**Auth:** Token/Session

**Body:**

**Skin:**
```json
{
  "assessment_type": "Skin",
  "data": {
    "condition_score": 4,
    "severity": 3,
    "sensitivity": 2,
    "description": "Mild breakouts on cheeks"
  }
}
```

**Hair:**
```json
{
  "assessment_type": "Hair",
  "data": {
    "condition_score": 5,
    "severity": 2,
    "scalp_condition": "Oily",
    "description": "Oily scalp, fine hair"
  }
}
```

**Lifestyle:**
```json
{
  "assessment_type": "Lifestyle",
  "data": {
    "sleep_quality": "Good",
    "stress_level": "Medium",
    "diet_quality": "Fair"
  }
}
```

| `assessment_type` | Target DocType |
|---|---|
| `Skin` | Skin Assessment |
| `Hair` | Hair Assessment |
| `Lifestyle` | Lifestyle Assessment |

**Response 200:**
```json
{
  "message": {
    "assessment_id": "ASM-001",
    "scores": { "overall_score": 7 }
  }
}
```

Scores are also written back to the user's Beauty User Profile (`skin_score`, `hair_score`, `overall_beauty_score`).

#### `GET /api/method/aura.api.assessments.get_assessment_history`

Get recent assessments (last 10 of each type).

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "ASM-001",
      "assessment_date": "2026-06-29 12:00:00.000000",
      "overall_score": 7,
      "assessment_type": "Skin Assessment"
    }
  ]
}
```

---

### 4.5 Recommendations

#### `GET /api/method/aura.api.recommendations.get_recommendations`

Get the latest product recommendations. Auto-generates if none exist.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": {
    "confidence_score": 0.75,
    "reasoning": "Generated based on profile goals and product scores",
    "generated_date": "2026-06-29 12:00:00.000000",
    "products": [
      {
        "product_name": "Hydrating Serum",
        "brand": "GlowLab",
        "price": 34.99,
        "category": "Skincare",
        "confidence": 0.88,
        "reason": "Top rated product"
      }
    ]
  }
}
```

---

### 4.6 Marketplace

#### `POST /api/method/aura.api.marketplace.place_order`

Place an order for a product.

**Auth:** Token/Session

**Body:**
```json
{
  "product_id": "PRD-001",
  "quantity": 2
}
```

**Response 200:**
```json
{
  "message": "Order placed successfully",
  "order_id": "ORD-001",
  "status": "Pending"
}
```

#### `POST /api/method/aura.api.marketplace.partner_register`

Register a new marketplace partner (guest-accessible).

**Auth:** Guest

**Body:**
```json
{
  "company_name": "GlowLab Inc.",
  "contact_email": "partner@glowlab.com",
  "contact_person": "Jane Doe",
  "webhook_url": "https://glowlab.com/webhook",
  "commission_percent": 15,
  "integration_type": "Shopify"
}
```

| Field | Required | Notes |
|---|---|---|
| `company_name` | Yes | Unique |
| `contact_email` | Yes | |
| `contact_person` | No | |
| `webhook_url` | No | HTTPS URL for order notifications |
| `commission_percent` | No | Integer 0–100 |
| `integration_type` | No | `ERPNext`, `Odoo`, `Shopify`, `Custom API`, `Manual` |

**Response 200:**
```json
{
  "message": "Registration submitted",
  "partner_id": "PARTNER-001",
  "api_key": "abc123...",
  "api_secret": "xyz789..."
}
```

#### `GET /api/method/aura.api.marketplace.partner_get_orders`

Get orders for the authenticated partner.

**Auth:** Partner API headers (`X-API-Key`, `X-API-Secret`)

**Headers:**
```
X-API-Key: abc123...
X-API-Secret: xyz789...
```

**Response 200:**
```json
{
  "message": [
    {
      "name": "ORD-001",
      "user": "jane@example.com",
      "total_price": 69.98,
      "order_status": "Pending",
      "payment_status": "Pending",
      "ordered_date": "2026-06-29 12:00:00.000000"
    }
  ]
}
```

#### `POST /api/method/aura.api.marketplace.partner_update_order_status`

Update order status (partner-authenticated).

**Auth:** Partner API headers

**Body:**
```json
{
  "order_id": "ORD-001",
  "status": "Confirmed",
  "invoice_url": "https://invoices.example.com/inv-001.pdf"
}
```

**Valid statuses:** `Confirmed`, `Processing`, `Shipped`, `Delivered`, `Cancelled`

**Response 200:**
```json
{
  "message": "Order Confirmed",
  "order_id": "ORD-001",
  "status": "Confirmed"
}
```

---

### 4.7 Subscriptions

#### `GET /api/method/aura.api.subscriptions.get_plans`

List all active subscription plans.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "Free",
      "plan_name": "Free",
      "plan_type": "Free",
      "price_monthly": 0.0,
      "price_yearly": 0.0,
      "is_active": 1,
      "features": []
    },
    {
      "name": "Premium",
      "plan_name": "Premium",
      "plan_type": "Premium",
      "price_monthly": 19.99,
      "price_yearly": 199.99,
      "is_active": 1,
      "features": ["AI Coach Access", "Advanced Analytics"]
    }
  ]
}
```

#### `POST /api/method/aura.api.subscriptions.upgrade_plan`

Upgrade or change subscription.

**Auth:** Token/Session

**Body:**
```json
{
  "plan_id": "Premium",
  "subscription_type": "Monthly"
}
```

| Field | Options |
|---|---|
| `plan_id` | Any active plan name (e.g. `Free`, `Basic`, `Premium`) |
| `subscription_type` | `Monthly`, `Yearly` |

**Response 200:**
```json
{
  "message": "Upgraded to Premium",
  "subscription": "SUB-001"
}
```

#### `POST /api/method/aura.api.subscriptions.cancel_subscription`

Cancel the active subscription. Resets plan to Free.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": "Subscription cancelled"
}
```

---

### 4.8 Community

#### `POST /api/method/aura.api.community.create_post`

Create a community post.

**Auth:** Token/Session

**Body:**
```json
{
  "title": "My skincare journey",
  "content": "I have been using this routine for 30 days...",
  "group": "GROUP-001",
  "tags": "skincare,routine"
}
```

**Response 200:**
```json
{
  "message": "Post created",
  "post_id": "POST-001"
}
```

#### `GET /api/method/aura.api.community.get_feed`

Get community feed with pagination.

**Auth:** Token/Session

**Query params:**

| Param | Default | Notes |
|---|---|---|
| `limit` | 20 | Max posts per page |
| `start` | 0 | Offset for pagination |

**Response 200:**
```json
{
  "message": [
    {
      "name": "POST-001",
      "title": "My skincare journey",
      "content": "<p>I have been using this routine for 30 days...</p>",
      "author": "jane@example.com",
      "group": "GROUP-001",
      "likes": 5,
      "tags": "skincare,routine",
      "image": null,
      "creation": "2026-06-29 12:00:00.000000",
      "author_name": "Jane Doe",
      "comment_count": 3
    }
  ]
}
```

#### `POST /api/method/aura.api.community.add_comment`

Add a comment to a post.

**Auth:** Token/Session

**Body:**
```json
{
  "post": "POST-001",
  "content": "Great progress!"
}
```

**Response 200:**
```json
{
  "message": "Comment added",
  "comment_id": "CMT-001"
}
```

#### `POST /api/method/aura.api.community.toggle_like`

Like a post (increments counter).

**Auth:** Token/Session

**Body:**
```json
{ "post": "POST-001" }
```

**Response 200:**
```json
{
  "message": { "likes": 6 }
}
```

#### `GET /api/method/aura.api.community.get_groups`

List public community groups.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "GROUP-001",
      "group_name": "Skincare Enthusiasts",
      "description": "For anyone passionate about skincare",
      "members_count": 150,
      "is_public": 1
    }
  ]
}
```

---

### 4.9 Routines

#### `GET /api/method/aura.api.routines.get_routines`

Get the current user's active routines.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "RTN-001",
      "routine_template": "TMPL-001",
      "is_active": 1,
      "start_date": "2026-06-01",
      "progress_percent": 60.0
    }
  ]
}
```

#### `POST /api/method/aura.api.routines.start_routine`

Start a new routine from a template.

**Auth:** Token/Session

**Body:**
```json
{ "template_id": "TMPL-001" }
```

**Response 200:**
```json
{
  "message": "Routine started",
  "routine_id": "RTN-001"
}
```

#### `POST /api/method/aura.api.routines.complete_step`

Mark a routine step as completed.

**Auth:** Token/Session

**Body:**
```json
{
  "routine_id": "RTN-001",
  "step_row_name": "row-id-from-routine"
}
```

**Response 200:**
```json
{
  "message": { "progress_percent": 80.0 }
}
```

#### `GET /api/method/aura.api.routines.get_templates`

List available routine templates.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "TMPL-001",
      "template_name": "30-Day Glow Up",
      "description": "A complete 30-day skincare transformation",
      "is_active": 1
    }
  ]
}
```

---

### 4.10 Progress

#### `GET /api/method/aura.api.progress.get_progress`

Get progress entries.

**Auth:** Token/Session

**Query params:** `limit` (default 30)

**Response 200:**
```json
{
  "message": [
    {
      "name": "PRG-001",
      "entry_date": "2026-06-29",
      "entry_type": "Diary",
      "value": 7,
      "notes": "Skin feels hydrated today"
    }
  ]
}
```

#### `POST /api/method/aura.api.progress.log_progress`

Log a progress entry.

**Auth:** Token/Session

**Body:**
```json
{
  "entry_type": "Diary",
  "value": 7,
  "notes": "Skin feels hydrated today"
}
```

| Field | Options |
|---|---|
| `entry_type` | `Assessment`, `Diary`, `Routine`, `Photo`, `Note` |
| `value` | Integer (0–10 scale) |
| `notes` | Text |

**Response 200:**
```json
{
  "message": "Progress logged",
  "entry_id": "PRG-001"
}
```

---

### 4.11 Badges

#### `GET /api/method/aura.api.badges.get_my_badges`

Get badges earned by the current user.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "badge": "BDG-001",
      "earned_date": "2026-06-15",
      "badge_name": "Early Adopter",
      "icon": "star",
      "description": "Joined Aura in the first month",
      "points": 50
    }
  ]
}
```

#### `GET /api/method/aura.api.badges.get_all_badges`

Get all available badges (leaderboard).

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "BDG-001",
      "badge_name": "Early Adopter",
      "icon": "star",
      "description": "Joined Aura in the first month",
      "points": 50
    }
  ]
}
```

---

### 4.12 Ingredients

#### `GET /api/method/aura.api.ingredients.get_ingredients`

List all known ingredients.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "ING-001",
      "ingredient_name": "Hyaluronic Acid",
      "description": "A humectant that holds 1000x its weight in water",
      "benefits": "Deep hydration, plumping effect"
    }
  ]
}
```

#### `GET /api/method/aura.api.ingredients.get_conflicts`

List all known ingredient conflicts (e.g. retinol + vitamin C).

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": [
    {
      "name": "CONF-001",
      "ingredient_a": "ING-001",
      "ingredient_b": "ING-002",
      "severity": "High",
      "description": "Can cause irritation when used together",
      "ingredient_a_name": "Retinol",
      "ingredient_b_name": "Vitamin C"
    }
  ]
}
```

---

### 4.13 Need Analyzer

#### `GET /api/method/aura.api.need_analyzer.analyze_needs`

Analyze the user's profile and identify areas needing attention.

**Auth:** Token/Session

**Response 200:**
```json
{
  "message": {
    "needs": [
      {
        "area": "hydration",
        "priority": "high",
        "message": "Skin hydration is low"
      },
      {
        "area": "Skin",
        "priority": "medium",
        "message": "Acne"
      }
    ],
    "profile_complete": true
  }
}
```

---

### 4.14 AI Coach

#### `POST /api/method/aura.api.ai_coach.chat`

Send a message to the AI beauty coach.

**Auth:** Token/Session

**Body:**
```json
{
  "message": "What should I do about my dry skin?"
}
```

**Response 200:**
```json
{
  "message": {
    "response": "Thanks for your message! Based on your profile (skin: Combination, concerns: Dryness), I recommend maintaining a consistent routine. Try using products suited for your skin type and concerns.",
    "conversation_id": "CONV-001"
  }
}
```

#### `GET /api/method/aura.api.ai_coach.get_history`

Get AI conversation history.

**Auth:** Token/Session

**Query params:** `limit` (default 20)

**Response 200:**
```json
{
  "message": [
    {
      "name": "CONV-001",
      "message": "What should I do about my dry skin?",
      "response": "Thanks for your message! ...",
      "timestamp": "2026-06-29 12:00:00.000000",
      "sentiment": "Neutral"
    }
  ]
}
```

---

## 5. Standard REST Endpoints

Frappe exposes automatic REST APIs for all DocTypes.

### 5.1 List

```
GET /api/resource/{DocType}
```

Query params: `filters`, `fields`, `limit`, `limit_start`, `order_by`

**Auth:** Token/Session

```json
{
  "data": [
    { "name": "...", "field1": "...", ... }
  ]
}
```

### 5.2 Get

```
GET /api/resource/{DocType}/{name}
```

**Response:**
```json
{
  "data": { "name": "...", "field1": "...", ... }
}
```

### 5.3 Create

```
POST /api/resource/{DocType}
Content-Type: application/json

{ "field1": "value1", ... }
```

### 5.4 Update

```
PUT /api/resource/{DocType}/{name}
Content-Type: application/json

{ "field1": "new-value" }
```

### 5.5 Delete

```
DELETE /api/resource/{DocType}/{name}
```

### 5.6 Useful Resource Endpoints

| Resource | Notes |
|---|---|
| `/api/resource/Concern Tag` | Add filters to query |
| `/api/resource/Aura Subscription Plan` | Read plan details |
| `/api/resource/Routine Template` | Read templates with steps |
| `/api/resource/Achievement Badge` | Read badge catalog |

---

## 6. Pagination, Sorting & Filtering

### 6.1 Pagination

For whitelisted methods, use `limit` and `start` query parameters:

```
/api/method/aura.api.community.get_feed?limit=10&start=20
```

For REST resources:

```
/api/resource/Community Post?limit=10&limit_start=20&order_by=creation desc
```

### 6.2 Sorting

For REST resources, use `order_by`:

```
/api/resource/Beauty Product?order_by=product_score desc
```

Whitelisted methods have fixed sort orders (typically `creation desc` or date-based).

### 6.3 Filtering (REST Resources)

Use the `filters` parameter as a JSON string:

```
/api/resource/Beauty Product?filters=[["is_active","=",1],["category","=","Skincare"]]
```

**Standard Frappe filter syntax:**

| Operator | Meaning |
|---|---|
| `=` | Equals |
| `!=` | Not equals |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater or equal |
| `<=` | Less or equal |
| `like` | SQL LIKE |
| `in` | In list |
| `not in` | Not in list |
| `between` | Between two values |
