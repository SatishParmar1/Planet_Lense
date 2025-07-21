import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import 'home_view.dart';
import 'history_view.dart';
import 'favorites_view.dart';
import 'profile_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;
  
  final List<Widget> _views = [
    const HomeView(),
    const HistoryView(),
    const FavoritesView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize authentication when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      extendBody: true,
    );
  }
}
