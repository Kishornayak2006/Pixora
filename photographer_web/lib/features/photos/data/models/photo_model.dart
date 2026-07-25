class PhotoModel {
  final int id;
  final int eventId;
  final String originalName;
  final String fileName;
  final String imageUrl;
  final String mimeType;
  final int fileSize;
  final String processingStatus;
  final DateTime createdAt;

  PhotoModel({
    required this.id,
    required this.eventId,
    required this.originalName,
    required this.fileName,
    required this.imageUrl,
    required this.mimeType,
    required this.fileSize,
    required this.processingStatus,
    required this.createdAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as int,
      eventId: json['event_id'] as int,
      originalName: json['original_name'] as String,
      fileName: json['file_name'] as String,
      imageUrl: json['image_url'] as String,
      mimeType: json['mime_type'] as String,
      fileSize: json['file_size'] as int,
      processingStatus: json['processing_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'original_name': originalName,
      'file_name': fileName,
      'image_url': imageUrl,
      'mime_type': mimeType,
      'file_size': fileSize,
      'processing_status': processingStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}