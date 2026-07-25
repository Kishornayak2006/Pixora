import 'package:flutter/material.dart';
import '../../data/models/create_event_request.dart';
import '../../data/services/event_service.dart';
import '../../data/models/event_model.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({
    super.key,
    required this.event,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();

  late final TextEditingController _eventNameController;
  late final TextEditingController _clientNameController;
  late final TextEditingController _clientPhoneController;
  late final TextEditingController _clientEmailController;
  late final TextEditingController _locationController;

  late DateTime _eventDate;

  late String _eventType;
  late String _status;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _eventNameController =
        TextEditingController(text: widget.event.eventName);

    _clientNameController =
        TextEditingController(text: widget.event.clientName);

    _clientPhoneController =
        TextEditingController(text: widget.event.clientPhone);

    _clientEmailController =
        TextEditingController(text: widget.event.clientEmail);

    _locationController =
        TextEditingController(text: widget.event.location);

    _eventDate = widget.event.eventDate;
    _eventType = widget.event.eventType;
    _status = widget.event.status;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
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
                    DropdownMenuItem(value: "WEDDING", child: Text("Wedding")),
                    DropdownMenuItem(value: "RECEPTION", child: Text("Reception")),
                    DropdownMenuItem(value: "BIRTHDAY", child: Text("Birthday")),
                    DropdownMenuItem(value: "CORPORATE", child: Text("Corporate")),
                    DropdownMenuItem(value: "COLLEGE", child: Text("College")),
                    DropdownMenuItem(value: "OTHER", child: Text("Other")),
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
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Event Date",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      "${_eventDate.day}/${_eventDate.month}/${_eventDate.year}",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _field(
                  controller: _locationController,
                  label: "Location",
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "UPCOMING",
                      child: Text("Upcoming"),
                    ),
                    DropdownMenuItem(
                      value: "ONGOING",
                      child: Text("Ongoing"),
                    ),
                    DropdownMenuItem(
                      value: "COMPLETED",
                      child: Text("Completed"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateEvent,
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
                            "Save Changes",
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

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
        eventDate: _eventDate,
        location: _locationController.text.trim(),
        coverImage: widget.event.coverImage,
      );

      await _eventService.updateEvent(
        widget.event.id,
        request,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event updated successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update event.\n$e"),
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