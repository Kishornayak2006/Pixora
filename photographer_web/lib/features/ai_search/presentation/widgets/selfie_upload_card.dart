import 'package:flutter/material.dart';

class SelfieUploadCard extends StatelessWidget {
  final VoidCallback? onSelectImage;

  const SelfieUploadCard({
    super.key,
    this.onSelectImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xffF3F0FF),
              borderRadius: BorderRadius.circular(55),
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              size: 55,
              color: Color(0xff6C3EF4),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Upload a Selfie",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Upload a clear front-facing photo to search for matching event photos using AI.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed: onSelectImage,
            icon: const Icon(Icons.upload_file),
            label: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Text("Choose Selfie"),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Supported: JPG, PNG • Max 10 MB",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}