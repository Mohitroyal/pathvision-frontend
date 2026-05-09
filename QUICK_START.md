# JARVIS OS Flutter - Quick Start Guide

## 🚀 Get Running in 5 Minutes

### Step 1: Install Flutter
```bash
# Download from https://flutter.dev/docs/get-started/install
# Verify installation
flutter doctor
```

### Step 2: Navigate & Setup
```bash
cd flutter_project
flutter pub get
```

### Step 3: Run the App
```bash
# On emulator
flutter run

# On web
flutter run -d chrome

# On physical device
flutter run
```

That's it! The app should now be running. 🎉

---

## 📖 Project Overview

This is a **pixel-perfect Flutter replication** of JARVIS OS - a personal & company operating system with:

- ✨ **Dark Theme** - Premium black backgrounds with gold accents
- 📱 **Responsive** - Works on mobile, tablet, and desktop
- 🎨 **Design System** - 30+ colors, 3 fonts, 8px spacing grid
- 🧩 **20+ Widgets** - Reusable, composition-based UI components
- 📊 **4 Screens** - Dashboard, Finance, Tasks, AI Assistant

---

## 📁 Key Files to Know

```
lib/
├── main.dart                    # App entry point
├── theme/
│   ├── jarvis_colors.dart       # All color constants
│   └── jarvis_theme.dart        # Material theme config
├── widgets/                     # 20+ reusable components
│   ├── jarvis_card.dart         # Card component family
│   ├── jarvis_chip.dart         # Status badges
│   ├── jarvis_topbar.dart       # App bar
│   ├── jarvis_kpi.dart          # Metrics display
│   ├── jarvis_ai_orb.dart       # Animated orb
│   ├── jarvis_sidebar.dart      # Desktop nav
│   └── jarvis_widgets.dart      # Utility widgets
└── screens/                     # 4 main screens
    ├── dashboard_screen.dart    # Main dashboard
    ├── finance_screen.dart      # Financial module
    ├── tasks_screen.dart        # Task engine
    └── ai_screen.dart           # AI assistant
```

---

## 🎯 Common Tasks

### Change a Color
**File**: `lib/theme/jarvis_colors.dart`

```dart
// Change gold to blue
const Color gold = Color(0xFF2471A3);
const Color goldLight = Color(0xFF3498DB);
```

### Add a New Screen
1. Create `lib/screens/my_screen.dart`
2. Export in `lib/screens/index.dart`
3. Add to `_screens` list in `lib/main.dart`

```dart
final List<Widget> _screens = [
  const DashboardScreen(),
  const FinanceScreen(),
  const TasksScreen(),
  const AiScreen(),
  const MyScreen(),  // Add here
];
```

### Create a Custom Widget
**File**: `lib/widgets/my_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Center(
        child: Text('My Custom Widget',
            style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}
```

### Use a Component
```dart
// KPI Card
JarvisKpi(
  value: '₹4,821',
  label: 'Income',
  valueColor: incomeLight,
  icon: Icons.trending_up,
)

// Status Chip
JarvisChip(
  label: 'On Track',
  type: ChipType.ok,
)

// Card
JarvisCard(
  child: Text('My content'),
)

// Task Item
TaskItem(
  label: 'Review budget',
  isCompleted: false,
  meta: 'Priority: High',
)

// AI Orb
AiOrb(size: 60, animate: true)
```

---

## 🎨 Design System Quick Reference

### Spacing
```dart
Spacing.xs = 4px      // Tiny gap
Spacing.sm = 8px      // Small
Spacing.md = 12px     // Medium (default)
Spacing.lg = 16px     // Large
Spacing.xl = 20px     // Extra large
Spacing.xxl = 24px    // 2x large
Spacing.xxxl = 32px   // 3x large
```

### Text Styles
```dart
// Headings (Orbitron)
Theme.of(context).textTheme.headlineLarge    // 48px, bold
Theme.of(context).textTheme.headlineMedium   // 32px, bold
Theme.of(context).textTheme.headlineSmall    // 20px, bold

// Body (Rajdhani)
Theme.of(context).textTheme.bodyLarge        // 14px
Theme.of(context).textTheme.bodyMedium       // 12px
Theme.of(context).textTheme.bodySmall        // 11px

// Labels (JetBrains Mono)
Theme.of(context).textTheme.labelLarge       // 11px, gold
Theme.of(context).textTheme.labelSmall       // 8px, dim
```

### Colors
```dart
// Backgrounds
bgPrimary       // #030303 (main black)
bgTertiary      // #111111 (card bg)
bgQuaternary    // #181818 (input bg)

// Accents
gold            // #C9A84C (primary)
goldLight       // #E8C96D (lighter)
goldLine        // rgba(201,168,76,0.22) (borders)

// Status
okColor         // Green (#1E8A4A)
warnColor       // Yellow (#D4830A)
dangerColor     // Red (#C0392B)
blueColor       // Blue (#2471A3)

// Finance
incomeLight     // Green (#27AE60)
expenseLight    // Red (#E74C3C)

// Text
textPrimary     // #E8E0D0 (main text)
textMid         // #A09888 (secondary)
textDim         // #6A6058 (subtitle)
```

---

## 🔧 Debugging Tips

### Check Widget Tree
```bash
flutter run -v
# Look for "Building..." messages
```

### Enable Dev Tools
```bash
flutter pub global activate devtools
devtools
```

### Common Issues

**Problem**: Font not loading
```bash
flutter pub get
flutter pub pub cache repair
```

**Problem**: Hot reload not working
```bash
flutter clean
flutter pub get
flutter run
```

**Problem**: Build size too large
```bash
flutter build apk --split-per-abi  # Android
flutter build ios --release        # iOS
```

---

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-app.apk
```

### iOS
```bash
flutter build ios --release
# Use Xcode to sign and ship
```

### Web
```bash
flutter build web --release
# Output: build/web/ (deploy to any static host)
```

---

## 🎓 Learning Resources

- 📖 [Flutter Docs](https://flutter.dev/docs)
- 🎨 [Material Design 3](https://m3.material.io/)
- 🔤 [Google Fonts](https://fonts.google.com/)
- 💻 [Dart Language](https://dart.dev/)

---

## 🤝 Need Help?

### Check Documentation
- `README.md` - Project overview
- `SETUP_GUIDE.md` - Detailed setup instructions
- `IMPLEMENTATION_CHECKLIST.md` - What's included
- `components_showcase.dart` - Widget examples

### Common Patterns

**Safe Navigation**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: const JarvisTopbar(),
    body: _buildContent(),  // Separate method
  );
}

Widget _buildContent() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(Spacing.lg),
    child: Column(
      children: [ /* content */ ],
    ),
  );
}
```

**Responsive Layout**
```dart
final isDesktop = MediaQuery.of(context).size.width > 900;

return isDesktop 
  ? _buildDesktopLayout()
  : _buildMobileLayout();
```

**State Management**
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Updated')),
    );
  }
}
```

---

## ✨ Tips & Tricks

1. **Use const constructors** for better performance
2. **Separate build methods** for cleaner code
3. **Extract widgets** into separate files as they grow
4. **Use theme constants** instead of hardcoding values
5. **Leverage widget composition** over complex inheritance
6. **Test on multiple devices** (phone, tablet, web)
7. **Profile performance** with DevTools
8. **Keep widgets small** and focused on one job

---

## 🎉 Ready to Build!

You now have a fully-functional, production-ready Flutter app with:
- ✅ Complete design system
- ✅ Responsive layouts
- ✅ 20+ reusable components
- ✅ 4 feature screens
- ✅ Professional styling
- ✅ Documentation & examples

**Next Steps:**
1. Explore the screens in the app
2. Customize colors/fonts in `theme/`
3. Add more screens using existing patterns
4. Integrate with backend APIs
5. Deploy to app stores

Happy coding! 🚀
