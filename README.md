# ⚡ Pulse — Fitness Tracker

A premium, dark-themed fitness tracking app built with Flutter and Clean Architecture. Track workouts, steps, calories, and hydration — all stored locally with zero backend dependency.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)
![Bloc](https://img.shields.io/badge/State-flutter__bloc-7C4DFF?style=flat)
![SQLite](https://img.shields.io/badge/Database-sqflite-003B57?style=flat&logo=sqlite&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)

---

## ✨ Features

- **Dashboard** — animated step ring, calories burned, active minutes, hydration tracker, today's workout list
- **Log Workout** — add activities (running, cycling, gym, yoga, swimming, walking) with duration, calories, steps, and notes
- **History** — full workout log grouped by date, swipe-to-delete
- **Analytics** — weekly calories and steps charts (fl_chart), goal-hit summary
- **Profile** — editable daily goals (steps / calories / water), weekly stats overview, reset all data
- 100% offline — all data persisted locally with SQLite
- Dark UI with a volt green (`#CCFF00`) accent throughout

---

## 📱 Screens

| Dashboard | History | Analytics | Profile |
|:---:|:---:|:---:|:---:|
| Step ring, stats, hydration | Grouped workout log | Weekly charts | Goals & settings |

*(Add your own screenshots here)*

---

## 🏗 Architecture

Pulse follows **Clean Architecture (Layer-First)** with strict separation of concerns:

```
lib/
├── core/                      # Theme, colors, constants
├── domain/                    # Pure Dart — no Flutter, no SQLite
│   ├── entities/               # Workout, StepEntry, WaterEntry
│   └── repositories/           # Abstract repository contract
├── data/                      # Implementation details
│   ├── models/                 # toMap / fromMap mappers
│   ├── datasources/             # Raw SQLite queries
│   └── repositories/           # Concrete repository implementation
└── presentation/              # UI layer
    ├── blocs/                  # FitnessBloc, WorkoutBloc
    ├── router/                  # go_router configuration
    └── screens/                 # Dashboard, History, Analytics, Profile, Log Workout
```

**Dependency rule:** `presentation → domain ← data`. The domain layer has zero knowledge of Flutter or SQLite — it could run in a pure Dart environment unchanged. The `data` layer implements the `domain` contracts, and `presentation` only ever talks to `domain`.

This means swapping SQLite for Firebase, for example, would only require rewriting the `data` layer — the Bloc and UI code stay untouched.

---

## 🛠 Tech Stack

| Layer | Tool |
|---|---|
| State management | `flutter_bloc` + `equatable` |
| Navigation | `go_router` |
| Local database | `sqflite` + `path_provider` |
| Charts | `fl_chart` |
| Persistence (settings) | `shared_preferences` |
| UI | `percent_indicator` |
| Utilities | `uuid`, `intl` |
| Font | Plus Jakarta Sans |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.10
- Dart SDK ≥ 3.0
- Android Studio / Xcode for emulator or physical device

### Installation

```bash
# Clone the repo
git clone https://github.com/abdelrahmansaed1/pulse-fitness-app.git
cd pulse-fitness-app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Fonts

Download [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans) and place the following files in `assets/fonts/`:

```
PlusJakartaSans-Regular.ttf
PlusJakartaSans-Medium.ttf
PlusJakartaSans-Bold.ttf
PlusJakartaSans-ExtraBold.ttf
```

---

## 🗄 Database Schema

```sql
CREATE TABLE workouts (
  id               TEXT PRIMARY KEY,
  activity_type    TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  calories         REAL NOT NULL,
  steps            INTEGER NOT NULL DEFAULT 0,
  notes            TEXT NOT NULL DEFAULT '',
  date             TEXT NOT NULL
);

CREATE TABLE daily_steps (
  date  TEXT PRIMARY KEY,
  steps INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE water_log (
  date      TEXT PRIMARY KEY,
  amount_ml INTEGER NOT NULL DEFAULT 0
);
```

---

## 🎨 Design Tokens

```dart
volt        = Color(0xFFCCFF00)  // primary accent
bgPrimary   = Color(0xFF08080A)
bgCard      = Color(0xFF111114)
bgElevated  = Color(0xFF1A1A1F)
border      = Color(0xFF27272A)
textPrimary   = Color(0xFFFFFFFF)
textSecondary = Color(0xFFA1A1AA)
textMuted     = Color(0xFF52525B)
```

---

## 📌 Roadmap

- [ ] Charts for monthly / yearly trends
- [ ] Export workout history to CSV
- [ ] Optional cloud sync (Firebase)
- [ ] Workout reminders / notifications
- [ ] Light theme support

---

## 👤 Author

**Abdelrahman Saed**
GitHub: [@abdelrahmansaed1](https://github.com/abdelrahmansaed1)

Built as part of a Flutter development internship at **CodeAlpha**.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
