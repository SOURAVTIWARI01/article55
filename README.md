<div align="center">

# 🗳️ Article 55 – Fair Electoral System

**A production-grade, secure Flutter voting app for gated societies**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/State-Provider-6.1.2-8E44AD)](.)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![Material 3](https://img.shields.io/badge/Design-Material%203-6750A4?logo=materialdesign&logoColor=white)](https://m3.material.io/)

*Phone login • Candidate management • One-vote-per-flat • Live results • Admin approval • Glassmorphism UI*

</div>

---

## 🎯 Overview

Article 55 is a clean-architecture Flutter app that enables **secure, transparent digital voting** for gated societies and residential communities. The system covers the entire electoral pipeline — from candidate registration and admin approval to category-based voting with one-vote-per-flat enforcement and real-time live results.

---

## 📸 App Preview

| Splash Screen | Login Screen | Registration | User Dashboard | Admin Dashboard |
|---|---|---|---|---|
| ![Splash](article_55_screens/article_55_splash_screen/screen.png) | ![Login](article_55_screens/article_55_login_screen/screen.png) | ![Register](article_55_screens/article_55_registration_screen/screen.png) | ![User](article_55_screens/article_55_user_dashboard/screen.png) | ![Admin](article_55_screens/article_55_admin_dashboard/screen.png) |

---

## 🏗️ App Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Flutter App UI                                │
│  Splash → Login ─┬→ User Dashboard ─┬→ Voting Screen (3 categories)       │
│                  │                  ├→ Candidate Form → Awaiting Approval  │
│                  │                  └→ Live Results (animated counters)    │
│                  └→ Admin Dashboard ─┬→ Candidate Approval Panel          │
│           ↕                          └→ Live Results                      │
│      Registration                                                         │
└──────────────────────────────────┬────────────────────────────────────────┘
                                   │
                     Provider State Layer
            (AuthProvider, CandidateProvider, VotingProvider, AdminProvider)
                                   │
                   ┌───────────────┼───────────────┐
                   │               │               │
             AuthService    CandidateService   VotingService
          (login/register)  (CRUD/approval)   (atomic votes/
                   │               │            realtime)
                   └───────────────┼───────────────┘
                                   │
                             Supabase DB
                   (users + candidates + votes tables)
                     RLS policies · cast_vote RPC
```

---

## ✨ Features

### 🔐 Authentication & Registration
- Phone number + passcode login (no OTP required)
- Role-based routing: `user` → User Dashboard, `admin` → Admin Dashboard
- Resident registration with name, block, flat, phone, email
- Phone and flat number uniqueness enforced at app + DB level
- Secure session handling with logout
- Demo mode for local testing without Supabase

### 🏛️ Candidate Management
- **Run for Office** — users submit their candidature (name, category, summary)
- Live word count on summary field (max 300 words)
- Category selection: President, Secretary, Treasurer
- Candidates saved as `is_approved = false` until admin reviews
- Success screen shows "Awaiting Admin Approval" status

### ✅ Admin Approval Panel
- View all pending candidates with category badges
- One-tap approve / reject buttons
- Pending count badge in top bar
- Empty state when all candidates are reviewed
- Only accessible to `admin` role

### 🗳️ Voting System
- **Category-based tabs**: President · Secretary · Treasurer
- Approved candidates displayed as premium cards
- **Single-select mode**: pick one candidate per category
- Confirmation dialog before casting vote
- One-vote-per-flat-per-category enforced at DB level (`UNIQUE` constraint)
- Duplicate vote attempts blocked with clear error messaging
- **Atomic vote casting** via Supabase RPC transaction
- "Already voted" badge per category after casting

### 📊 Live Results Dashboard
- Real-time vote counts updated via Supabase Realtime subscriptions
- Animated progress bars with percentage counters
- Candidates ranked by vote count with trophy badge for leader
- Category tabs to switch between President/Secretary/Treasurer results
- Green "Updating in real-time" indicator

### 📊 User Dashboard
- Dynamic greeting based on time of day
- Verified Voter badge
- Active polls summary card (navigates to Voting Screen)
- **Quick Actions**: "Cast Your Vote" + "Run for Office" gradient cards
- Horizontally scrollable Recent Polls carousel
- Community Active members section
- Custom bottom navigation bar

### 🛡️ Admin Dashboard
- Gradient "Admin Control" header with notification bell
- Stats grid: Total Votes + Turnout percentage
- **Quick Actions**: "Candidates" (→ Approval Panel) + "Results" (→ Live Results)
- Scrollable chip row: Reports, Audit Logs, Config
- Live Monitoring cards with progress bars and status badges
- Floating bottom nav with elevated FAB button

### 🎨 Premium Design System
- Material 3 with Plus Jakarta Sans + Cinzel typography
- Glassmorphism cards with translucent backgrounds
- Smooth fade+slide page transitions across all screens
- Dark theme support
- Custom reusable widgets:
  - `GradientButton` — Full-width gradient CTA with loading spinner
  - `CustomTextField` — Glassmorphic input with prefix icon
  - `AnimatedCard` — Fade-in-up animated container
  - `LoadingIndicator` — Three-dot staggered animation
  - `RoleBadge` — User/Admin role display
  - `CandidateCard` — Candidate avatar, name, summary, trailing action
  - `VoteButton` — Animated button with selected/disabled/count states
  - `CategoryTabBar` — Segmented control for election categories

---

## 🛠️ Technology Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (latest stable, null-safe) |
| **State Management** | Provider (4 providers) |
| **Backend / Auth** | Supabase (Postgres + Auth + Realtime) |
| **Database** | PostgreSQL with Row Level Security |
| **Typography** | Google Fonts (Plus Jakarta Sans, Cinzel) |
| **Architecture** | Clean Architecture (models → services → providers → screens) |
| **Design** | Material 3, Glassmorphism, Gradient animations |

---

## 📁 Project Structure

```text
lib/
 ├── main.dart                              # Entry point + dotenv load
 ├── app.dart                               # MaterialApp + 9 routes + 4 Providers
 ├── config/
 │   └── env_config.dart                    # Reads .env via flutter_dotenv
 ├── core/
 │   ├── constants/
 │   │   ├── app_colors.dart                # Color palette + 5 gradients
 │   │   └── app_strings.dart               # All UI strings (70+)
 │   ├── theme/
 │   │   └── app_theme.dart                 # Light + Dark themes + page transitions
 │   └── utils/
 │       └── validators.dart                # Phone, name, flat, email validators
 ├── models/
 │   ├── user_model.dart                    # User model + JSON serialization
 │   ├── candidate_model.dart               # Candidate model + JSON serialization
 │   └── vote_model.dart                    # Vote model + VoteCount aggregate
 ├── services/
 │   ├── supabase_service.dart              # Supabase client init
 │   ├── auth_service.dart                  # Login / register / sign out + demo mode
 │   ├── candidate_service.dart             # Candidate CRUD + admin approval + demo mode
 │   └── voting_service.dart                # Atomic voting + counts + realtime + demo mode
 ├── providers/
 │   ├── auth_provider.dart                 # Auth state (ChangeNotifier)
 │   ├── candidate_provider.dart            # Candidate creation state
 │   ├── voting_provider.dart               # Voting state + realtime subscription
 │   └── admin_provider.dart                # Pending candidates + approve/reject
 ├── screens/
 │   ├── splash_screen.dart                 # Animated splash + auto-navigate
 │   ├── login_screen.dart                  # Phone + passcode + role routing
 │   ├── registration_screen.dart           # Multi-field form + validation
 │   ├── user_dashboard_screen.dart         # Polls, quick actions, community
 │   ├── admin_dashboard_screen.dart        # Stats, actions, monitoring
 │   ├── candidate_form_screen.dart         # Run for Office form + success screen
 │   ├── admin_approval_screen.dart         # Pending candidate review panel
 │   ├── voting_screen.dart                 # Category-tabbed single-select voting
 │   └── results_screen.dart                # Live animated results dashboard
 └── widgets/
     ├── custom_text_field.dart             # Glassmorphic input field
     ├── gradient_button.dart               # Gradient CTA with loading state
     ├── animated_card.dart                 # Fade-in-up animated container
     ├── loading_indicator.dart             # Three-dot staggered animation
     ├── role_badge.dart                    # User/Admin role badge
     ├── candidate_card.dart                # Candidate info card with actions
     ├── vote_button.dart                   # Animated vote button
     └── category_tab_bar.dart              # President/Secretary/Treasurer tabs
```

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Supabase project (optional — demo mode works without it)

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Configure environment

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
DEMO_MODE=true
```

> Set `DEMO_MODE=false` once your Supabase project is configured.

### 3) Setup Supabase database (optional)

Run the SQL files in the Supabase SQL Editor:

1. **`schema.sql`** — Creates the `users` table with RLS and seed data
2. **`schema_phase2.sql`** — Creates the `candidates` and `votes` tables with:
   - `candidate_category` and `vote_type` enums
   - `UNIQUE(flat_number, category)` constraint for one-vote-per-flat
   - Full RLS policies (user privacy, admin access, vote immutability)
   - `cast_vote` RPC function for atomic vote transactions
   - `vote_counts` view for aggregated results
   - Pre-approved seed candidates (2 per category)

### 4) Run app

```bash
flutter run
```

---

## 🔑 Demo Credentials

| Role | Phone | Password |
|---|---|---|
| 👤 User | `9335946391` | `user@test` |
| 🛡️ Admin | `8947043315` | `admin@test` |

### Demo Mode Includes
- 6 pre-approved candidates (2 per category)
- Full voting flow with in-memory vote storage
- One-vote-per-flat enforcement
- Live vote count tracking
- Admin approval workflow (all candidates pre-approved)

---

## 🔐 Security

| Constraint | Enforcement Layer |
|---|---|
| One vote per flat per category | DB `UNIQUE(flat_number, category)` constraint |
| Atomic vote casting | `cast_vote` RPC with transaction |
| Only approved candidates votable | RPC validates `is_approved = TRUE` |
| User-flat ownership | RPC validates `users.flat_number` match |
| Vote immutability | No UPDATE RLS policy — votes cannot be changed |
| Voter privacy | Users can only see their own votes |
| Admin-only approval | RLS checks `role = 'admin'` for candidate updates |
| Phone/flat uniqueness | App + DB level dual enforcement |
| Secrets protection | `.env` in `.gitignore` |

---

## 🧪 Quality Checks

```bash
flutter analyze    # Static analysis — 0 issues ✅
flutter test       # Unit & widget tests
```

---

## 🗺️ Roadmap

- [x] Authentication, registration, and role-based access
- [x] Premium UI/UX with glassmorphism design system
- [x] User and Admin dashboards
- [x] Candidate management with admin approval workflow
- [x] Category-based voting (President, Secretary, Treasurer)
- [x] One-vote-per-flat enforcement with atomic transactions
- [x] Live results dashboard with animated counters
- [x] Real-time vote updates via Supabase Realtime
- [x] Demo mode for offline testing
- [ ] Push notifications for vote status and results
- [ ] Biometric authentication
- [ ] PDF report generation
- [ ] Multi-society support
- [ ] Audit log viewer

---

## � Screen Routes

| Route | Screen | Access |
|---|---|---|
| `/` | Splash Screen | All |
| `/login` | Login Screen | All |
| `/register` | Registration Screen | All |
| `/user-dashboard` | User Dashboard | User |
| `/admin-dashboard` | Admin Dashboard | Admin |
| `/candidate-form` | Run for Office Form | User |
| `/admin-approval` | Candidate Approval Panel | Admin |
| `/voting` | Voting Screen | User |
| `/results` | Live Results Dashboard | All |

---

<div align="center">

**Built for secure, transparent, and fair digital voting in gated communities.**

Made with ❤️ using Flutter & Supabase

</div>
