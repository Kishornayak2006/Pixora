import 'package:dio/dio.dart';
import '../models/ai_processing_status_model.dart';

class AIProcessingService {
  final Dio _dio = Dio();

  Future<AIProcessingStatus> getStatus(int eventId) async {
    final response = await _dio.get(
      "/photos/event/$eventId/ai-status",
    );

    return AIProcessingStatus.fromJson(response.data);
  }

  Future<void> retryFailed(int eventId) async {
    await _dio.post(
      "/events/$eventId/retry-processing",
    );
  }
}