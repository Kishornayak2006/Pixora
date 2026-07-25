import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../studio/data/models/studio_model.dart';
import '../../../studio/data/services/studio_service.dart';

class StudiosPage extends StatefulWidget {
  const StudiosPage({super.key});

  @override
  State<StudiosPage> createState() => _StudiosPageState();
}

class _StudiosPageState extends State<StudiosPage> {
  final _formKey = GlobalKey<FormState>();

  final _studioName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _logoUrl = TextEditingController();

  bool loading = true;
  bool studioExists = false;

  @override
  void initState() {
    super.initState();
    loadStudio();
  }

  Future<void> loadStudio() async {
    try {
      final studio = await StudioService().getMyStudio();

      _studioName.text = studio.studioName;
      _phone.text = studio.phone;
      _email.text = studio.email;
      _description.text = studio.description ?? "";
      _address.text = studio.address ?? "";
      _city.text = studio.city ?? "";
      _state.text = studio.state ?? "";
      _country.text = studio.country ?? "";
      _logoUrl.text = studio.logoUrl ?? "";

      studioExists = true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        studioExists = false;
      } else {
        rethrow;
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  StudioModel buildStudio() {
    return StudioModel(
      studioName: _studioName.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      description: _description.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      country: _country.text.trim(),
      logoUrl: _logoUrl.text.trim(),
    );
  }

  Future<void> saveStudio() async {
    if (!_formKey.currentState!.validate()) return;

    if (studioExists) {
      await StudioService().updateStudio(buildStudio());
    } else {
      await StudioService().createStudio(buildStudio());
      studioExists = true;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          studioExists
              ? "Studio Updated Successfully"
              : "Studio Created Successfully",
        ),
      ),
    );

    setState(() {});
  }

  Future<void> deleteStudio() async {
    await StudioService().deleteStudio();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Studio Deleted"),
      ),
    );

    setState(() {
      studioExists = false;

      _studioName.clear();
      _phone.clear();
      _email.clear();
      _description.clear();
      _address.clear();
      _city.clear();
      _state.clear();
      _country.clear();
      _logoUrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studioExists ? "My Studio" : "Create Studio",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            _field(_studioName, "Studio Name"),
            _field(_phone, "Phone"),
            _field(_email, "Email"),
            _field(_description, "Description"),
            _field(_address, "Address"),
            _field(_city, "City"),
            _field(_state, "State"),
            _field(_country, "Country"),
            _field(_logoUrl, "Logo URL"),

            const SizedBox(height: 30),

            Row(
              children: [
                ElevatedButton(
                  onPressed: saveStudio,
                  child: Text(
                    studioExists ? "Update Studio" : "Create Studio",
                  ),
                ),
                const SizedBox(width: 15),
                if (studioExists)
                  ElevatedButton(
                    onPressed: deleteStudio,
                    child: const Text("Delete"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        validator: (v) {
          if ((label == "Studio Name" ||
                  label == "Phone" ||
                  label == "Email") &&
              (v == null || v.trim().isEmpty)) {
            return "$label is required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}