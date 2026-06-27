# Aura - Beauty Intelligence Platform: Deployment Guide

---

## 1. Prerequisites

### 1.1 System Requirements

| Component | Minimum | Recommended |
|---|---|---|
| CPU | 4 cores | 8+ cores |
| RAM | 8 GB | 16+ GB |
| Disk | 50 GB SSD | 100+ GB SSD |
| OS | Ubuntu 22.04 LTS | Ubuntu 24.04 LTS |

### 1.2 Software Prerequisites

| Software | Version | Purpose |
|---|---|---|
| Python | >= 3.10 | Frappe runtime |
| Node.js | >= 18.x | Frappe frontend build |
| Redis | >= 6.x | Caching, sessions, queues |
| MariaDB | >= 10.6 | Primary database |
| Nginx | >= 1.24 | Reverse proxy |
| wkhtmltopdf | >= 0.12.6 | PDF generation |
| Flutter SDK | >= 3.16 | Mobile app build |
| Dart SDK | >= 3.0 | Flutter runtime |
| Android SDK | >= 34 | Android builds |
| Xcode | >= 15.x | iOS builds (macOS only) |
| Bench CLI | >= 5.x | Frappe site management |

### 1.3 Install Frappe Bench

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install system dependencies
sudo apt install -y \
  python3-dev python3-pip python3-setuptools python3-venv \
  git mariadb-server mariadb-client \
  redis-server nginx \
  libffi-dev libssl-dev libmysqlclient-dev \
  wkhtmltopdf \
  curl wget

# Configure MariaDB
sudo mysql_secure_installation

# Create MariaDB config
sudo tee -a /etc/mysql/mariadb.conf.d/99-aura.cnf <<EOF
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
max_allowed_packet = 256M
innodb-file-format = barracuda
innodb-file-per-table = 1
innodb-large-prefix = 1
EOF

sudo systemctl restart mariadb

# Install Bench
sudo pip3 install frappe-bench

# Verify installation
bench --version
```

---

## 2. ERPNext Installation

```bash
# Create a bench directory
bench init --version version-15 frappe-bench
cd frappe-bench

# Set Python version
bench set-config python /usr/bin/python3

# Download ERPNext
bench get-app --branch version-15 erpnext

# Create a new site
bench new-site aura.site \
  --mariadb-root-password <root_password> \
  --admin-password <admin_password>

# Install ERPNext on the site
bench --site aura.site install-app erpnext

# Set developer mode for development
bench --site aura.site set-config developer_mode 1

# Start development server
bench start
```

---

## 3. Custom App Installation (Aura)

```bash
# Navigate to bench directory
cd ~/frappe-bench

# Get the custom app (from repository)
bench get-app aura /path/to/aura-beauty/backend/aura

# Install the app on the site
bench --site aura.site install-app aura

# Build app assets
bench build --app aura

# Migrate database
bench --site aura.site migrate

# Reload scheduler
bench --site aura.site clear-cache

# Load fixtures (default data)
bench --site aura.site load-fixtures

# Restart bench processes
bench restart
```

### App Dependencies

The Aura app depends on:
```python
# requirements.txt
frappe>=15.0.0
erpnext>=15.0.0
requests>=2.31.0
Pillow>=10.0.0
```

---

## 4. Flutter Build Configuration

### 4.1 Environment Setup

```bash
# Install Flutter SDK
# Download from https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Navigate to frontend directory
cd /path/to/aura-beauty/frontend

# Get dependencies
flutter pub get

# Generate code (json_serializable, freezed)
dart run build_runner build --delete-conflicting-outputs
```

### 4.2 Environment Configuration

Create `frontend/.env` (or use `flutter_dotenv`):

```env
# API Configuration
API_BASE_URL=https://api.aurabeauty.ai
API_TIMEOUT_SECONDS=30

# Authentication
TOKEN_STORAGE_KEY=aura_auth_token
REFRESH_TOKEN_KEY=aura_refresh_token

# Feature Flags
ENABLE_AI_COACH=true
ENABLE_SUBSCRIPTIONS=true
ENABLE_COMMUNITY=true
MAX_ASSESSMENT_RETRIES=3

# AI Coach Limits
FREE_AI_MESSAGES_DAY=10
PLUS_AI_MESSAGES_DAY=50
PREMIUM_AI_MESSAGES_DAY=200

# Pagination
DEFAULT_PAGE_SIZE=20

# Firebase (Push Notifications)
FCM_TOPIC=aura_updates
```

### 4.3 Flutter Build Variants

Configure `frontend/lib/core/constants/app_config.dart`:

```dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.aurabeauty.ai',
  );

  static const bool enableAICoach = bool.fromEnvironment(
    'ENABLE_AI_COACH',
    defaultValue: true,
  );

  static const int defaultPageSize = 20;
  static const Duration apiTimeout = Duration(seconds: 30);
}
```

---

## 5. Android Deployment

### 5.1 APK Build (Debug)

```bash
cd frontend

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --debug

# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### 5.2 AAB Build (Release - Play Store)

```bash
# Generate keystore (first time only)
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass <store_password> \
  -keypass <key_password>

# Create key.properties
cat > android/key.properties <<EOF
storePassword=<store_password>
keyPassword=<key_password>
keyAlias=upload
storeFile=../android/app/upload-keystore.jks
EOF

# Build release AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### 5.3 Android App Signing

```bash
# Verify signature
jarsigner -verify -verbose -certs \
  build/app/outputs/bundle/release/app-release.aab

# Upload to Google Play Console
# 1. Go to Release > Production > Create new release
# 2. Upload app-release.aab
# 3. Fill in release notes
# 4. Review and rollout
```

---

## 6. iOS Deployment

### 6.1 Prerequisites (macOS only)

```bash
# Install CocoaPods
sudo gem install cocoapods

# Navigate to iOS directory
cd frontend/ios

# Install pods
pod install --repo-update
```

### 6.2 TestFlight Build

```bash
# Build iOS archive
flutter build ios --release --no-codesign

# Open in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Product > Archive
# 2. Distribute App > App Store Connect
# 3. Upload to TestFlight

# Alternative: Fastlane
fastlane beta
```

### 6.3 App Store Submission

```bash
# Build with distribution certificate
flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.aurabeauty.ai

# Archive in Xcode
# Product > Archive > Distribute App > App Store Connect

# Configure in App Store Connect:
# 1. App Information
# 2. Pricing and Availability
# 3. Screenshots (6.7", 6.5", 5.5" displays)
# 4. App Review information
# 5. Version Release (Manual)
```

### 6.4 iOS Info.plist Updates

```xml
<key>NSCameraUsageDescription</key>
<string>Take photos for skin assessment and progress tracking</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Upload progress photos to your profile</string>
<key>NSUserNotificationUsageDescription</key>
<string>Get reminders for your beauty routine</string>
```

---

## 7. Environment Configuration

### 7.1 Production Frappe Configuration (`sites/aura.site/site_config.json`)

```json
{
  "db_name": "aura_production",
  "db_password": "<db_password>",
  "admin_password": "<admin_password>",
  "developer_mode": 0,
  "maintenance_mode": 0,
  "pause_scheduler": 0,
  "max_file_size": 10485760,
  "file_size_limit": 10485760,
  "allow_guests_to_upload_files": 0,
  "deny_all_robots": 0,
  "session_expiry": "360:00",
  "limit_users": 5000,
  "setup_complete": 1,
  "background_jobs": 4,
  "cache_redis_database": 0,
  "redis_cache": "redis://localhost:6379",
  "redis_queue": "redis://localhost:6379",
  "redis_socketio": "redis://localhost:6379",
  "mail_server": "smtp.sendgrid.net",
  "mail_port": 587,
  "use_tls": 1,
  "mail_login": "apikey",
  "mail_password": "<sendgrid_api_key>",
  "auto_email_id": "noreply@aurabeauty.ai",
  "email_sender_name": "Aura Beauty",
  "disable_standard_email_footer": 1,
  "logout_on_password_reset": 0,
  "allow_password_reset_via_email": 1
}
```

### 7.2 Nginx Configuration (`/etc/nginx/sites-available/aura`)

```nginx
upstream frappe {
    server 127.0.0.1:8000 fail_timeout=0;
}

upstream socketio {
    server 127.0.0.1:9000 fail_timeout=0;
}

server {
    listen 80;
    server_name api.aurabeauty.ai;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.aurabeauty.ai;

    ssl_certificate /etc/letsencrypt/live/api.aurabeauty.ai/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.aurabeauty.ai/privkey.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";

    # Max upload size
    client_max_body_size 20M;

    # Gzip
    gzip on;
    gzip_types application/json text/css application/javascript;
    gzip_min_length 1024;

    # API endpoints
    location /api {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://frappe;
    }

    # Static files
    location /assets {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://frappe;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # SocketIO
    location /socket.io {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://socketio;
    }

    # Health check
    location /health {
        return 200 "OK";
        add_header Content-Type text/plain;
    }

    # Deny access to sensitive files
    location ~ (\.env|\.git|node_modules|pycache) {
        deny all;
        return 404;
    }
}
```

### 7.3 Environment Variable Checklist

| Variable | Required | Description |
|---|---|---|
| `FRAPPE_SITE` | Yes | Site name (e.g., `aura.site`) |
| `DB_PASSWORD` | Yes | MariaDB password |
| `REDIS_CACHE` | Yes | Redis connection string |
| `MAIL_PASSWORD` | Yes | SMTP API key |
| `SENTRY_DSN` | No | Error tracking |
| `STRIPE_API_KEY` | Yes | Payment processing |
| `FCM_SERVER_KEY` | Yes | Push notifications |
| `AI_COACH_API_KEY` | Yes | External AI provider key |

---

## 8. Database Migration

```bash
# Run pending migrations
bench --site aura.site migrate

# Check migration status
bench --site aura.site console
>>> frappe.db.get_value("Patch Log", {}, "count")
```

### Migration Best Practices

```bash
# Backup before migration
bench --site aura.site backup --with-files

# Dry-run for patches
bench --site aura.site migrate --dry-run

# Rollback if needed (restore backup)
bench --site aura.site restore \
  sites/aura.site/private/backups/YYYY-MM-DD/aura_site-YYYY-MM-DD.sql.gz

# Clear cache after migration
bench --site aura.site clear-cache
```

---

## 9. CI/CD Pipeline Setup

### 9.1 GitHub Actions (Backend)

```yaml
# .github/workflows/backend-deploy.yml
name: Deploy Backend

on:
  push:
    branches: [main, develop]
    paths:
      - 'backend/aura/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Frappe Server
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd ~/frappe-bench
            git pull origin main
            bench --site aura.site clear-cache
            bench --site aura.site migrate
            bench --site aura.site build --app aura
            bench restart
```

### 9.2 GitHub Actions (Flutter)

```yaml
# .github/workflows/flutter-build.yml
name: Flutter Build & Test

on:
  pull_request:
    branches: [main, develop]
    paths:
      - 'frontend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Run analyzer
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build APK
        run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: aura-app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

### 9.3 Git Workflow

```bash
# Feature branch workflow
git checkout -b feature/assessment-flow
# ... develop ...
git add .
git commit -m "feat(assessment): add skin assessment submission"
git push origin feature/assessment-flow
# Create PR → review → merge to develop

# Release workflow
git checkout develop
git merge --no-ff feature/assessment-flow
git tag v1.0.0-beta.1
git push origin develop --tags
# Deploy to staging

# Production release
git checkout main
git merge --no-ff develop
git tag v1.0.0
git push origin main --tags
```

---

## 10. Monitoring and Logging

### 10.1 Frappe Error Logging

```bash
# View error logs
bench --site aura.site frappe --tail -f logs/error.log

# View scheduler logs
bench --site aura.site frappe --tail -f logs/scheduler.log

# View worker logs
tail -f ~/frappe-bench/logs/web.log
tail -f ~/frappe-bench/logs/worker.log
```

### 10.2 Sentry Integration

```python
# In hooks.py or app __init__.py
import frappe
import sentry_sdk
from sentry_sdk.integrations.frappe import FrappeIntegration

sentry_sdk.init(
    dsn="https://<key>@sentry.io/<project>",
    integrations=[FrappeIntegration()],
    environment="production",
    traces_sample_rate=0.2,
)
```

### 10.3 System Monitoring

```bash
# Install Prometheus + Grafana (optional)
# Monitor:
# - Frappe API response times
# - Database query performance
# - Redis cache hit ratios
# - Background job queue depth
# - Worker memory usage

# Check site health
bench --site aura.site health

# Monitor background jobs
bench --site aura.site show-workers

# Check Redis status
redis-cli ping
redis-cli info stats | grep hits
```

### 10.4 Logging Dashboard

| Log Source | Location | Tool |
|---|---|---|
| Frappe Error | `logs/error.log` | `tail -f` / Sentry |
| Frappe Scheduler | `logs/scheduler.log` | `tail -f` |
| Nginx Access | `/var/log/nginx/access.log` | GoAccess |
| Nginx Error | `/var/log/nginx/error.log` | `tail -f` |
| MariaDB Slow | `/var/log/mysql/mariadb-slow.log` | pt-query-digest |
| System | `journalctl` | systemd |

---

## 11. Backup Strategy

### 11.1 Database Backup

```bash
# Manual backup with files
bench --site aura.site backup --with-files

# Output:
# Database: sites/aura.site/private/backups/YYYY-MM-DD/aura_site-YYYY-MM-DD-HHMMSS.sql.gz
# Files:    sites/aura.site/private/backups/YYYY-MM-DD/aura_site-files-YYYY-MM-DD-HHMMSS.tar.gz
# Config:   sites/aura.site/private/backups/YYYY-MM-DD/aura_site-site_config_backup.json

# Automated backup script
cat > ~/backup-aura.sh <<'SCRIPT'
#!/bin/bash
SITE="aura.site"
BACKUP_DIR="/var/backups/aura"
DATE=$(date +%Y-%m-%d)

cd ~/frappe-bench
bench --site $SITE backup --with-files --backup-path $BACKUP_DIR/$DATE

# Keep only last 30 days
find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} \;

# Upload to S3 (optional)
aws s3 sync $BACKUP_DIR s3://aura-backups/ --delete
SCRIPT

chmod +x ~/backup-aura.sh

# Add to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ubuntu/backup-aura.sh") | crontab -
```

### 11.2 Backup Schedule

| Frequency | What | Retention |
|---|---|---|
| Daily | Full DB + Files | 30 days |
| Weekly | Full DB + Files + Config | 12 weeks |
| Monthly | Full DB + Files + Config | 12 months |
| Pre-migration | Full backup | Until next migration |

### 11.3 Restore Procedure

```bash
# Restore from backup
bench --site aura.site restore \
  /path/to/backup/aura_site-YYYY-MM-DD-HHMMSS.sql.gz \
  --with-public-files /path/to/backup/aura_site-files-YYYY-MM-DD-HHMMSS.tar.gz \
  --with-private-files /path/to/backup/aura_site-files-YYYY-MM-DD-HHMMSS.tar.gz
```

---

## 12. Scaling Recommendations

### 12.1 Vertical Scaling (First Stage)

```bash
# Increase MariaDB resources
sudo tee -a /etc/mysql/mariadb.conf.d/99-aura.cnf <<EOF
innodb_buffer_pool_size = 4G
innodb_log_file_size = 1G
innodb_flush_log_at_trx_commit = 2
query_cache_type = 0
thread_cache_size = 256
max_connections = 200
EOF

# Increase Redis memory
sudo sed -i 's/# maxmemory <bytes>/maxmemory 2gb/' /etc/redis/redis.conf
sudo systemctl restart redis

# Increase Frappe worker count
bench set-config background_jobs 8
```

### 12.2 Horizontal Scaling (Second Stage)

```bash
# Architecture:
# ┌──────────┐     ┌──────────┐     ┌──────────┐
# │  Load    │─────│  App     │─────│  MariaDB │
# │  Balancer│     │  Server 1│     │  Primary  │
# │  (Nginx) │     ├──────────┤     ├──────────┤
# │          │─────│  App     │─────│  MariaDB │
# └──────────┘     │  Server 2│     │  Replica  │
#                  └──────────┘     └──────────┘

# Configure read-write splitting
bench set-config db_type "mariadb"
bench set-config db_host "primary-db.internal"
bench set-config replica_host "replica-db.internal"
```

### 12.3 Caching Strategy

```bash
# Dedicated Redis instances
# 1. Cache (session, API responses)
# 2. Queue (background jobs)
# 3. SocketIO (real-time)

bench set-config redis_cache "redis://cache-redis:6379"
bench set-config redis_queue "redis://queue-redis:6379"
bench set-config redis_socketio "redis://socketio-redis:6379"
```

### 12.4 CDN Configuration

```nginx
# In nginx config - proxy static assets to CDN
location /assets/aura/ {
    proxy_pass https://cdn.aurabeauty.ai/assets/aura/;
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 12.5 Performance Targets

| Metric | Target | Threshold |
|---|---|---|
| API Response Time (p95) | < 200ms | 500ms |
| Database Query Time (p95) | < 50ms | 200ms |
| Recommendation Generation | < 5s | 15s |
| Concurrent Users per Worker | 50 | 100 |
| Daily Active Users (per server) | 10,000 | 20,000 |
| Backup Completion | < 10 min | 30 min |
| Deployment Downtime | < 30s | 5 min |

---

## Appendix: Useful Commands

```bash
# Frappe/Bench
bench --site aura.site console           # Python console
bench --site aura.site migrate           # Run migrations
bench --site aura.site clear-cache       # Clear all caches
bench --site aura.site backup            # Create backup
bench --site aura.site restore <file>    # Restore backup
bench --site aura.site reload-doc <dt> <name>  # Reload doctype
bench build --app aura                   # Build assets
bench start                              # Start dev server

# Flutter
flutter pub get                          # Get dependencies
flutter clean                            # Clean build
flutter build apk --release              # Build APK
flutter build ios --release              # Build iOS
flutter test                             # Run tests
flutter analyze                          # Lint check
dart run build_runner build              # Generate code

# Flutter (local testing)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
flutter run --flavor development
```

---

## Environment Quick Reference

| Environment | Frappe Site | API URL | Flutter Flavor |
|---|---|---|---|
| Local Dev | `aura.site` | `http://localhost:8000` | development |
| Staging | `staging.aurabeauty.ai` | `https://staging-api.aurabeauty.ai` | staging |
| Production | `aura.site` | `https://api.aurabeauty.ai` | production |

---

## Troubleshooting

```
Issue: bench start fails with port in use
Fix:   sudo lsof -i :8000
       kill -9 <PID>
       bench start

Issue: Migration fails with integrity error
Fix:   bench --site aura.site migrate --force
       Or restore from backup

Issue: Flutter build fails with "No such file or directory"
Fix:   flutter clean
       flutter pub get
       dart run build_runner build --delete-conflicting-outputs

Issue: Redis connection refused
Fix:   sudo systemctl status redis
       sudo systemctl restart redis
       redis-cli ping

Issue: MariaDB connection failed
Fix:   sudo systemctl status mariadb
       sudo mysqladmin ping
       Check /etc/mysql/mariadb.conf.d/99-aura.cnf
```
