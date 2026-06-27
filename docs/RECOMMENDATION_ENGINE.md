# Aura - Beauty Intelligence Platform: Recommendation Engine

---

## 1. Overview and Goals

### What It Does

The Recommendation Engine is the core intelligence layer of Aura. It analyzes a user's beauty profile, assessment results, and goals to match them with the most suitable products from the catalog. The engine produces a ranked list of product recommendations with explainable match scores.

### Goals

1. **Personalization**: Deliver product recommendations tailored to each user's unique skin type, hair type, concerns, goals, and lifestyle
2. **Explainability**: Every recommendation includes human-readable reasons for why a product was matched
3. **Adaptability**: Recommendations improve over time as users complete more assessments and provide feedback
4. **Performance**: Generate recommendations in under 5 seconds for immediate user-facing responses
5. **Freshness**: Automatically regenerate daily to reflect new products and updated user data

### Architecture Overview

```
User Profile + Assessments
          │
          ▼
┌─────────────────────┐
│  Profile Analyzer   │  Extracts user attributes, scores, goals
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Product Scorer     │  Scores each active product against user
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Rank & Sort        │  Composite score = weighted average
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Explainability     │  Generates match reason strings
└─────────┬───────────┘
          │
          ▼
    Cached Results
```

---

## 2. Scoring Algorithm

The engine computes a composite match score for each product against the user. The score is a weighted sum of five sub-scores, each normalized to 0-100.

### Score Components

```
TotalScore = w₁ × SkinTypeScore + w₂ × ConcernScore + w₃ × GoalScore
           + w₄ × IngredientScore + w₅ × AIWeightScore
```

Where:
- `w₁ + w₂ + w₃ + w₄ + w₅ = 1.0`
- Each sub-score is calculated independently and normalized to 0-100
- Default weights are configurable per product category

### 2.1 Skin Type Compatibility Scoring

Evaluates how well a product's target skin types match the user's skin type.

```
SkinTypeScore = MatchRatio × 100

MatchRatio = (Number of matched skin types) / (Number of product's listed skin types)

Where "match" means:
  - Product skin_types list contains user.skin_type
  - OR product skin_types is empty (product is "all skin types")
```

**Examples**:
| User Skin Type | Product Skin Types | Score |
|---|---|---|
| Oily | ["Oily", "Combination"] | 100 |
| Dry | ["Oily", "Combination"] | 0 |
| Combination | [] (all types) | 100 |

### 2.2 Concern Matching

Measures overlap between user's assessment concerns and product's targeted concerns.

```
ConcernScore = (MatchedConcerns / Max(TotalUserConcerns, TotalProductConcerns, 1)) × 100

Where:
  - MatchedConcerns = intersection of user concerns and product concerns
  - TotalUserConcerns = concerns identified from latest assessment
  - TotalProductConcerns = concerns listed on product
```

**Weighting by severity** (optional enhancement):
```python
concern_weights = {
    "acne_presence": {"None": 0, "Mild": 0.3, "Moderate": 0.6, "Severe": 1.0},
    "hair_loss": {"None": 0, "Mild": 0.3, "Moderate": 0.6, "Severe": 1.0},
    "dryness": {"None": 0, "Low": 0.25, "Medium": 0.5, "High": 1.0},
}
```

### 2.3 Goal Alignment

Evaluates how well the product's features align with the user's stated goals from assessments.

```
GoalScore = (MatchedGoals / TotalUserGoals) × 100

Where:
  - MatchedGoals = intersection of user goals and product's related attributes
  - TotalUserGoals = number of goals user selected in assessments
```

**Goal-Product Mapping Table**:

| User Goal | Product Matches When... |
|---|---|
| Reduce Acne | Product concerns include "Acne" OR contains salicylic acid/benzoyl peroxide |
| Anti-Aging | Product concerns include "Wrinkles" OR contains retinol/vitamin C |
| Brightening | Product concerns include "Pigmentation" OR contains niacinamide/vitamin C |
| Hydration | Product routine_step is "Moisturizer" OR contains hyaluronic acid |
| Hair Growth | Product concerns include "Hair Loss" OR category is "Haircare" |

### 2.4 Ingredient Compatibility

Scores based on beneficial ingredients matching user concerns and harmful ingredients being absent.

```
IngredientScore = BeneficialScore - (HarmfulPenalty × 0.2)

BeneficialScore = (BeneficialIngredients / TotalCheckedIngredients) × 100

Where:
  - BeneficialIngredients = ingredients that address user's concerns
  - HarmfulPenalty = number of ingredients flagged for user's skin/hair type
  - TotalCheckedIngredients = max(beneficial + harmful, 1)
```

**Ingredient-Concern Database**:

| Ingredient | Benefits For | Avoid For |
|---|---|---|
| Salicylic Acid | Acne, Oily skin | Dry, Sensitive skin |
| Hyaluronic Acid | Dryness, Dehydration | - |
| Niacinamide | Pigmentation, Acne, Large pores | - |
| Retinol | Wrinkles, Aging, Texture | Sensitive skin (high concentration) |
| Vitamin C | Brightening, Pigmentation, Antioxidant | - |
| Benzoyl Peroxide | Acne | Dry, Sensitive skin |
| Sulfates | - | Dry hair, Curly hair, Sensitive scalp |
| Silicones | - | Fine hair, Oily scalp |

### 2.5 AI Weight Factor

A machine-learned weight (`ai_weight` field on `Beauty Product`) that captures user engagement signals.

```
AIWeightScore = product.ai_weight × 100

Where:
  - ai_weight is 0.0 to 1.0, initially set by product managers
  - Can be automatically adjusted based on:
    • User click-through rates on recommendations
    • Product save-to-routine ratio
    • Community post mentions (positive sentiment)
    • Re-purchase rates
```

---

## 3. Weight Calculation Formula

### Default Weights

| Component | Symbol | Default Weight | Rationale |
|---|---|---|---|
| Skin Type Match | w₁ | 0.30 | Skin compatibility is primary filter |
| Concern Match | w₂ | 0.25 | Addresses user's specific issues |
| Goal Alignment | w₃ | 0.20 | Matches user's stated objectives |
| Ingredient Score | w₄ | 0.15 | Deep ingredient-level matching |
| AI Weight | w₅ | 0.10 | Learned engagement signals |

### Category-Specific Weights

Weights shift based on product category:

| Category | w₁ (Skin) | w₂ (Concern) | w₃ (Goal) | w₄ (Ing) | w₅ (AI) |
|---|---|---|---|---|---|
| Skincare | 0.35 | 0.25 | 0.15 | 0.15 | 0.10 |
| Haircare | 0.25 | 0.30 | 0.20 | 0.15 | 0.10 |
| Body | 0.30 | 0.25 | 0.20 | 0.10 | 0.15 |
| Fragrance | 0.20 | 0.10 | 0.20 | 0.10 | 0.40 |

### Final Score Normalization

```
FinalScore = round(SkinTypeScore × w₁ + ConcernScore × w₂ + GoalScore × w₃
                    + IngredientScore × w₄ + AIWeightScore × w₅, 1)

Range: 0.0 - 100.0
```

Products scoring below a configurable threshold (default: 30) are excluded from results.

---

## 4. Product Scoring Example

### User Profile
```json
{
  "skin_type": "Combination",
  "skin_sensitivity": "Medium",
  "hair_type": "Wavy",
  "age_range": "25-34",
  "climate": "Tropical"
}
```

### Latest Skin Assessment
```json
{
  "acne_presence": "Mild",
  "pigmentation": "Medium",
  "hydration_level": 60,
  "oiliness": "Moderate",
  "main_goals": ["Reduce Acne", "Even Skin Tone", "Hydration"]
}
```

### Product Being Scored: "Brightening Niacinamide Serum"

```json
{
  "product_name": "Brightening Niacinamide Serum",
  "brand": "GlowLab",
  "category": "Skincare",
  "routine_step": "Serum",
  "price": 34.99,
  "skin_types": ["Combination", "Oily"],
  "concerns": ["Acne", "Pigmentation", "Large Pores"],
  "ingredients": ["Niacinamide", "Zinc PCA", "Hyaluronic Acid"],
  "ai_weight": 0.85,
  "product_score": 0.0
}
```

### Step 1: Skin Type Score
- User skin type: Combination
- Product skin types: [Combination, Oily]
- Match: Combination found → 1/1 = 1.0
- **SkinTypeScore = 100**

### Step 2: Concern Score
- User concerns: [Acne (Mild), Pigmentation (Medium)]
- Product concerns: [Acne, Pigmentation, Large Pores]
- Matched: Acne (0.3 weighted), Pigmentation (0.6 weighted) = 0.9
- Total user concern severity: 0.3 + 0.6 = 0.9
- Max(user_concerns, product_concerns) = max(2, 3) = 3
- **ConcernScore = (0.9 / 3.0) × 100 = 30**

### Step 3: Goal Score
- User goals: [Reduce Acne, Even Skin Tone, Hydration]
- Product matches:
  - Reduce Acne → Yes (Acne concern + Niacinamide)
  - Even Skin Tone → Yes (Pigmentation concern + Niacinamide)
  - Hydration → Partial (Hyaluronic Acid in ingredients, but not primary)
- Matched goals: 2.5 / 3 = 0.833
- **GoalScore = 83.3**

### Step 4: Ingredient Score
- Beneficial: Niacinamide (acne, pigmentation), Hyaluronic Acid (hydration)
  - 2 beneficial matches
- Harmful: None for combination skin
- **IngredientScore = (2 / 2) × 100 = 100**

### Step 5: AI Weight Score
- **AIWeightScore = 0.85 × 100 = 85**

### Step 6: Final Score (Skincare weights)
```
FinalScore = 100 × 0.35 + 30 × 0.25 + 83.3 × 0.15 + 100 × 0.15 + 85 × 0.10

= 35.00 + 7.50 + 12.50 + 15.00 + 8.50

= 78.5
```

### Match Reasons Generated
```json
[
  "Perfect for Combination skin type",
  "Contains Niacinamide to address acne concerns",
  "Contains Hyaluronic Acid for hydration",
  "Helps achieve your goal: Even Skin Tone",
  "Helps achieve your goal: Reduce Acne"
]
```

---

## 5. Routine Generation Logic

After products are scored and ranked, the engine generates a daily routine by:

### Algorithm

```
1. Filter products with FinalScore >= 50 (quality threshold)
2. Group by routine_step (Cleanser, Serum, Moisturizer, SPF, etc.)
3. For each step group, select the highest-scored product
4. Assign time_of_day based on routine_step:
   - Morning: Cleanser, SPF, Light Moisturizer
   - Evening: Cleanser, Serum, Heavy Moisturizer, Treatment
   - Weekly: Mask, Exfoliator
5. Order steps by step_order within time_of_day
6. Generate instructions based on product + user profile
```

### Example Generated Routine

```json
{
  "user": "sarah@example.com",
  "date": "2025-06-25",
  "steps": [
    {"step_order": 1, "time_of_day": "Morning", "product": "Gentle Cleanser", "completed": false},
    {"step_order": 2, "time_of_day": "Morning", "product": "Vitamin C Serum", "completed": false},
    {"step_order": 3, "time_of_day": "Morning", "product": "Lightweight Moisturizer", "completed": false},
    {"step_order": 4, "time_of_day": "Morning", "product": "SPF 50 Sunscreen", "completed": false},
    {"step_order": 1, "time_of_day": "Evening", "product": "Oil Cleanser", "completed": false},
    {"step_order": 2, "time_of_day": "Evening", "product": "Niacinamide Serum", "completed": false},
    {"step_order": 3, "time_of_day": "Evening", "product": "Night Moisturizer", "completed": false},
    {"step_order": 1, "time_of_day": "Weekly", "product": "Salicylic Acid Mask", "completed": false}
  ]
}
```

---

## 6. A/B Testing Framework

### Experiment Structure

```python
@frappe.whitelist()
def get_recommendations(user, type="all", limit=10):
    experiment = resolve_ab_test(user)
    
    if experiment == "control":
        return get_v1_recommendations(user, type, limit)
    elif experiment == "variant_a":
        return get_v2_recommendations(user, type, limit)
    elif experiment == "variant_b":
        return get_v3_recommendations(user, type, limit)
```

### Testable Variants

| Variant | Weight Change | Description |
|---|---|---|
| Control | Default weights | w₁=0.35, w₂=0.25, w₃=0.15, w₄=0.15, w₅=0.10 |
| Variant A | Higher AI weight | w₁=0.25, w₂=0.20, w₃=0.15, w₄=0.10, w₅=0.30 |
| Variant B | Higher ingredient weight | w₁=0.25, w₂=0.20, w₃=0.15, w₄=0.30, w₅=0.10 |

### Metrics Tracked

| Metric | Definition | Target |
|---|---|---|
| CTR | Click-through rate on recommended products | > 15% |
| Save Rate | % of recommendations saved to routine | > 25% |
| Purchase Rate | % of recommendations purchased | > 8% |
| Lift vs. Random | Improvement over random product selection | > 3x |
| User Satisfaction | Post-recommendation rating (1-5) | > 4.0 |

### Experiment Lifecycle

```
1. Define hypothesis (e.g., "Higher AI weight improves CTR")
2. Randomly assign 10% of users to each variant
3. Run experiment for 7 days minimum
4. Analyze results with statistical significance (p < 0.05)
5. Deploy winning variant to 100% of users
6. Archive experiment and document findings
```

---

## 7. Performance Metrics

### System Metrics

| Metric | Current | Target | Measurement |
|---|---|---|---|
| Average score time per product | 2ms | < 5ms | `time.perf_counter` |
| Total engine run (500 products) | 1.2s | < 3s | Benchmarked |
| Cache hit ratio | 85% | > 90% | Redis `info stats` |
| Daily regeneration time | 3min | < 5min | Scheduler log |
| API response time (p95) | 180ms | < 200ms | Nginx log |

### Business Metrics

| Metric | Definition | Instrumentation |
|---|---|---|
| Recommendation Coverage | % of users with recs available | Database query |
| Empty Recommendation Rate | % of API calls returning 0 results | API log |
| Click-to-Save Rate | % of clicked recs saved to routine | Analytics event |
| Average Recommendation Age | Hours since last regeneration | Doc metadata |

### Monitoring Queries

```sql
-- Check recommendation coverage
SELECT COUNT(DISTINCT user) FROM `tabRecommendation Result`
WHERE generated_date > DATE_SUB(NOW(), INTERVAL 2 DAY);

-- Check average scores by category
SELECT p.category, AVG(r.match_score)
FROM `tabRecommendation Result` r
JOIN `tabBeauty Product` p ON ...
GROUP BY p.category;
```

---

## 8. Future Improvements

### Short-term (Next 3 months)

| Improvement | Impact | Complexity |
|---|---|---|
| Collaborative filtering using community data | +15% CTR | Medium |
| Seasonality factor (weather-based product shifts) | Better relevance | Low |
| User feedback loop (explicit thumbs up/down) | Improved personalization | Low |
| Product bundling recommendations | Higher cart value | Medium |

### Medium-term (3-6 months)

| Improvement | Impact | Complexity |
|---|---|---|
| ML-based scoring model (LightGBM or similar) | +25% accuracy | High |
| Real-time personalization with user activity | Immediate relevance | High |
| Computer vision ingredient scanner | User engagement | High |
| Dynamic pricing-aware recommendations | Conversion rate | Medium |

### Long-term (6-12 months)

| Improvement | Impact | Complexity |
|---|---|---|
| Multi-modal AI (analyze user photos + profile) | Holistic assessment | Very High |
| Predictive product lifespan & refill timing | Recurring revenue | High |
| Virtual try-on integration | Purchase confidence | Very High |
| Hyper-personalized formulations | Unique value prop | Very High |

### Known Limitations

1. **Cold start problem**: New users with no assessments get generic recommendations. Mitigated by requiring onboarding before recommendations.
2. **New product cold start**: Products with no `ai_weight` default to 0.5. Mitigated by manual ai_weight assignment by product managers.
3. **No negative signals**: Engine doesn't learn from products user has tried and disliked. Future: add product feedback mechanism.
4. **Static weights**: All users get the same weight formula. Future: personalize weights per user segment.
5. **No price sensitivity**: Higher-priced products may rank well but not convert. Future: price-awareness factor.

---

## Appendix: Configuration

```python
# config/recommendation_engine.py

# Scoring weights (default)
DEFAULT_WEIGHTS = {
    "Skincare": {"skin_type": 0.35, "concern": 0.25, "goal": 0.15, "ingredient": 0.15, "ai": 0.10},
    "Haircare": {"skin_type": 0.25, "concern": 0.30, "goal": 0.20, "ingredient": 0.15, "ai": 0.10},
    "Body":     {"skin_type": 0.30, "concern": 0.25, "goal": 0.20, "ingredient": 0.10, "ai": 0.15},
    "Fragrance":{"skin_type": 0.20, "concern": 0.10, "goal": 0.20, "ingredient": 0.10, "ai": 0.40},
}

# Quality thresholds
MIN_SCORE_FOR_RECOMMENDATION = 30
MIN_SCORE_FOR_ROUTINE = 50
MAX_RECOMMENDATIONS = 20
MAX_ROUTINE_STEPS = 12

# Scoring time budget
MAX_SCORING_TIME_MS = 5000

# Cache TTL (seconds)
RECOMMENDATION_CACHE_TTL = 86400  # 24 hours

# Regeneration schedule
DAILY_REGEN_HOUR = 3  # 3 AM

# A/B testing
AB_TEST_PERCENTAGE = 0.10  # 10% of users in experiments
AB_TEST_MIN_DURATION_DAYS = 7
AB_TEST_MIN_USERS = 1000
```
