import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            selectedFontSize: 12,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.camera_alt_outlined),
                activeIcon: const Icon(Icons.camera_alt),
                label: AppLocalizations.of(context)!.identify,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: AppLocalizations.of(context)!.history,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_outline),
                activeIcon: const Icon(Icons.favorite),
                label: AppLocalizations.of(context)!.favorites,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: AppLocalizations.of(context)!.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
