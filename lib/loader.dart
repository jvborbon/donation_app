import 'package:flutter/material.dart';

class ThemeLoader extends StatelessWidget {
  const ThemeLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        backgroundColor: theme.colorScheme.surface.withAlpha((0.2 * 255).round()), // was: withOpacity(0.2)
        strokeWidth: 4,
      ),
    );
  }
}
