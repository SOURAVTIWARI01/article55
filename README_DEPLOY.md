# Society Voting System - Firebase Deployment Guide

This project is a production-ready digital voting system built with Flutter and Firebase.

## Prerequisites
- Flutter SDK (>= 3.0.0)
- Firebase Account
- Google Sheets API (for exports, optional)

## Setup Instructions

### 1. Firebase Console Setup
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** and activate **Phone** sign-in (OTP).
3. Create a **Cloud Firestore** database in "Production Mode".
4. Enable **Firebase Storage**.
5. Add your apps (Android, iOS, Web) and download the configuration files:
   - `google-services.json` (Android) -> Place in `android/app/`
   - `GoogleService-Info.plist` (iOS) -> Place in `ios/Runner/`
   - Web Config -> Initialize in `lib/main.dart` if using web.

### 2. Security Rules
Deploy the rules provided in the root directory:
```bash
firebase deploy --only firestore:rules,storage:rules
```

### 3. Local Development
```bash
cd society_voting_firebase
flutter pub get
flutter run
```

## Security Features
- **OTP Verification**: Mandatory for all voters.
- **Flat Uniqueness**: Enforced via Firestore transactions and unique ID construction (`Block_Flat`).
- **Audit Logs**: All admin actions (approvals, deletions) should be logged in the `audit_logs` collection.
- **Vote Locking**: The `hasVoted` flag in the user document prevents session re-entry.

## Admin Roles
To grant admin access, manually change the `role` field from `'voter'` to `'admin'` in the user's Firestore document.

## Support
For technical issues, contact the system administrator.
