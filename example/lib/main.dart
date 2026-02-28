import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bloc_manager/bloc_manager.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const BlocManagerExampleApp());
}

/// Main app entry point demonstrating BlocManagerTheme setup.
/// BlocManagerTheme provides app-wide theming for all BlocManager widgets.
class BlocManagerExampleApp extends StatelessWidget {
  const BlocManagerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocManagerTheme(
      data: BlocManagerThemeData(
        // Custom loading widget with branded spinner
        loadingWidget: const SpinKitFoldingCube(
          color: Colors.white,
          size: 50.0,
        ),
        // Custom loading overlay color
        loadingColor: Colors.blue.withValues(alpha: 0.3),

        // Custom error handler - shows red snackbar
        onError: (context, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        },

        // Custom success handler - shows green snackbar
        onSuccess: (context, message) {
          if (message == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        },

        // Enable/disable global error/success notifications
        showResultErrorNotifications: true,
        showResultSuccessNotifications: true,
      ),
      child: MaterialApp(
        title: 'Bloc Manager Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
