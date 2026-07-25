
import '../../../../core/api/api_client.dart';
import '../models/studio_model.dart';

class StudioService {
  Future<StudioModel> getMyStudio() async {
    final response = await ApiClient.dio.get('/studios/me');

    return StudioModel.fromJson(response.data);
  }

  Future<StudioModel> createStudio(
    StudioModel studio,
  ) async {
    final response = await ApiClient.dio.post(
      '/studios',
      data: studio.toJson(),
    );

    return StudioModel.fromJson(response.data);
  }

  Future<StudioModel> updateStudio(
    StudioModel studio,
  ) async {
    final response = await ApiClient.dio.put(
      '/studios/me',
      data: studio.toJson(),
    );

    return StudioModel.fromJson(response.data);
  }

  Future<void> deleteStudio() async {
    await ApiClient.dio.delete('/studios/me');
  }
}