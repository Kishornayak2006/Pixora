import 'package:flutter/material.dart';

class PhotoDropZone extends StatelessWidget {
  final VoidCallback onSelectPhotos;

  const PhotoDropZone({
    super.key,
    required this.onSelectPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onSelectPhotos,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_rounded,
              size: 70,
              color: Colors.blue.shade600,
            ),

            const SizedBox(height: 20),

            const Text(
              "Drag & Drop Photos Here",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "or",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onSelectPhotos,
              icon: const Icon(Icons.folder_open),
              label: const Text("Select Photos"),
            ),
          ],
        ),
      ),
    );
  }
}