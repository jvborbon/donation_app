import 'package:flutter/material.dart';

class ThemeLoader extends StatelessWidget {
  const ThemeLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.2),
        strokeWidth: 4,
      ),
    );
  }
}
