import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/ai_processing_status_model.dart';
import '../../data/services/ai_processing_service.dart';
import 'package:photographer_web/core/widgets/glass_card.dart';

class AIProcessingPage extends StatefulWidget {
  final int eventId;
  final String eventName;

  const AIProcessingPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<AIProcessingPage> createState() => _AIProcessingPageState();
}

class _AIProcessingPageState extends State<AIProcessingPage> {
  final AIProcessingService _service = AIProcessingService();

  AIProcessingStatus? _status;
  bool _loading = true;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _loadStatus();

    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadStatus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final result = await _service.getStatus(widget.eventId);

      if (!mounted) return;

      setState(() {
        _status = result;
        _loading = false;
      });

      if (result.ready) {
        _timer?.cancel();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        title: const Text("AI Processing"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Monitor AI indexing progress for this event.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 30),
            _ReadyBanner(
              ready: _status?.ready ?? false,
            ),
            const SizedBox(height: 24),
            _StatsGrid(
              status: _status!,
            ),
            const SizedBox(height: 24),
            _ProgressCard(
              status: _status!,
            ),
            const SizedBox(height: 20),
            _AIAnalyticsCard(
              status: _status!,
            ),
            const SizedBox(height: 24),
            _QueueCard(
              queue: _status!.processingQueue,
            ),
            const SizedBox(height: 24),
            _FailedCard(
              queue: _status!.failedQueue,
              eventId: widget.eventId,
              service: _service,
              onRetry: _loadStatus,
            ),
          ],
        ),
      ),
    );
  }
}

/// 🚀 STEP 2 — Ready Banner
class _ReadyBanner extends StatelessWidget {
  final bool ready;

  const _ReadyBanner({
    required this.ready,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ready ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ready ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle : Icons.hourglass_top,
            color: ready ? Colors.green : Colors.orange,
            size: 36,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              ready
                  ? "AI indexing completed successfully.\nGuests can now search for their photos."
                  : "AI is currently indexing uploaded photos.\nGuests will be able to search once processing is completed.",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🚀 STEP 3 — Statistics Grid
class _StatsGrid extends StatelessWidget {
  final AIProcessingStatus status;

  const _StatsGrid({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        _StatCard(
          title: "Photos",
          value: status.totalPhotos.toString(),
          icon: Icons.photo_library,
          color: Colors.blue,
        ),
        _StatCard(
          title: "Indexed",
          value: status.indexedPhotos.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _StatCard(
          title: "Processing",
          value: status.processingPhotos.toString(),
          icon: Icons.hourglass_top,
          color: Colors.orange,
        ),
        _StatCard(
          title: "Failed",
          value: status.failedPhotos.toString(),
          icon: Icons.error,
          color: Colors.red,
        ),
      ],
    );
  }
}

/// 🚀 STEP 4 — Stat Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🚀 STEP 5 — Progress Card
class _ProgressCard extends StatelessWidget {
  final AIProcessingStatus status;

  const _ProgressCard({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overall Progress",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: status.progress / 100,
                minHeight: 12,
                backgroundColor: const Color(0xffE2E8F0),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "${status.progress.toStringAsFixed(1)}% Complete",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Estimated Time Remaining : ${status.estimatedTime}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🚀 STEP 6 — Queue Card
class _QueueCard extends StatelessWidget {
  final List<String> queue;

  const _QueueCard({
    required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Currently Processing",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (queue.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "No photos are currently being processed.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...queue.map(
                (photo) => Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.photo,
                        color: Colors.blue,
                      ),
                      title: Text(photo),
                      subtitle: const Text("Processing..."),
                    ),
                    const Divider(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🚀 STEP 7 — Failed Card
class _FailedCard extends StatelessWidget {
  final List<String> queue;
  final int eventId;
  final AIProcessingService service;
  final Future<void> Function() onRetry;

  const _FailedCard({
    required this.queue,
    required this.eventId,
    required this.service,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Failed Photos",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (queue.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "No failed photos 🎉",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...queue.map(
                (photo) => Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                      title: Text(photo),
                      subtitle: const Text(
                        "AI processing failed",
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            if (queue.isNotEmpty) const SizedBox(height: 20),
            if (queue.isNotEmpty)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                ),
                onPressed: () async {
                  await service.retryFailed(eventId);
                  await onRetry();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry Failed Photos"),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🚀 STEP 8 — AI Analytics Card
class _AIAnalyticsCard extends StatelessWidget {
  final AIProcessingStatus status;

  const _AIAnalyticsCard({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Analytics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text("Processing Speed"),
            trailing: Text(status.processingSpeed),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text("Success Rate"),
            trailing: Text("${status.successRate}%"),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Remaining Photos"),
            trailing: Text(
              "${status.remainingPhotos}",
            ),
          ),
        ],
      ),
    );
  }
}