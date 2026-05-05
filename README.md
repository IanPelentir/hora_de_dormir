# Sleep Tracker App 🌙

A production-ready Flutter application designed to track user sleep sessions with a strong focus on LGPD compliance, secure authentication, and a clean Model-View-Controller (MVC) architecture.

## 🎯 Problem Solved
People need a simple, reliable way to record their sleep patterns. However, privacy is a major concern. This app solves the problem by providing an intuitive interface to start and end sleep sessions while explicitly complying with the General Data Protection Law (LGPD), ensuring users know exactly how their data is used and stored.

## 👥 Target Audience
Individuals who want to monitor their sleep duration and history in a secure environment without their data being shared or sold.

## 🏗️ Architecture (MVC)
The project is built using the **Model-View-Controller (MVC)** architectural pattern, strictly separating logic, state, and UI.

- **Models (`lib/models/`)**: Defines data structures (e.g., `SleepModel` with `toMap` and `fromMap` serialization).
- **Views (`lib/views/`)**: Pure UI components built with Flutter. They react to state changes using `Provider`.
- **Controllers (`lib/controllers/`)**: Handles the business logic (e.g., `SleepController` calculating durations and interacting with services).
- **Providers (`lib/providers/`)**: Manages the application state (e.g., `SleepProvider`, `AuthProvider`), bridging Controllers and Views.
- **Services (`lib/services/`)**: Handles external integrations like Firebase.

## ☁️ Backend (Firebase)
- **Authentication**: Firebase Auth handles user sign-in securely.
- **Database**: Cloud Firestore is used to persist `sleep_records`. Each document is securely tied to a `userId`.

## 🧠 State Management (Provider)
We use the `provider` package. `MultiProvider` at the root of the app injects `AuthProvider` and `SleepProvider`. Views use `context.watch()` to listen to state changes dynamically without manual `setState` calls.

## ⚖️ LGPD Compliance
Before accessing the app, users are forced to read and agree to the Terms of Use and Privacy Policy (`TermsView`).
- **Data transparency**: Explains that only email, sleep start/end, and duration are collected.
- **Data protection**: Explicitly states no data selling or third-party sharing.
- **Consent persistence**: `SharedPreferences` saves the consent locally.

## 🎬 UI & Animations
Rive animations (`.riv`) are integrated for modern, smooth UX:
- Loading states
- Empty history states
- Dynamic sleeping/awake states (`sleep.riv` / `awake.riv`)

## 🚀 How to Run

1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. **Important - Firebase Configuration**: 
   - Add your `google-services.json` to `android/app/`.
   - Add your `GoogleService-Info.plist` to `ios/Runner/`.
4. Run the app:
   ```bash
   flutter run
   ```
