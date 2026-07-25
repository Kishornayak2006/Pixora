import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SelectedPhotoList extends StatelessWidget {
  final List<PlatformFile> files;

  const SelectedPhotoList({
    super.key,
    required this.files,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.photo_library),
                const SizedBox(width: 10),
                Text(
                  "Selected Photos (${files.length})",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: files.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final file = files[index];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.image),
                  ),
                  title: Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "${(file.size / 1024 / 1024).toStringAsFixed(2)} MB",
                  ),
                  trailing: const Icon(Icons.check_circle,
                      color: Colors.green),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}