# Aura - Beauty Intelligence Platform: Development Roadmap

---

## Overview

**Timeline**: 12 Weeks
**Team**: 2 Backend (Frappe), 2 Frontend (Flutter), 1 QA, 1 Product Manager
**Methodology**: 2-week sprints with bi-weekly retrospectives

---

## Phase 1: Foundation (Week 1-2)

### Sprint 1.1: Frappe App Setup & Core DocTypes (Week 1)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Initialize Frappe app with `bench new-app aura` | BE-1 | Done |
| Define `hooks.py` with navigation, permissions, scheduler events | BE-1 | Done |
| Create `Beauty User Profile` DocType with all fields | BE-1 | Done |
| Create `Concern Tag` DocType as concern taxonomy | BE-1 | Done |
| Create `Assessment Goal` child DocType | BE-1 | Done |
| Set up `fixtures/` with default Subscription Plans | BE-1 | Planned |
| Configure role-based permissions (System Manager, All) | BE-1 | Done |
| Implement `before_save` and `validate` hooks on Profile | BE-1 | Done |
| Set up `patches.txt` and migration framework | BE-1 | Planned |
| Configure `requirements.txt` and `setup.py` | BE-1 | Done |

**Deliverables**:
- Working Frappe app installed on site
- 3 DocTypes with proper fields, permissions, and validations
- Fixture system configured

**Acceptance Criteria**:
- `bench --site site.name install-app aura` succeeds
- Beauty User Profile can be created via Desk
- Permissions restrict access correctly

---

### Sprint 1.2: Flutter Project Setup (Week 1-2)

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Initialize Flutter project with `flutter create` | FE-1 | Done |
| Set up `pubspec.yaml` with all dependencies | FE-1 | Done |
| Configure Clean Architecture folder structure | FE-1 | Done |
| Create `app.dart` with `MaterialApp.router` | FE-1 | Done |
| Define `AuraTheme.lightTheme` and `AuraTheme.darkTheme` | FE-2 | Done |
| Create `app_colors.dart`, `app_spacing.dart`, `app_typography.dart` | FE-2 | Done |
| Set up GoRouter with basic route tree | FE-1 | Done |
| Create splash screen with logo animation | FE-2 | Planned |
| Set up Riverpod `ProviderScope` | FE-1 | Done |
| Configure localization (`en`, `ar`) | FE-2 | Planned |
| Add `assets/images/` directory structure | FE-1 | Done |

**Deliverables**:
- Flutter app that builds and runs
- Theming system with light/dark mode support
- Navigation framework with route definitions

**Acceptance Criteria**:
- `flutter run` launches the app
- Theme colors and typography render correctly
- Navigation between placeholder screens works

---

### Sprint 2.1: Authentication System (Week 2)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `aura/api/auth.py` - register endpoint | BE-2 | Planned |
| Create `aura/api/auth.py` - login with API key/secret | BE-2 | Planned |
| Create `aura/api/auth.py` - logout and session management | BE-2 | Planned |
| Create `aura/api/auth.py` - password reset flow | BE-2 | Planned |
| Implement automatic `Beauty User Profile` creation on register | BE-2 | Planned |
| Add rate limiting for login endpoint | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `auth/` screen directory (login, register, forgot password) | FE-1 | Planned |
| Build login form with email/password fields and validation | FE-1 | Planned |
| Build registration form with all required fields | FE-1 | Planned |
| Implement `flutter_secure_storage` for token persistence | FE-2 | Planned |
| Create `authProvider` (Riverpod StateNotifier) | FE-2 | Planned |
| Add social login buttons (UI only, future scope) | FE-1 | Planned |
| Configure Dio HTTP client with auth interceptor | FE-2 | Planned |

**Integration**: Auth flow from registration through login to profile creation

**Deliverables**:
- Full authentication cycle: Register → Login → API call → Logout
- Token persisted in secure storage
- Auth guard redirects unauthenticated users

---

## Phase 2: Core Features (Week 3-5)

### Sprint 2.2: Onboarding & Assessments (Week 3)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `Skin Assessment` DocType with all fields | BE-1 | Done |
| Create `Hair Assessment` DocType with all fields | BE-1 | Done |
| Create `Lifestyle Assessment` DocType with all fields | BE-1 | Done |
| Create `aura/api/assessments.py` - submit endpoints | BE-2 | Planned |
| Create `aura/api/assessments.py` - history endpoint | BE-2 | Planned |
| Implement assessment scoring logic (compute overall_score) | BE-2 | Planned |
| Update profile `last_assessment_date` on submission | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `onboarding/` screens with stepper | FE-1 | Planned |
| Build skin assessment form (radio buttons, sliders) | FE-1 | Planned |
| Build hair assessment form (selection grids) | FE-1 | Planned |
| Build lifestyle assessment form | FE-1 | Planned |
| Build goal selection screen (multi-select chips) | FE-2 | Planned |
| Create assessment Riverpod providers | FE-2 | Planned |
| Add onboarding redirect logic in GoRouter | FE-2 | Planned |

**Deliverables**:
- Complete onboarding flow (welcome → assessments → goals)
- Assessment data persisted in backend
- User redirected to main app after completion

---

### Sprint 3.1: Product Intelligence System (Week 4)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `Beauty Product` DocType with all fields | BE-1 | Done |
| Create `Product Concern` and `Product Ingredient` child tables | BE-1 | Done |
| Create `aura/api/products.py` - list, get, search endpoints | BE-2 | Planned |
| Implement product filtering (category, brand, price range) | BE-2 | Planned |
| Implement full-text search on product names and descriptions | BE-2 | Planned |
| Create `Routine Template` DocType with step child table | BE-1 | Planned |
| Load sample product catalog via fixtures | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `discover/` screen with product listing | FE-1 | Planned |
| Build product detail screen with image gallery | FE-1 | Planned |
| Implement search bar with debounced API calls | FE-2 | Planned |
| Build category filter chips | FE-1 | Planned |
| Create product Riverpod providers | FE-2 | Planned |
| Build product card component (reusable) | FE-1 | Planned |
| Add shimmer loading placeholders | FE-2 | Planned |

**Deliverables**:
- Product catalog browsable and searchable
- Product detail views with ingredient information
- Filtering and search fully functional

---

### Sprint 3.2: Recommendation Engine v1 (Week 5)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `recommendation_engine/scorer.py` - scoring algorithm | BE-1 | Planned |
| Create `recommendation_engine/matcher.py` - product-user matching | BE-1 | Planned |
| Create `Recommendation Result` DocType for caching | BE-1 | Done |
| Create `aura/api/recommendations.py` - get and regenerate | BE-2 | Planned |
| Implement daily scheduler for batch regeneration | BE-2 | Planned |
| Calculate match scores: skin, concern, goal, ingredient | BE-1 | Planned |
| Add AI weight factor to product scoring | BE-1 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Build recommendation carousel on home screen | FE-1 | Planned |
| Create recommendation result cards with score badges | FE-1 | Planned |
| Display match reasons per recommendation | FE-2 | Planned |
| Handle empty/no-assessment states gracefully | FE-2 | Planned |
| Add pull-to-refresh for regeneration | FE-1 | Planned |

**Deliverables**:
- Personalized product recommendations based on assessments
- Recommendations cached and refreshed daily
- Visual display of match scores and reasons

---

### Sprint 4.1: Routine Management (Week 5)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `User Routine` DocType with step child table | BE-1 | Done |
| Create `aura/api/routines.py` - CRUD endpoints | BE-2 | Planned |
| Implement routine generation from recommendations | BE-2 | Planned |
| Add step completion tracking | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `routine/` screen with daily timeline | FE-1 | Planned |
| Build routine step cards with completion toggles | FE-1 | Planned |
| Create routine detail view | FE-2 | Planned |
| Add percentage completion indicator | FE-1 | Planned |
| Create routine Riverpod provider | FE-2 | Planned |

**Deliverables**:
- User can view daily beauty routine
- Steps can be toggled as completed
- Routines generated from recommendations

---

## Phase 3: Community (Week 6-7)

### Sprint 4.2: Community Feed & Posts (Week 6)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `Community Post` DocType | BE-1 | Done |
| Create `Community Comment` DocType | BE-1 | Done |
| Create `Community Group` DocType | BE-1 | Done |
| Create `aura/api/community.py` - CRUD endpoints | BE-2 | Planned |
| Implement feed generation (For You, Following) | BE-2 | Planned |
| Add like/unlike functionality | BE-2 | Planned |
| Implement post-comment relationship | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `community/` screen with feed tabs | FE-1 | Planned |
| Build `PostCard` reusable widget | FE-1 | Planned |
| Create post detail screen with comments | FE-1 | Planned |
| Build comment input and display | FE-2 | Planned |
| Implement like button with animation | FE-2 | Planned |
| Create post creation screen with media upload | FE-1 | Planned |
| Build community Riverpod providers | FE-2 | Planned |

**Deliverables**:
- Community feed with For You and Following tabs
- Create, like, and comment on posts
- Post detail view

---

### Sprint 5.1: Groups & Challenges (Week 7)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `Challenge` DocType | BE-1 | Done |
| Add group membership tracking (members_count) | BE-2 | Planned |
| Implement challenge participation logic | BE-2 | Planned |
| Create challenge endpoints | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Build groups list and detail screens | FE-1 | Planned |
| Create challenges screen with progress tracking | FE-1 | Planned |
| Build challenge detail and join flow | FE-2 | Planned |
| Add group feed filter | FE-1 | Planned |
| Create challenge Riverpod provider | FE-2 | Planned |

**Deliverables**:
- Community groups browsable
- Challenges with participation tracking
- Group-specific feed

---

### Sprint 5.2: Progress Tracking & Charts (Week 7)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `Progress Entry` DocType | BE-1 | Done |
| Create `aura/api/progress.py` - add, history, charts | BE-2 | Planned |
| Implement trend analysis and score change calculation | BE-2 | Planned |
| Generate insights (e.g., "Your hydration improved 15%") | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `progress/` dashboard screen | FE-1 | Planned |
| Build score overview chart (`fl_chart`) | FE-2 | Planned |
| Create trend line charts for each assessment type | FE-2 | Planned |
| Build progress entry form with photo upload | FE-1 | Planned |
| Add milestone and achievement badges | FE-1 | Planned |
| Create progress Riverpod providers | FE-2 | Planned |

**Deliverables**:
- Progress dashboard with charts
- Manual progress entry with photos
- Score trends and insights

---

## Phase 4: Intelligence (Week 8-10)

### Sprint 6.1: AI Beauty Coach Integration (Week 8)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `AI Conversation` DocType | BE-1 | Done |
| Create `aura/api/ai_coach.py` - send, history, clear | BE-2 | Planned |
| Integrate with external AI API (OpenAI or similar) | BE-2 | Planned |
| Implement context-aware responses (uses assessments) | BE-2 | Planned |
| Add rate limiting per subscription tier | BE-2 | Planned |
| Implement content filtering for safety | BE-2 | Planned |
| Create conversation context builder | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `ai_coach/` chat screen | FE-1 | Planned |
| Build chat bubble UI (user vs coach styling) | FE-1 | Planned |
| Implement streaming response display (typing indicator) | FE-2 | Planned |
| Add context selector (skin, hair, routine, product) | FE-1 | Planned |
| Show daily message usage counter | FE-2 | Planned |
| Create AI Coach Riverpod provider | FE-2 | Planned |
| Display product recommendations inline in chat | FE-1 | Planned |

**Deliverables**:
- AI chat interface with streaming responses
- Context-aware beauty advice
- Subscription-based rate limiting

---

### Sprint 6.2: Advanced Recommendations (Week 9)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Enhance scoring algorithm with weighted factors | BE-1 | Planned |
| Implement A/B testing framework for recommendation variants | BE-1 | Planned |
| Add collaborative filtering signals (community data) | BE-2 | Planned |
| Create personalization engine user segments | BE-1 | Planned |
| Add seasonality factors to recommendations | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Add recommendation refinement filters | FE-1 | Planned |
| Build "Why this product?" expandable explanation | FE-2 | Planned |
| Add product comparison feature | FE-1 | Planned |
| Create personalized skin/hair score display | FE-2 | Planned |

---

### Sprint 7.1: Subscription System (Week 10)

**Backend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create `Subscription Plan` DocType with fixtures | BE-1 | Done |
| Create `User Subscription` DocType | BE-1 | Done |
| Create `aura/api/subscriptions.py` - plans, subscribe, cancel, status | BE-2 | Planned |
| Integrate Stripe payment processing | BE-2 | Planned |
| Implement subscription feature gating | BE-2 | Planned |
| Add webhook handlers for payment events | BE-2 | Planned |
| Create subscription status auto-expiry job | BE-2 | Planned |

**Frontend Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Build subscription plans screen with feature comparison | FE-1 | Planned |
| Create checkout flow with payment method selection | FE-2 | Planned |
| Add subscription status badge on profile | FE-1 | Planned |
| Implement feature gating based on subscription level | FE-2 | Planned |
| Handle subscription expiry gracefully | FE-2 | Planned |

**Deliverables**:
- Subscription plans visible and purchasable
- Stripe payment processing
- Feature gating by subscription tier

---

## Phase 5: Polish (Week 11-12)

### Sprint 7.2: Localization & Arabic Support (Week 11)

**Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Create ARB files for English and Arabic localizations | FE-2 | Planned |
| Translate all UI strings to Arabic | FE-2 | Planned |
| Implement RTL layout support for Arabic | FE-2 | Planned |
| Localize date, number, and currency formats | FE-2 | Planned |
| Test all screens in Arabic RTL mode | QA | Planned |
| Add locale switcher in settings | FE-1 | Planned |

**Deliverables**:
- Full Arabic localization
- RTL layout support
- Locale switcher

---

### Sprint 8.1: Dark Mode (Week 11)

**Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Complete `AuraTheme.darkTheme` with all color definitions | FE-2 | Planned |
| Test all widgets in dark mode | FE-2 | Planned |
| Add theme toggle in settings | FE-1 | Planned |
| Persist theme preference | FE-1 | Planned |
| Create theme Riverpod provider | FE-2 | Planned |

**Deliverables**:
- Fully functional dark mode
- Theme persistence across sessions

---

### Sprint 8.2: Performance Optimization (Week 12)

**Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Profile Flutter app with DevTools | FE-2 | Planned |
| Optimize build method rebuilds (const widgets, selective rebuilds) | FE-2 | Planned |
| Implement paginated lists with pre-fetch | FE-1 | Planned |
| Add image caching with `cached_network_image` | FE-1 | Planned |
| Optimize Riverpod providers (autoDispose, family) | FE-2 | Planned |
| Profile and optimize database queries | BE-2 | Planned |
| Add Redis caching for frequently accessed data | BE-2 | Planned |
| Implement lazy loading for community feed | FE-1 | Planned |

---

### Sprint 8.3: Testing & Bug Fixes (Week 12)

**Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Write unit tests for domain layer (entities, use cases) | FE-2 | Planned |
| Write widget tests for core components | FE-1 | Planned |
| Write integration tests for critical flows (auth, assessment) | FE-1 | Planned |
| Write Frappe unit tests for DocType validations | BE-1 | Planned |
| Write API endpoint tests (frappe.tests) | BE-2 | Planned |
| Conduct QA regression testing | QA | Planned |
| Fix priority bugs from backlog | All | Planned |
| Performance benchmark against targets | All | Planned |

---

### Sprint 8.4: App Store Preparation (Week 12)

**Tasks**:
| Task | Assignee | Status |
|---|---|---|
| Prepare app store screenshots (iPhone, Android) | PM | Planned |
| Write app store description (English, Arabic) | PM | Planned |
| Configure privacy policy URL | PM | Planned |
| Set up Terms of Service | PM | Planned |
| Create app icon and store assets | Design | Planned |
| Prepare TestFlight beta build | FE-1 | Planned |
| Prepare Google Play internal test track | FE-1 | Planned |
| Submit for app review | PM | Planned |
| Monitor crash reports post-launch | All | Planned |

**Deliverables**:
- App submitted to App Store and Google Play
- TestFlight and internal testing configured
- All store assets and legal documents ready

---

## Milestone Summary

| Phase | Week | Milestone | Key Deliverable |
|---|---|---|---|
| Foundation | 1-2 | Project Scaffolding | Frappe app + Flutter project + Auth |
| Core | 3-5 | MVP Features | Assessments + Products + Recommendations + Routines |
| Community | 6-7 | Social Layer | Feed + Groups + Challenges + Progress |
| Intelligence | 8-10 | Premium Features | AI Coach + Advanced Recs + Subscriptions |
| Polish | 11-12 | Launch Ready | Arabic + Dark Mode + Performance + App Store |

---

## Risk Register

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Frappe API performance degradation | Medium | High | Caching layer, query optimization |
| Flutter build time > 5 min | Low | Medium | Cached builds, modularization |
| AI API latency > 2s | Medium | High | Streaming responses, timeout handling |
| App Store rejection (guidelines) | Low | High | Pre-review guidelines, proper permissions |
| Arabization/RTL layout bugs | Medium | Medium | Early Arabic testing, separate RTL widgets |
| Payment integration issues | Low | High | Sandbox testing, fallback payment methods |

---

## Appendix: Definition of Done

A task is considered complete when:

1. Code is written and follows project conventions
2. Code compiles/passes syntax check (`flutter analyze` / `bench build`)
3. Unit tests pass (`flutter test` / `bench --site test-site run-tests`)
4. API contract is documented (for backend tasks)
5. Widget matches Figma design (for frontend tasks)
6. PR is reviewed by at least one other developer
7. Feature is tested in staging environment
8. No regressions introduced in CI pipeline
9. Error states and empty states are handled
10. Logging is added for production debugging
