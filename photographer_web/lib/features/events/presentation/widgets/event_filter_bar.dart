import 'package:flutter/material.dart';

class EventFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const EventFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const filters = [
    "All",
    "Active",
    "Completed",
    "Archived",
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: filters.map((filter) {
        final isSelected = filter == selected;

        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) => onChanged(filter),
        );
      }).toList(),
    );
  }
}