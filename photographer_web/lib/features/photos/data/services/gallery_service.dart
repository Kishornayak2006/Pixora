import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;
import '../../../../core/api/api_client.dart';
import '../models/photo_model.dart';
import 'dart:typed_data';

class GalleryService {
  final Dio _dio = ApiClient.dio;

  Future<List<PhotoModel>> getPhotos(
    int eventId, {
    String sort = "desc",
  }) async {
    final response = await _dio.get(
      '/photos/event/$eventId',
      queryParameters: {
        'sort': sort,
      },
    );

    final List items = response.data['items'];

    return items
        .map((json) => PhotoModel.fromJson(json))
        .toList();
  }

  Future<void> deletePhoto(int photoId) async {
    await _dio.delete('/photos/$photoId');
  }
  Future<void> downloadPhoto(
    int photoId,
    String fileName,
  ) async {
    final response = await _dio.get(
      '/photos/$photoId/download',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = Uint8List.fromList(
      List<int>.from(response.data),
    );

    final blob = html.Blob([bytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}