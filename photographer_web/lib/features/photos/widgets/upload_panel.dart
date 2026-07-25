import 'package:flutter/material.dart';

class UploadPanel extends StatelessWidget {
  final Widget dropZone;
  final int totalPhotos;
  final int totalBytes;
  final bool uploading;
  final double progress;
  final VoidCallback onUpload;

  const UploadPanel({
    super.key,
    required this.dropZone,
    required this.totalPhotos,
    required this.totalBytes,
    required this.uploading,
    required this.progress,
    required this.onUpload,
  });

  String get formattedSize {
    final mb = totalBytes / 1024 / 1024;

    if (mb < 1024) {
      return "${mb.toStringAsFixed(2)} MB";
    }

    return "${(mb / 1024).toStringAsFixed(2)} GB";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload Photos",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              dropZone,

              const SizedBox(height: 25),

              const Divider(),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.photo_library),

                  const SizedBox(width: 10),

                  Text(
                    "$totalPhotos Photos",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  const Icon(Icons.storage),

                  const SizedBox(width: 10),

                  Text(formattedSize),
                ],
              ),

              const SizedBox(height: 25),

              if (uploading) ...[
                const Text(
                  "Uploading...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                  ),
                ),

                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      totalPhotos == 0 || uploading ? null : onUpload,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text(
                    "Upload Photos",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}