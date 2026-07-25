import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';

class PremiumSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const PremiumSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: AppGradients.sidebar,
        boxShadow: AppShadows.sidebar,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Logo
              Column(
                children: [
                  Image.asset(
                    "assets/images/pixora_logo.png",
                    height: 72,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Pixora",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Every Moment. Instantly Yours",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                "Every Moment. Instantly Yours.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.body,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              _item(
                icon: Icons.dashboard_rounded,
                title: "Dashboard",
                index: 0,
              ),

              _item(
                icon: Icons.event_rounded,
                title: "Events",
                index: 1,
              ),

              _item(
                icon: Icons.business_rounded,
                title: "Studio",
                index: 2,
              ),

              const Spacer(),

              // Branding Area
              Expanded(
                child: Center(
                  child: Opacity(
                    opacity: .95,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Opacity(
                        opacity: .82,
                        child: Image.asset(
                          "assets/images/sidebar_brand.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Divider(
                color: Colors.grey.shade300,
              ),

              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: onLogout,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.primary : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xff6C3EF4).withOpacity(.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(index),
            child: ListTile(
              leading: Icon(
                icon,
                color: selected ? Colors.white : AppColors.heading,
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.heading,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}