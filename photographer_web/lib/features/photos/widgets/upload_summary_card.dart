import 'package:flutter/material.dart';

class UploadSummaryCard extends StatelessWidget {
  final int totalPhotos;
  final int totalBytes;
  final bool uploading;
  final VoidCallback onUpload;

  const UploadSummaryCard({
    super.key,
    required this.totalPhotos,
    required this.totalBytes,
    required this.uploading,
    required this.onUpload,
  });

  String get size {
    final mb = totalBytes / 1024 / 1024;

    if (mb < 1024) {
      return "${mb.toStringAsFixed(2)} MB";
    }

    return "${(mb / 1024).toStringAsFixed(2)} GB";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$totalPhotos Photos",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(size),
                  ],
                ),
              ),

              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: uploading ? null : onUpload,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(
                    uploading ? "Uploading..." : "Upload",
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