class AIProcessingStatus {
  final int totalPhotos;
  final int indexedPhotos;
  final int processingPhotos;
  final int failedPhotos;
  final double progress;
  final String estimatedTime;
  final List<String> processingQueue;
  final List<String> failedQueue;
  final bool ready;
  final String processingSpeed;
  final double successRate;
  final int remainingPhotos;

  AIProcessingStatus({
    required this.totalPhotos,
    required this.indexedPhotos,
    required this.processingPhotos,
    required this.failedPhotos,
    required this.progress,
    required this.estimatedTime,
    required this.processingQueue,
    required this.failedQueue,
    required this.ready,
    required this.processingSpeed,
    required this.successRate,
    required this.remainingPhotos,
  });

  factory AIProcessingStatus.fromJson(Map<String, dynamic> json) {
    return AIProcessingStatus(
      totalPhotos: json["total_photos"],
      indexedPhotos: json["indexed_photos"],
      processingPhotos: json["processing_photos"],
      failedPhotos: json["failed_photos"],
      progress: (json["progress"] as num).toDouble(),
      estimatedTime: json["estimated_time"],
      processingQueue:
          List<String>.from(json["processing_queue"] ?? []),
      failedQueue:
          List<String>.from(json["failed_queue"] ?? []),
      ready: json["ready"],
      processingSpeed: json["processing_speed"] ?? "",
      successRate: (json["success_rate"] as num).toDouble(),
      remainingPhotos: json["remaining_photos"] ?? 0,
    );
  }
}