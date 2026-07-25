import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/premium_sidebar.dart';
import '../../../../core/storage/token_storage.dart';
import 'dashboard_home_page.dart';
import 'package:photographer_web/features/events/presentation/pages/events_page.dart';
import 'gallery_page.dart';
import 'profile_page.dart';
import 'studios_page.dart';
import '../../../../core/widgets/premium_sidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardHomePage(), // 0 Dashboard
    EventsPage(),        // 1 Events
    StudiosPage(),       // 2 Studio
    GalleryPage(),       // 3
    ProfilePage(),       // 4
  ];

  Future<void> _logout() async {
    await TokenStorage().clearToken();

    if (!mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          PremiumSidebar(
            selectedIndex: selectedIndex,
            onSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            onLogout: _logout,
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.background,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.65),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: _pages[selectedIndex],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(
    IconData icon,
    String title,
    int index,
  ) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      child: ListTile(
        selected: selected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedTileColor: Colors.white12,
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          if (index == 5) {
            _logout();
            return;
          }

          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}