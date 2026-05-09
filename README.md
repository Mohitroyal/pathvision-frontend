# PathVision OS: Flutter AI Frontend

The premium, real-time mobile and web interface for the PathVision AI Operating System. Built with Flutter, powered by Supabase Cloud.

## 🧬 System Architecture

PathVision OS uses a high-performance, reactive architecture:

- **lib/repositories**: Enterprise-grade data access layer for Supabase.
- **lib/providers**: Reactive state management with real-time stream listeners.
- **lib/realtime**: Centralized orchestration for all Supabase subscriptions.
- **lib/ai**: Integrated Jarvis AI engine with Groq LPU support.
- **lib/models**: Strongly-typed data structures for system-wide integrity.

## 🚀 Getting Started

### 1. Environment Configuration
Copy `.env.example` to `.env` (or use `api_config.dart`) and configure your Supabase URL and Anon Key.

### 2. Dependencies
```bash
flutter pub get
```

### 3. Run Production Build
```bash
flutter run --release
```

## 🧠 Neural Features
- **Real-time Sync**: Zero-latency updates across Tasks, Projects, and Finance.
- **Jarvis Assistant**: Integrated voice/text AI for system control.
- **Risk Radar**: Live visualization of system-detected project threats.
- **Unified Planner**: A dynamic, cloud-synced daily schedule.

## 🛡️ Security
- Secure session persistence via Supabase Auth.
- Environment-driven configuration.
- Encrypted data streams.
