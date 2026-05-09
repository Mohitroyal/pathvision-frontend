import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JarvisTopbar(
        title: title.toUpperCase(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 64, color: goldDim),
            const SizedBox(height: Spacing.lg),
            Text(
              '$title Module',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Under construction. Coming soon in v2.0.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
