import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../photos/presentation/pages/upload_photos_page.dart';
import '../../data/models/event_model.dart';
import '../../../photos/presentation/pages/gallery_page.dart';
import 'edit_event_page.dart';
import 'qr_preview_page.dart';

// TODO: Import your AISearchPage here once created
// import 'ai_search_page.dart';

class EventDetailsPage extends StatelessWidget {
  final EventModel event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(event.eventDate);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(event.eventName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🚀 Sprint 10.1 — Premium Header Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff6C3EF4),
                    Color(0xff8D6BFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: event.coverImage != null &&
                            event.coverImage!.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      event.coverImage!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                event.coverImage!,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            width: 110,
                            height: 110,
                            color: Colors.white24,
                            child: const Icon(
                              Icons.photo_camera_back,
                              color: Colors.white,
                              size: 45,
                            ),
                          ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.eventName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.eventType,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            event.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Client Information
            SectionCard(
              title: "👤 Client Information",
              child: Column(
                children: [
                  InfoRow(
                    title: "Name",
                    value: event.clientName,
                  ),
                  InfoRow(
                    title: "Phone",
                    value: event.clientPhone,
                  ),
                  InfoRow(
                    title: "Email",
                    value: event.clientEmail,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Event Information
            SectionCard(
              title: "📅 Event Information",
              child: Column(
                children: [
                  InfoRow(
                    title: "Type",
                    value: event.eventType,
                  ),
                  InfoRow(
                    title: "Date",
                    value: formattedDate,
                  ),
                  InfoRow(
                    title: "Location",
                    value: event.location,
                  ),
                  InfoRow(
                    title: "Status",
                    value: event.status,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Gallery Token & QR Preview
            SectionCard(
              title: "🔑 Gallery Token",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    event.galleryToken,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: event.galleryToken,
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gallery Token Copied"),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy Token"),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6C3EF4),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QRPreviewPage(
                                event: event,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text("View QR Code"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Quick Actions
            SectionCard(
              title: "⚡ Quick Actions",
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 156, 4, 232),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UploadPhotosPage(
                            event: event,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Photos"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 35, 224, 6),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryPage(
                            event: event,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text("View Gallery"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 110, 64),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      /* 
                      // Uncomment when AISearchPage is built:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AISearchPage(
                            event: event,
                          ),
                        ),
                      );
                      */
                    },
                    icon: const Icon(Icons.face_retouching_natural),
                    label: const Text("AI Face Search"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 11, 184, 227),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditEventPage(event: event),
                        ),
                      );

                      if (updated == true) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Event"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30),
            child,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}