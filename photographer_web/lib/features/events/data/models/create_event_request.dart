class CreateEventRequest {
  final String eventName;
  final String eventType;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final DateTime eventDate;
  final String location;
  final String? coverImage;

  CreateEventRequest({
    required this.eventName,
    required this.eventType,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.eventDate,
    required this.location,
    this.coverImage,
  });

  Map<String, dynamic> toJson() {
    return {
      "event_name": eventName,
      "event_type": eventType,
      "client_name": clientName,
      "client_phone": clientPhone,
      "client_email": clientEmail,
      "event_date":
          "${eventDate.year.toString().padLeft(4, '0')}-"
          "${eventDate.month.toString().padLeft(2, '0')}-"
          "${eventDate.day.toString().padLeft(2, '0')}",
      "location": location,
      "cover_image": coverImage,
    };
  }
}