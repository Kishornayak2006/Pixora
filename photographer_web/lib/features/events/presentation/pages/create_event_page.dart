import 'package:flutter/material.dart';

import '../../data/models/create_event_request.dart';
import '../../data/services/event_service.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final EventService _eventService = EventService();

  final _eventNameController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _eventDate;

  String _eventType = "WEDDING";

  bool _isLoading = false;

  @override
  void dispose() {
    _eventNameController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select event date"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateEventRequest(
        eventName: _eventNameController.text.trim(),
        eventType: _eventType,
        clientName: _clientNameController.text.trim(),
        clientPhone: _clientPhoneController.text.trim(),
        clientEmail: _clientEmailController.text.trim(),
        eventDate: _eventDate!,
        location: _locationController.text.trim(),
        coverImage: null,
      );

      await _eventService.createEvent(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event created successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create event.\n$e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _field(
                  controller: _eventNameController,
                  label: "Event Name",
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _eventType,
                  decoration: const InputDecoration(
                    labelText: "Event Type",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "WEDDING",
                      child: Text("Wedding"),
                    ),
                    DropdownMenuItem(
                      value: "RECEPTION",
                      child: Text("Reception"),
                    ),
                    DropdownMenuItem(
                      value: "BIRTHDAY",
                      child: Text("Birthday"),
                    ),
                    DropdownMenuItem(
                      value: "CORPORATE",
                      child: Text("Corporate"),
                    ),
                    DropdownMenuItem(
                      value: "COLLEGE",
                      child: Text("College"),
                    ),
                    DropdownMenuItem(
                      value: "OTHER",
                      child: Text("Other"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _eventType = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                _field(
                  controller: _clientNameController,
                  label: "Client Name",
                ),

                const SizedBox(height: 20),

                _field(
                  controller: _clientPhoneController,
                  label: "Client Phone",
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),

                _field(
                  controller: _clientEmailController,
                  label: "Client Email",
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Event Date",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _eventDate == null
                          ? "Select Date"
                          : "${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _field(
                  controller: _locationController,
                  label: "Location",
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Create Event",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label is required";
        }

        if (label == "Client Email") {
          final emailRegex =
              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

          if (!emailRegex.hasMatch(value.trim())) {
            return "Enter a valid email";
          }
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}