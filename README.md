# AURA 1.0 — Beauty Intelligence Platform

> Unified merge of `lumina_beauty` (luxury editorial design) and `aura_beauty` (full-stack Frappe/Flutter platform). Personalized beauty assessments, AI-powered product recommendations, and community-driven skincare & haircare routines.

---

## Tech Stack

### Backend

| Technology | Purpose |
|---|---|
| [Frappe Framework](https://frappeframework.com) v15 | Full-stack web framework, REST API, admin panel |
| [ERPNext](https://erpnext.com) v15 | Role-based permissions, user management |
| Python 3.10+ | Server-side logic, recommendation engine |
| MariaDB 10.6+ | Primary database |
| Redis 6+ | Caching, session management, background jobs |

### Frontend

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev) 3.16+ | Cross-platform mobile UI |
| [Riverpod](https://riverpod.dev) 2.4+ | State management |
| [GoRouter](https://pub.dev/packages/go_router) 13+ | Declarative routing & deep linking |
| [Dio](https://pub.dev/packages/dio) 5+ | HTTP client with interceptors |
| [fl_chart](https://pub.dev/packages/fl_chart) 0.66+ | Charts & data visualization |
| [freezed](https://pub.dev/packages/freezed) | Immutable data classes |
| [json_serializable](https://pub.dev/packages/json_serializable) | JSON serialization |
| [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | Secure token storage |
| [google_fonts](https://pub.dev/packages/google_fonts) | Playfair Display + Manrope typography |

---

## Features

### Core
- **Smart Assessments**: Skin, hair, and lifestyle questionnaires with scoring
- **Product Intelligence**: Curated catalog with ingredient-level analysis
- **Recommendation Engine**: AI-powered product matching with explainable scores
- **Daily Routines**: Automated morning/evening routine generation
- **Progress Tracking**: Photo-based progress with trend charts and insights
- **Virtual Vanity**: Personal product shelf, usage tracking, expiry alerts, harmony reports
- **The Journal**: Editorial content with featured articles, topics, and newsletter CTA

### Community
- **Social Feed**: Share routines, reviews, and progress updates
- **Interest Groups**: Join skincare, haircare, and lifestyle communities
- **Challenges**: Weekly and monthly beauty challenges with rewards

### Intelligence
- **AI Beauty Coach**: Context-aware chat assistant for personalized advice
- **Smart Scoring**: Multi-factor product scoring algorithm
- **Personalization**: Recommendations adapt to your unique profile

### Platform
- **Subscription Tiers**: Free, Aura Plus, and Aura Premium
- **Dark Mode**: Full dark theme support
- **Arabic Support**: RTL layout and Arabic localization
- **Push Notifications**: Routine reminders and community updates
- **Climate Matching**: Smart product recommendations based on local UV, humidity, pollution

---

## Project Structure

```
aura_beauty/
├── backend/
│   └── aura/                          # Frappe/ERPNext custom app
│       ├── aura/
│       │   ├── __init__.py
│       │   ├── api/                   # REST API endpoints
│       │   │   ├── auth.py            # Authentication
│       │   │   ├── profile.py         # User profiles
│       │   │   ├── assessments.py     # Skin/Hair/Lifestyle
│       │   │   ├── products.py        # Product catalog
│       │   │   ├── recommendations.py # Recommendation engine API
│       │   │   ├── routines.py        # Routine management
│       │   │   ├── community.py       # Posts, comments, groups
│       │   │   ├── progress.py        # Progress tracking
│       │   │   ├── subscriptions.py   # Plans & payments
│       │   │   └── ai_coach.py        # AI chat
│       │   ├── doctype/               # 20 DocType definitions
│       │   ├── hooks.py               # App configuration
│       │   └── tasks/                 # Scheduled jobs
│       ├── setup.py
│       ├── requirements.txt
│       └── patches.txt
│
├── frontend/                          # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart                  # App entry point
│   │   ├── app.dart                   # Root widget, theme, router
│   │   ├── core/                      # Shared infrastructure
│   │   │   ├── constants/
│   │   │   ├── localization/
│   │   │   ├── network/
│   │   │   ├── router/
│   │   │   └── theme/
│   │   ├── data/                      # Data layer (29 files)
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/                    # Domain layer (28 files)
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── repository_providers.dart  # DI wiring
│   │   ├── presentation/              # Presentation layer
│   │   │   ├── providers/             # 5 state providers
│   │   │   ├── screens/               # 12 feature screens
│   │   │   │   ├── vanity/            # Virtual Vanity (ported from lumina)
│   │   │   │   └── diary/             # Beauty Diary + Journal (ported)
│   │   │   └── widgets/               # 9 shared widgets
│   │   └── l10n/                      # Localization files
│   └── pubspec.yaml
│
└── docs/                              # Documentation
    ├── ARCHITECTURE.md
    ├── API_CONTRACTS.md
    ├── DATABASE_SCHEMA.md
    ├── DEPLOYMENT.md
    ├── DEVELOPMENT_ROADMAP.md
    ├── RECOMMENDATION_ENGINE.md
    └── NAVIGATION_FLOW.md
```

---

## Getting Started

### Prerequisites

- Frappe Bench v5+ ([install guide](https://frappeframework.com/docs/v15/user/en/installation))
- Python 3.10+, Node.js 18+, Redis 6+, MariaDB 10.6+
- Flutter SDK 3.16+ ([install guide](https://docs.flutter.dev/get-started/install))

### Backend Setup

```bash
# Initialize bench
bench init frappe-bench
cd frappe-bench

# Get ERPNext
bench get-app --branch version-15 erpnext

# Create site and install apps
bench new-site aura.site
bench --site aura.site install-app erpnext
bench --site aura.site install-app aura

# Start development server
bench start
```

### Frontend Setup

```bash
cd frontend
flutter pub get
dart run build_runner build
flutter run
```

---

## Design Philosophy

The UI follows an **editorial luxury aesthetic** inspired by high-fashion beauty brands:

- **Typography**: Playfair Display (serif headings) + Manrope (sans-serif body) — elegant, editorial feel
- **Palette**: Warm neutrals (ivory, nude, sand) accented with matte gold, grounded by soft charcoal
- **Spacing**: Generous white space with consistent 8px grid, 24px container margins
- **AURA Wordmark**: `letterSpacing: 6.0` on the brand name for a premium, spaced-out logo feel
- **Cards**: Soft rounded corners (`radiusCards: 24`), subtle borders, frosted-glass top bar

## Documentation

| Document | Description |
|---|---|
| [Architecture](docs/ARCHITECTURE.md) | System architecture, clean architecture layers, data flow |
| [API Contracts](docs/API_CONTRACTS.md) | Complete REST API reference with examples |
| [Database Schema](docs/DATABASE_SCHEMA.md) | All 20+ DocTypes, ERD, field definitions |
| [Deployment Guide](docs/DEPLOYMENT.md) | Production setup, CI/CD, monitoring |
| [Development Roadmap](docs/DEVELOPMENT_ROADMAP.md) | 12-week sprint plan with tasks |
| [Recommendation Engine](docs/RECOMMENDATION_ENGINE.md) | Scoring algorithm, weights, A/B testing |
| [Navigation Flow](docs/NAVIGATION_FLOW.md) | Route tree, auth flow, deep linking |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

[MIT License](LICENSE)

---

*Built with Frappe & Flutter. Powered by beauty intelligence.*
