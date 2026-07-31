import 'package:flutter/material.dart';
import 'full_screen_photo_page.dart';
import '../../data/models/photo_model.dart';
import '../../data/services/gallery_service.dart';
import '../../../photos/presentation/pages/upload_photos_page.dart';

// Step 2: Import EventService
import '../../../events/data/services/event_service.dart';

class GalleryPage extends StatefulWidget {
  final dynamic event;

  const GalleryPage({
    super.key,
    required this.event,
  });

  int get eventId {
    if (event is int) return event as int;
    return event.id;
  }

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final GalleryService _galleryService = GalleryService();

  // Step 2: Instantiate EventService and declare _coverImage
  final EventService _eventService = EventService();
  String? _coverImage;

  late Future<List<PhotoModel>> _photosFuture;
  String _sort = "desc";
  String _search = "";
  String _selectedStatusFilter = "ALL";

  int? _hoveredPhotoId;

  @override
  void initState() {
    super.initState();
    _loadPhotos();

    // Step 3: Initialize current cover photo safely
    if (widget.event is! int) {
      try {
        _coverImage = widget.event.coverImage;
      } catch (_) {
        _coverImage = null;
      }
    }
  }

  void _loadPhotos() {
    setState(() {
      _photosFuture = _galleryService.getPhotos(
        widget.eventId,
        sort: _sort,
      );
    });
  }

  // Step 4: Add _setCover method
  Future<void> _setCover(PhotoModel photo) async {
    try {
      await _eventService.setCoverPhoto(
        eventId: widget.eventId,
        photoId: photo.id,
      );

      setState(() {
        _coverImage = photo.imageUrl;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cover photo updated"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deletePhoto(PhotoModel photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Photo"),
          content: const Text("This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _galleryService.deletePhoto(photo.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo deleted successfully")),
      );

      _loadPhotos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    IconData icon;
    Color color;
    String text;

    switch (status.toUpperCase()) {
      case "COMPLETED":
        icon = Icons.check_circle;
        color = const Color(0xff10B981);
        text = "Completed";
        break;
      case "PROCESSING":
        icon = Icons.hourglass_top;
        color = const Color(0xffF59E0B);
        text = "Processing";
        break;
      case "FAILED":
        icon = Icons.error;
        color = const Color(0xffEF4444);
        text = "Failed";
        break;
      default:
        icon = Icons.schedule;
        color = const Color(0xff64748B);
        text = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1600
        ? 6
        : width > 1300
            ? 5
            : width > 1000
                ? 4
                : width > 700
                    ? 3
                    : 2;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Event Gallery",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<PhotoModel>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final allPhotos = snapshot.data ?? [];

          final filteredPhotos = allPhotos.where((photo) {
            final matchesSearch = photo.originalName
                .toLowerCase()
                .contains(_search.toLowerCase());

            final matchesStatus = _selectedStatusFilter == "ALL" ||
                photo.processingStatus.toUpperCase() ==
                    _selectedStatusFilter.toUpperCase();

            return matchesSearch && matchesStatus;
          }).toList();

          final totalCount = allPhotos.length;
          final completedCount = allPhotos
              .where((p) => p.processingStatus.toUpperCase() == "COMPLETED")
              .length;
          final processingCount = allPhotos
              .where((p) => p.processingStatus.toUpperCase() == "PROCESSING")
              .length;
          final failedCount = allPhotos
              .where((p) => p.processingStatus.toUpperCase() == "FAILED")
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Gallery",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage uploaded photos and AI processing",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6C3EF4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadPhotosPage(
                                  event: widget.event,
                                ),
                              ),
                            ).then((_) => _loadPhotos());
                          },
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text("Upload Photos"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.sort, color: Color(0xff64748B)),
                            tooltip: "Sort Photos",
                            onSelected: (value) {
                              setState(() => _sort = value);
                              _loadPhotos();
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: "desc",
                                child: Text("Newest First"),
                              ),
                              PopupMenuItem(
                                value: "asc",
                                child: Text("Oldest First"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Stats Section
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth > 800
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _StatCard(
                          width: cardWidth,
                          title: "Total Photos",
                          value: "$totalCount",
                          icon: Icons.photo_library,
                          color: const Color(0xff6C3EF4),
                        ),
                        _StatCard(
                          width: cardWidth,
                          title: "Completed",
                          value: "$completedCount",
                          icon: Icons.check_circle,
                          color: const Color(0xff10B981),
                        ),
                        _StatCard(
                          width: cardWidth,
                          title: "Processing",
                          value: "$processingCount",
                          icon: Icons.hourglass_top,
                          color: const Color(0xffF59E0B),
                        ),
                        _StatCard(
                          width: cardWidth,
                          title: "Failed",
                          value: "$failedCount",
                          icon: Icons.error,
                          color: const Color(0xffEF4444),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Filters & Search
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) => setState(() => _search = value),
                        decoration: InputDecoration(
                          hintText: "Search by filename...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xffF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip("All", "ALL"),
                            _buildFilterChip("Completed", "COMPLETED"),
                            _buildFilterChip("Processing", "PROCESSING"),
                            _buildFilterChip("Failed", "FAILED"),
                            _buildFilterChip("Pending", "PENDING"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Grid View
                if (filteredPhotos.isEmpty)
                  _buildEmptyState()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.58, // Adjusted ratio to fit cover button
                    ),
                    itemCount: filteredPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = filteredPhotos[index];
                      final isHovered = _hoveredPhotoId == photo.id;

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => setState(() => _hoveredPhotoId = photo.id),
                        onExit: (_) => setState(() => _hoveredPhotoId = null),
                        child: AnimatedScale(
                          scale: isHovered ? 1.02 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isHovered ? 0.08 : 0.03),
                                  blurRadius: isHovered ? 12 : 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: const Color(0xffE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // Image
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => FullScreenPhotoPage(photo: photo),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: Image.network(
                                            photo.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (_, __, ___) => const Center(
                                              child: Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Delete Button
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.black54,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                                            onPressed: () => _deletePhoto(photo),
                                          ),
                                        ),
                                      ),

                                      // Step 5: Add the Cover badge inside Stack
                                      if (_coverImage == photo.imageUrl)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade700,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Cover",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Footer
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        photo.originalName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: Color(0xff0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildStatusBadge(photo.processingStatus),

                                      // Step 6: Add "Set as Cover" Button below status badge
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _coverImage == photo.imageUrl
                                              ? null
                                              : () => _setCover(photo),
                                          icon: const Icon(Icons.star, size: 18),
                                          label: Text(
                                            _coverImage == photo.imageUrl
                                                ? "Cover Photo"
                                                : "Set as Cover",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedStatusFilter = value),
        selectedColor: const Color(0xff6C3EF4).withOpacity(0.15),
        checkmarkColor: const Color(0xff6C3EF4),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xff6C3EF4) : const Color(0xff64748B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xffF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.collections, size: 48, color: Color(0xff94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Photos Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Upload your first photos to begin AI face indexing.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xff64748B)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6C3EF4),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadPhotosPage(event: widget.event),
                ),
              ).then((_) => _loadPhotos());
            },
            icon: const Icon(Icons.upload, size: 18),
            label: const Text("Upload Photos"),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Color(0xff64748B)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}