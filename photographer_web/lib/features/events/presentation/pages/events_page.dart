import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_details_page.dart';
import '../../data/models/event_model.dart';
import '../../data/services/event_service.dart';
import 'create_event_page.dart';
import '../widgets/event_stat_card.dart';
import '../widgets/event_card.dart';
import '../widgets/event_search_bar.dart';
import '../widgets/event_filter_bar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventService _eventService = EventService();

  bool _loading = true;
  List<EventModel> _events = [];

  String _search = "";
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  List<EventModel> get _filteredEvents {
    return _events.where((event) {
      final matchesSearch =
          event.eventName.toLowerCase().contains(_search.toLowerCase()) ||
          event.clientName.toLowerCase().contains(_search.toLowerCase()) ||
          event.location.toLowerCase().contains(_search.toLowerCase());

      final matchesStatus =
          _selectedFilter == "All" ||
          event.status.toLowerCase() == _selectedFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventService.getEvents();

      print("Events Loaded: ${events.length}");

      for (final event in events) {
        print("Event: ${event.eventName}");
      }

      if (!mounted) return;

      setState(() {
        _events = events;
        _loading = false;
      });

      print("UI Updated Successfully");
    } catch (e, stackTrace) {
      print("ERROR: $e");
      print(stackTrace);

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _openCreateEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateEventPage(),
      ),
    );

    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 25),
            EventSearchBar(
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
            const SizedBox(height: 18),
            EventFilterBar(
              selected: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 135,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  EventStatCard(
                    icon: Icons.event,
                    title: "Total Events",
                    value: "${_events.length}",
                  ),
                  const SizedBox(width: 20),
                  EventStatCard(
                    icon: Icons.check_circle,
                    title: "Active",
                    value:
                        "${_events.where((e) => e.status == "Active").length}",
                  ),
                  const SizedBox(width: 20),
                  const EventStatCard(
                    icon: Icons.photo_library,
                    title: "Photos",
                    value: "--",
                  ),
                  const SizedBox(width: 20),
                  const EventStatCard(
                    icon: Icons.people,
                    title: "Guests",
                    value: "--",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Events",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Manage all your photography events",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: _openCreateEvent,
          icon: const Icon(Icons.add),
          label: const Text("Create Event"),
          style: FilledButton.styleFrom(
            minimumSize: const Size(190, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Events Yet",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Create your first event to start uploading photos.",
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _openCreateEvent,
              icon: const Icon(Icons.add),
              label: const Text("Create Event"),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        final formattedDate = DateFormat('dd MMM yyyy').format(event.eventDate);

        return EventCard(
          title: event.eventName,
          location: event.location,
          date: formattedDate,
          status: event.status,
          photos: 0,
          guests: 0,
          coverImage: event.coverImage,
          onOpen: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailsPage(event: event),
              ),
            );
          },
        );
      },
    );
  }
}