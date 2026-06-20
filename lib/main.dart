import 'package:flutter/material.dart';
import 'package:background_remover/l10n/app_localizations.dart';
import 'ui/theme.dart';
import 'ui/screens/dashboard_screen.dart';

void main() {
  runApp(const BackgroundRemoverApp());
}

class BackgroundRemoverApp extends StatelessWidget {
  const BackgroundRemoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        if (locales != null) {
          for (final locale in locales) {
            // Try exact match
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode &&
                  supported.countryCode == locale.countryCode) {
                return supported;
              }
            }
            // Try language-only match
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
          }
        }
        // Fallback to en
        return const Locale('en');
      },
      home: const DashboardScreen(),
    );
  }
}
