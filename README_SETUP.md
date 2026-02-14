# Society Voting System - Setup Guide

## Overview
This is a Flutter-based voting system for gated society elections, powered by SupaBase backend.

## Prerequisites
- Flutter SDK (>=3.0.0)
- SupaBase account
- Android Studio / VS Code with Flutter extensions

## SupaBase Setup

### 1. Create a SupaBase Project
1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down your project URL and anon key

### 2. Run Database Schema
1. Open your SupaBase project dashboard
2. Go to SQL Editor
3. Run the contents of `database/schema.sql`
4. Run the contents of `database/rls_policies.sql`

### 3. Create Storage Bucket
1. Go to Storage in SupaBase dashboard
2. Create a new bucket named `candidate-photos`
3. Set it to **public** for photo access

### 4. Configure the App
1. Open `lib/core/constants/supabase_constants.dart`
2. Replace `YOUR_SUPABASE_PROJECT_URL` with your project URL
3. Replace `YOUR_SUPABASE_ANON_KEY` with your anon key

## Flutter Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   └── constants/
│       └── supabase_constants.dart    # SupaBase configuration
├── data/
│   └── models/
│       └── user_model.dart            # User data model
├── services/
│   └── auth_service.dart              # Authentication logic
└── presentation/
    └── screens/
        └── registration_screen.dart   # User registration UI
```

## Database Schema

### Users Table
- Stores user information (name, block, flat, phone, email)
- Tracks voting status per user
- Enforces unique phone numbers

### Candidates Table
- Stores candidate information
- Requires admin approval before visibility
- Categories: President, Secretary, Treasurer

### Votes Table
- Records all votes
- Enforces one vote per category per user
- Prevents duplicate voting from same flat

## Security Features

✅ Row-Level Security (RLS) enabled on all tables  
✅ Phone number uniqueness validation  
✅ One vote per flat enforcement via database trigger  
✅ Candidate approval workflow  
✅ Immutable vote records  

## Next Steps

After completing Issue #1 setup:
- Issue #2: Implement candidate module and voting UI
- Issue #3: Build admin panel for oversight

## Troubleshooting

### SupaBase Connection Issues
- Verify your URL and anon key are correct
- Check internet connection
- Ensure RLS policies are properly set

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Support
For issues or questions, please refer to the GitHub repository issues section.
