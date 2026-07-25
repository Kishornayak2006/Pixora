import 'package:flutter/material.dart';
import '../widgets/recent_event_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard_header.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/dashboard_banner.dart';
import '../../../../core/widgets/app_page_layout.dart';
import '../../../../core/widgets/app_section_header.dart';

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),

          const SizedBox(height: 28),

          const DashboardBanner(),

          const SizedBox(height: 35),

          const Text(
            "Here's what's happening in your studio today.",
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 35),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                StatCard(
                  icon: Icons.photo_camera_rounded,
                  title: "Total Photos",
                  value: "0",
                  growth: "+0%",
                ),

                SizedBox(width: 22),

                StatCard(
                  icon: Icons.event_rounded,
                  title: "Events",
                  value: "0",
                  growth: "+0%",
                ),

                SizedBox(width: 22),

                StatCard(
                  icon: Icons.people_alt_rounded,
                  title: "Guests",
                  value: "0",
                  growth: "+0%",
                ),

                SizedBox(width: 22),

                StatCard(
                  icon: Icons.download_rounded,
                  title: "Downloads",
                  value: "0",
                  growth: "+0%",
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: SizedBox(
                  height: 420,
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppSectionHeader(
                            title: "Recent Events",
                          ),

                          const SizedBox(height: 20),

                          Expanded(
                            child: ListView(
                              children: const [
                                RecentEventCard(
                                  title: "John & Priya Wedding",
                                  location: "Mysore Palace",
                                  date: "20 July 2026",
                                  status: "Active",
                                  photos: 1240,
                                ),
                                RecentEventCard(
                                  title: "Corporate Meetup",
                                  location: "Bangalore",
                                  date: "18 July 2026",
                                  status: "Completed",
                                  photos: 860,
                                ),
                                RecentEventCard(
                                  title: "Birthday Celebration",
                                  location: "Coorg",
                                  date: "14 July 2026",
                                  status: "Completed",
                                  photos: 512,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 25),

              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    GlassCard(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Studio Overview",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 20),

                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              child: Icon(Icons.business),
                            ),
                            title: Text("My Studio"),
                            subtitle: Text("Premium Plan"),
                          ),

                          SizedBox(height: 15),

                          Text("Storage"),

                          SizedBox(height: 10),

                          LinearProgressIndicator(
                            value: .15,
                            minHeight: 8,
                          ),

                          SizedBox(height: 10),

                          Text(
                            "15 GB of 100 GB used",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.add),
                              label: const Text("Create Event"),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text("Upload Photos"),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.analytics),
                              label: const Text("Analytics"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}