import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';

class PhotoService {
  final Dio _dio = ApiClient.dio;

  Future<void> bulkUpload({
    required int eventId,
    required List<MultipartFile> files,
    required Function(int sent, int total) onProgress,
  }) async {
    final formData = FormData.fromMap({
      "event_id": eventId,
      "files": files,
    });

    await _dio.post(
      "/photos/bulk-upload",
      data: formData,
      onSendProgress: onProgress,
    );
  }
}