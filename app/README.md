# Neara - Voice-First Emergency Help App

An AI-powered Flutter application for connecting users with local service workers (mechanics, plumbers, electricians, maids) through voice-first emergency assistance.

## 🎯 Project Overview

Neara is a voice-first emergency help platform designed for the Indian market. Users can describe their emergency using voice or text, and the app uses Google Gemini AI to interpret the request, extract key details (service type, location, urgency), and connect them with nearby verified workers.

## ✅ Completed Features

### 🎤 Voice Agent Screen
- **Voice Input**: Real-time speech-to-text transcription using `speech_to_text` package
- **Text Input**: Alternative text input with transparent glass-morphic design
- **AI Processing**: Live Gemini AI analysis showing extracted information as user speaks
- **Confirmation Dialog**: User confirms extracted details before searching:
  - Service category (mechanic, plumber, electrician, maid, other)
  - Location hint (GPS-based or spoken location)
  - Urgency level (low, medium, high)
  - Issue summary
- **UI/UX**: 
  - Dark gradient theme (#0F172A → #020617)
  - Floating app bar with greeting
  - 2×2 quick action cards (Emergency help, Browse services, My requests, Safety & SOS)
  - Bottom input bar with integrated mic button
  - Modal listening panel with animated mic and live transcription

### 🤖 AI Integration
- **Gemini AI Service**: Uses `gemini-pro` model for natural language understanding
- **Environment Variables**: API key stored securely in `.env` file (not committed to git)
- **Emergency Interpretation**: Extracts structured data from voice/text input:
  ```dart
  {
    "issueSummary": "pipe burst in bathroom",
    "urgency": "high",
    "locationHint": "NH4 near City Center",
    "serviceCategory": "plumber"
  }
  ```
- **GPS Integration**: Captures user location using `geolocator` package

### 🔍 Worker Discovery Screen
- **Mock Worker Data**: 20+ pre-populated workers with realistic profiles
- **Filtering System**:
  - Service category (auto-applied from AI interpretation)
  - Distance radius (km)
  - Minimum rating
  - Verified workers only
  - Gender preference
- **Worker Cards**: Display name, service, rating, distance, verification status
- **Navigation**: Seamless flow from voice input → AI analysis → confirmation → worker list

### 🏗️ Architecture
- **State Management**: Riverpod (Provider-based)
- **File Structure**:
  ```
  lib/
  ├── core/
  │   ├── ai/
  │   │   ├── gemini_service.dart (AI interpretation)
  │   │   └── ai_providers.dart (Riverpod state management)
  │   └── theme/
  │       └── app_theme.dart
  ├── features/
  │   ├── voice_agent/
  │   │   └── presentation/
  │   │       └── voice_agent_screen.dart
  │   └── discovery/
  │       ├── data/
  │       │   └── worker_providers.dart (mock data)
  │       └── presentation/
  │           └── worker_discovery_screen.dart
  └── shared/
      └── widgets/
  ```

## 🚧 Mock/Stub Components

### Currently Mocked:
1. **Worker Data**: All 20+ workers are hardcoded mock data in `worker_providers.dart`
2. **Worker Profiles**: Detailed profile screen not implemented
3. **Job Requests**: Request tracking UI exists but no actual job creation
4. **Live Tracking**: Navigation to tracking screen exists but tracking not implemented
5. **Safety Features**: SOS, share session, and high-trust filters are stubs
6. **Worker Onboarding**: No worker registration or profile management
7. **Payment System**: No payment integration
8. **Chat/Messaging**: No communication system between users and workers
9. **Notifications**: No push notifications or real-time updates
10. **Map View**: Google Maps integration exists but worker pins not implemented

## 📋 To-Do List

### High Priority
- [ ] **Emergency Fallback Flow**: Quick category selection when voice fails + GPS-based auto-matching
- [ ] **Normal Browse Flow Refinement**:
  - Category selection screen
  - Advanced filters UI
  - Worker detailed profile page (bio, reviews, portfolio photos)
  - Sort options (rating, distance, price)

### Medium Priority
- [ ] **Map View Implementation**:
  - Display workers as pins on Google Maps
  - Cluster nearby workers
  - Tap pin to show worker quick info
  - Navigate to profile from map
- [ ] **Basic Worker Onboarding**:
  - Registration form (mock)
  - Profile creation
  - Service selection
  - Document upload simulation
- [ ] **Job Request Handling**:
  - Create job request from worker profile
  - Request details form (description, images, time preference)
  - Mock job status updates
  - Request history screen

### Low Priority
- [ ] **Safety Features**:
  - SOS button functionality (mock)
  - Share live session with emergency contact
  - High-trust worker filter hooks
  - Background location tracking
- [ ] **Performance Optimization**:
  - Image caching for worker photos
  - Lazy loading for long worker lists
  - Reduce Gemini API calls (debouncing)
- [ ] **Testing**:
  - Unit tests for AI interpretation
  - Widget tests for screens
  - Integration tests for complete flows

### Future Enhancements
- [ ] Real backend API integration
- [ ] User authentication (phone OTP)
- [ ] Real-time chat with workers
- [ ] Payment gateway integration
- [ ] Push notifications
- [ ] Worker availability calendar
- [ ] Price quotes and negotiation
- [ ] Review and rating system (functional)
- [ ] Multiple language support (Hindi, regional languages)

## 🔄 Key Workflows

### 1. Emergency Voice-First Flow
```
User Opens App
  ↓
Voice Agent Screen (Home)
  ↓
User Taps Mic / Speaks → Real-time transcription
  ↓
Gemini AI analyzes → Shows extracted info live
  ↓
User Taps "Done" → Confirmation dialog appears
  ↓
User Reviews:
  - Service: PLUMBER
  - Location: Current location
  - Urgency: HIGH
  - Issue: pipe burst
  ↓
User Taps "Find Workers"
  ↓
Worker Discovery Screen (filtered by service)
  ↓
User Selects Worker → (Future: Profile → Book → Track)
```

### 2. Text Input Flow
```
User Opens App
  ↓
Types in bottom input bar: "need electrician"
  ↓
Taps send / Enter → Shows loading
  ↓
Gemini interprets → Auto-applies filters
  ↓
Worker Discovery Screen (filtered results)
```

### 3. Browse Flow (Current)
```
User Opens App
  ↓
Taps "Browse services" quick action
  ↓
Worker Discovery Screen (all workers)
  ↓
User applies filters manually (not yet refined)
```

## 🔧 Technical Stack

### Core Dependencies
- **Flutter SDK**: ^3.9.2
- **flutter_riverpod**: ^2.5.1 (State management)
- **google_generative_ai**: ^0.4.6 (Gemini AI)
- **speech_to_text**: ^7.3.0 (Voice recognition)
- **geolocator**: ^13.0.1 (GPS location)
- **flutter_dotenv**: ^5.1.0 (Environment variables)
- **google_maps_flutter**: ^2.9.0 (Map integration)
- **google_fonts**: ^6.2.1 (Typography)

### Configuration Files
- **.env**: Contains `GEMINI_API_KEY` (gitignored)
- **pubspec.yaml**: Flutter dependencies
- **analysis_options.yaml**: Dart linter rules

## 🚀 Running the Project

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Create `.env` file in project root
   - Add your Gemini API key:
     ```
     GEMINI_API_KEY=your_api_key_here
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms
- ✅ Android
- ✅ iOS
- ⚠️ Web (limited - voice input may not work)
- ⚠️ Desktop (not tested)

## 🔐 Security Notes

- API keys are stored in `.env` file (never commit this!)
- `.gitignore` includes `.env` to prevent accidental commits
- GPS permissions requested at runtime
- Microphone permissions requested when needed

## 🎨 Design System

### Colors
- **Background Gradient**: `#0F172A` → `#020617`
- **Primary Accent**: `#4F46E5` (Indigo)
- **Secondary Accent**: `#EC4899` (Pink)
- **Tertiary Accent**: `#FBBF24` (Yellow)
- **Text Primary**: `#FFFFFF`
- **Text Secondary**: `#9CA3AF`
- **Card Background**: `#1F2937` / `#1E293B`
- **Border**: `#334155` (subtle)

### Typography
- Using Google Fonts (system default for now)
- Title: 18-20px, Bold
- Body: 14-16px, Regular
- Caption: 12-13px, Regular

## 🐛 Known Issues

1. **Voice Recognition**: May stop after one word if `ListenMode.confirmation` doesn't work properly
2. **Gemini API**: Rate limiting may cause errors during testing
3. **GPS**: Location permission must be granted manually in device settings
4. **Mock Data**: Worker distances are hardcoded, not calculated from actual GPS

## 📝 Notes

- This is a **prototype/MVP** with heavy use of mock data
- Real backend integration is not implemented
- Focus is on demonstrating the voice-first UX flow
- Worker data, tracking, payments are simulated

## 🤝 Contributing

This is an internal project. For questions or contributions, contact the development team.

## 📄 License

[Add license information here]

---

**Last Updated**: January 10, 2026  
**Version**: 0.1.0  
**Status**: MVP / Prototype
