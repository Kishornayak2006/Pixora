import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../widgets/selected_photo_list.dart';
import '../../../events/data/models/event_model.dart';
import '../../widgets/photo_drop_zone.dart';
import '../../widgets/upload_panel.dart';
import '../../widgets/selected_photo_list.dart';
import 'package:dio/dio.dart';
import '../../data/services/photo_service.dart';

class UploadPhotosPage extends StatefulWidget {
  final EventModel event;

  const UploadPhotosPage({
    super.key,
    required this.event,
  });

  @override
  State<UploadPhotosPage> createState() => _UploadPhotosPageState();
}

class _UploadPhotosPageState extends State<UploadPhotosPage> {
  final PhotoService _photoService = PhotoService();
  
  List<PlatformFile> _selectedFiles = [];


  bool _uploading = false;
  double _progress = 0;

  Future<void> _pickPhotos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      _selectedFiles = result.files;
    });
  }

  int get _totalBytes =>
      _selectedFiles.fold(0, (sum, file) => sum + file.size);

  Future<void> _uploadPhotos() async {
    if (_selectedFiles.isEmpty) return;

    try {
      setState(() {
        _uploading = true;
        _progress = 0;
      });

      final multipartFiles = <MultipartFile>[];

      for (final file in _selectedFiles) {
        multipartFiles.add(
          MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        );
      }

      await _photoService.bulkUpload(
        eventId: widget.event.id,
        files: multipartFiles,
        onProgress: (sent, total) {
          setState(() {
            _progress = sent / total;
          });
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Photos uploaded successfully."),
        ),
      );

      setState(() {
        _selectedFiles.clear();
        _uploading = false;
        _progress = 0;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        _uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.response?.data.toString() ??
                "Upload failed. Please try again.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Upload Photos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 380,
              child: UploadPanel(
                dropZone: PhotoDropZone(
                  onSelectPhotos: _pickPhotos,
                ),
                totalPhotos: _selectedFiles.length,
                totalBytes: _totalBytes,
                uploading: _uploading,
                progress: _progress,
                onUpload: _uploadPhotos,
              ),
            ),

            const SizedBox(width: 24),

            Expanded(
              child: _selectedFiles.isEmpty
                  ? Card(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "No photos selected",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Select photos from the left panel",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SelectedPhotoList(
                      files: _selectedFiles,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}