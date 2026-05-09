# SETUP & INSTALLATION GUIDE

## Prerequisites

Before you start, ensure you have the following installed:

- **Flutter SDK**: [Download here](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: (Included with Flutter)
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Git**: For version control

### Verify Installation
```bash
flutter doctor
```

This command checks your system for dependencies required by Flutter.

## Project Setup

### 1. Initial Setup

```bash
# Navigate to project directory
cd flutter_project

# Get all dependencies
flutter pub get

# Generate code files (if any)
flutter pub run build_runner build
```

### 2. Running the App

**On Emulator/Simulator:**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

**On Physical Device:**
```bash
# Connect device via USB and enable Developer Mode
flutter run
```

**On Web:**
```bash
flutter run -d chrome
```

### 3. Building for Production

**Android:**
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## Project Structure Details

### `lib/theme/`
- **jarvis_colors.dart**: All color constants with CSS hex equivalents
- **jarvis_theme.dart**: Material theme configuration with typography and shadows

### `lib/widgets/`
- **jarvis_card.dart**: Card components (JarvisCard, IncomeCard, ExpenseCard)
- **jarvis_chip.dart**: Status badges with different types
- **jarvis_topbar.dart**: App bar with custom styling
- **jarvis_kpi.dart**: KPI metric displays
- **jarvis_ai_orb.dart**: Animated AI orb with glowing effect
- **jarvis_sidebar.dart**: Desktop navigation sidebar
- **jarvis_widgets.dart**: Utility widgets (SectionHeader, TaskItem, etc.)

### `lib/screens/`
- **dashboard_screen.dart**: Main dashboard with KPIs and overview
- **finance_screen.dart**: Financial management interface
- **tasks_screen.dart**: Task execution engine
- **ai_screen.dart**: AI assistant chat interface

## Customization Guide

### 1. Changing the Color Scheme

Edit `lib/theme/jarvis_colors.dart`:

```dart
// Change primary gold to blue
const Color gold = Color(0xFF2471A3);
const Color goldLight = Color(0xFF3498DB);
const Color goldLighter = Color(0xFF5DADE2);
```

Then update all references in `jarvis_theme.dart`.

### 2. Modifying Typography

Edit `lib/theme/jarvis_theme.dart`:

```dart
headlineLarge: GoogleFonts.orbitron(
  fontSize: 56,  // Change size
  fontWeight: FontWeight.w900,
  letterSpacing: 3,  // Adjust spacing
),
```

### 3. Adding New Screens

Create `lib/screens/new_feature_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../widgets/index.dart';

class NewFeatureScreen extends StatelessWidget {
  const NewFeatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const JarvisTopbar(title: 'NEW FEATURE'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your content here'),
          ],
        ),
      ),
    );
  }
}
```

Add to `lib/screens/index.dart`:
```dart
export 'new_feature_screen.dart';
```

Add to `lib/main.dart` navigation:
```dart
final List<Widget> _screens = [
  const DashboardScreen(),
  const FinanceScreen(),
  const TasksScreen(),
  const AiScreen(),
  const NewFeatureScreen(),  // Add here
];
```

### 4. Creating Custom Widgets

Create `lib/widgets/custom_widget.dart`:

```dart
import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

class CustomWidget extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomWidget({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: Spacing.md),
          child,
        ],
      ),
    );
  }
}
```

## Advanced Features

### State Management with Provider

Install provider:
```bash
flutter pub add provider
```

Example usage:
```dart
import 'package:provider/provider.dart';

class MyAppState extends ChangeNotifier {
  String _userName = 'JARVIS';
  String get userName => _userName;
  
  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}

// In main.dart
ChangeNotifierProvider(
  create: (context) => MyAppState(),
  child: const JarvisOsApp(),
)

// In widget
Text(context.watch<MyAppState>().userName)
```

### Adding Animations

```dart
class AnimatedCard extends StatefulWidget {
  final Widget child;
  
  const AnimatedCard({required this.child});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: widget.child,
    );
  }
}
```

### Testing

Create `test/widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('JarvisCard renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JarvisCard(
            child: Text('Test'),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
```

Run tests:
```bash
flutter test
```

## Debugging

### Enable Debug Logs
```bash
flutter run -v
```

### Common Issues

**Issue**: Fonts not loading
**Solution**: Ensure fonts are in `pubspec.yaml` and run `flutter pub get`

**Issue**: Colors not applying
**Solution**: Make sure you're using constants from `jarvis_colors.dart`

**Issue**: Layout overflow
**Solution**: Wrap content with `SingleChildScrollView` or use `Expanded`

## Performance Tips

1. **Use const constructors** for widgets
2. **Lazy load lists** with `ListView.builder`
3. **Cache images** and network requests
4. **Minimize rebuilds** with `RepaintBoundary`
5. **Profile app** with Flutter DevTools

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [Google Fonts](https://fonts.google.com/)

## Need Help?

- Check Flutter [documentation](https://flutter.dev)
- Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- Join [Flutter Community](https://flutter.dev/community)
