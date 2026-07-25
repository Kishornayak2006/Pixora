import 'package:flutter/material.dart';

import '../../data/models/photo_model.dart';
import '../../data/services/gallery_service.dart';

class FullScreenPhotoPage extends StatelessWidget {
  final PhotoModel photo;

  const FullScreenPhotoPage({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final galleryService = GalleryService();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Download",
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                await galleryService.downloadPhoto(
                  photo.id,
                  photo.originalName,
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Download started"),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(photo.imageUrl),
        ),
      ),
    );
  }
}