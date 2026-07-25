class EventModel {
  final int id;
  final int studioId;

  final String galleryToken;

  final String eventName;
  final String eventType;

  final String clientName;
  final String clientPhone;
  final String clientEmail;

  final DateTime eventDate;

  final String location;
  final String? coverImage;

  final String status;

  EventModel({
    required this.id,
    required this.studioId,
    required this.galleryToken,
    required this.eventName,
    required this.eventType,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.eventDate,
    required this.location,
    this.coverImage,
    required this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json["id"] as int,
      studioId: json["studio_id"] as int,
      galleryToken: json["gallery_token"]?.toString() ?? "",
      eventName: json["event_name"]?.toString() ?? "",
      eventType: json["event_type"]?.toString() ?? "",
      clientName: json["client_name"]?.toString() ?? "",
      clientPhone: json["client_phone"]?.toString() ?? "",
      clientEmail: json["client_email"]?.toString() ?? "",
      eventDate: DateTime.parse(json["event_date"].toString()),
      location: json["location"]?.toString() ?? "",
      coverImage: json["cover_image"]?.toString(),
      status: json["status"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "studio_id": studioId,
      "gallery_token": galleryToken,
      "event_name": eventName,
      "event_type": eventType,
      "client_name": clientName,
      "client_phone": clientPhone,
      "client_email": clientEmail,
      "event_date": eventDate.toIso8601String(),
      "location": location,
      "cover_image": coverImage,
      "status": status,
    };
  }
}