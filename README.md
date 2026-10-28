# 💪 Gym Manager App — Flutter

A complete gym owner management app built in Flutter/Dart with a dark, energetic UI.

---

## 📱 Screens & Features

| Screen | Features |
|--------|----------|
| **Dashboard** | Live stats (active/expired/expiring members), monthly revenue, total dues, expiry alerts, recent members |
| **Members** | Search, filter (All/Active/Expired/Expiring), add members, view profiles |
| **Member Detail** | Full profile, membership info, payment history, add payment, renew membership, delete |
| **Fees** | Revenue overview, pending dues list, full payment history |
| **Plans** | Create/edit/delete membership plans with color, duration, features |
| **Fee Calculator** | Plan-based fee calculator with discount, extra fees, advance payment, balance due + built-in numpad calculator |
| **Gym Info** | Gym name, owner, contact, address, timings, working days, GST, social links |

---

## 🚀 Setup

### 1. Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0

### 2. Create a new Flutter project and replace files

```bash
flutter create gym_manager
cd gym_manager
```

Copy all files from this package into the project, replacing existing ones.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run
```

---

## 📦 Dependencies

```yaml
provider: ^6.1.2          # State management
shared_preferences: ^2.2.2 # Local data persistence
uuid: ^4.2.1               # Unique IDs
intl: ^0.19.0              # Number/date formatting
fl_chart: ^0.67.0          # Charts (optional, for future analytics)
```

---

## 🗂 Project Structure

```
lib/
├── main.dart                        # App entry point
├── models/
│   ├── member.dart                  # Member + PaymentRecord models
│   ├── plan.dart                    # Membership plan model
│   └── gym_info.dart                # Gym details model
├── utils/
│   ├── app_theme.dart               # Dark theme + colors
│   ├── app_state.dart               # ChangeNotifier state
│   └── data_store.dart              # SharedPreferences persistence
└── screens/
    ├── main_shell.dart              # Bottom nav shell
    ├── dashboard/dashboard_screen.dart
    ├── members/
    │   ├── members_screen.dart
    │   ├── add_member_screen.dart
    │   └── member_detail_screen.dart
    ├── fees/fees_screen.dart
    ├── plans/plans_screen.dart
    ├── calculator/calculator_screen.dart
    └── info/gym_info_screen.dart
```

---

## 🎨 Design

- **Theme**: Dark navy + vibrant orange (`#FF6B35`)
- **Status colors**: Green (active), Red (expired), Orange (expiring soon)
- **All data stored locally** on device via SharedPreferences (no internet needed)

---

## ➕ Extending the App

- **Notifications**: Add `flutter_local_notifications` for expiry reminders
- **PDF receipts**: Add `pdf` + `printing` packages to generate fee receipts
- **Charts**: Use `fl_chart` (already in pubspec) for revenue analytics
- **Backup**: Add Google Drive or Firebase sync
- **Photo**: Add `image_picker` for member profile photos
