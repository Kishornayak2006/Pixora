import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/event_model.dart';

class QRPreviewPage extends StatefulWidget {
  final EventModel event;

  const QRPreviewPage({
    super.key,
    required this.event,
  });

  @override
  State<QRPreviewPage> createState() => _QRPreviewPageState();
}

class _QRPreviewPageState extends State<QRPreviewPage> {
  final GlobalKey qrKey = GlobalKey();

  Future<void> downloadQR() async {
    final boundary =
        qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);

    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final pngBytes = byteData!.buffer.asUint8List();

    final blob = html.Blob([pngBytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = "${widget.event.eventName}_QR.png"
      ..click();

    html.Url.revokeObjectUrl(url);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("QR downloaded successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData =
        "https://pixora.app/g/${widget.event.galleryToken}";

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("Event QR Code"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.event.eventName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.event.eventType,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 30),

                  RepaintBoundary(
                    key: qrKey,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 380,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SelectableText(
                    qrData,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Guests can scan this QR code and upload a selfie to instantly find their photos.",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 35),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: downloadQR,
                        icon: const Icon(Icons.download),
                        label: const Text("Download QR"),
                      ),

                      const SizedBox(width: 20),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("Close"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}