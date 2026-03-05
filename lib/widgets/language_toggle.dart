import 'package:airly_app/services/app_state.dart';
import 'package:flutter/material.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppState.instance.locale,
      builder: (context, locale, _) {
        final isMk = locale.languageCode == 'mk';

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AppState.instance.setLocale(isMk ? const Locale('en') : const Locale('mk'));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              isMk ? 'MK' : 'EN',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
  }
}