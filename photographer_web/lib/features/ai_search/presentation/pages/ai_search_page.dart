import 'package:flutter/material.dart';
import '../../../events/data/models/event_model.dart';
import '../widgets/selfie_upload_card.dart';

class AISearchPage extends StatelessWidget {
  final EventModel event;

  const AISearchPage({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("AI Face Search"),
      ),
      body: Center(
        child: SelfieUploadCard(
          onSelectImage: () {
            // We'll connect ImagePicker in the next step.
          },
        ),
      ),
    );
  }
}