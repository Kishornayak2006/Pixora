import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/create_event_request.dart';
import '../models/event_model.dart';

class EventService {
  final Dio _dio = ApiClient.dio;

  /// Get all events for the authenticated studio
  Future<List<EventModel>> getEvents() async {
    final response = await _dio.get('/events');

    final List<EventModel> events = [];

    for (final item in response.data as List) {
      print("==================================");
      print(item);

      print("gallery_token = ${item['gallery_token']}");
      print("event_name    = ${item['event_name']}");
      print("event_type    = ${item['event_type']}");
      print("client_name   = ${item['client_name']}");
      print("client_phone  = ${item['client_phone']}");
      print("client_email  = ${item['client_email']}");
      print("event_date    = ${item['event_date']}");
      print("location      = ${item['location']}");
      print("cover_image   = ${item['cover_image']}");
      print("status        = ${item['status']}");

      events.add(EventModel.fromJson(item));
    }

    return events;
  }

  /// Get a single event
  Future<EventModel> getEvent(int id) async {
    final response = await _dio.get('/events/$id');

    return EventModel.fromJson(response.data);
  }

  /// Create a new event
  Future<void> createEvent(CreateEventRequest request) async {
    await _dio.post(
      '/events',
      data: request.toJson(),
    );
  }

  /// Update an existing event
  Future<EventModel> updateEvent(
    int id,
    CreateEventRequest request,
  ) async {
    final response = await _dio.put(
      '/events/$id',
      data: request.toJson(),
    );

    return EventModel.fromJson(response.data);
  }

  /// Delete an event
  Future<void> deleteEvent(int id) async {
    await _dio.delete('/events/$id');
  }
  
}