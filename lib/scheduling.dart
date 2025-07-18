import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class SchedulingDialog extends StatefulWidget {
  final DateTime? initialDate;
  const SchedulingDialog({Key? key, this.initialDate}) : super(key: key);

  @override
  State<SchedulingDialog> createState() => _SchedulingDialogState();
}

class _SchedulingDialogState extends State<SchedulingDialog> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Set Donation Schedule'),
      content: SizedBox(
        width: double.maxFinite,
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _selectedDate ?? DateTime.now(),
          selectedDayPredicate: (day) =>
            _selectedDate != null &&
            day.year == _selectedDate!.year &&
            day.month == _selectedDate!.month &&
            day.day == _selectedDate!.day,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedDate = null;
            });
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedDate == null
              ? null
              : () => Navigator.of(context).pop(_selectedDate),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Set Schedule'),
        ),
      ],
    );
  }
}