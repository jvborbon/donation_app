import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulingDialog extends StatefulWidget {
  final DateTime? initialDate;
  const SchedulingDialog({super.key, this.initialDate});

  @override
  State<SchedulingDialog> createState() => _SchedulingDialogState();
}

class _SchedulingDialogState extends State<SchedulingDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
      );
      _selectedTime = TimeOfDay.fromDateTime(widget.initialDate!);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime? get _combinedDateTime {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text(
        'Set Donation Schedule',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
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
                  color: theme.colorScheme.primary.withAlpha((0.4 * 255).round()),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(fontSize: 13),
                weekendTextStyle: const TextStyle(fontSize: 13),
                selectedTextStyle: const TextStyle(fontSize: 13, color: Colors.white),
                todayTextStyle: const TextStyle(fontSize: 13, color: Colors.white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 12),
                weekendStyle: TextStyle(fontSize: 12),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 32, // Reduced height
              child: ElevatedButton.icon(
                icon: const Icon(Icons.access_time, size: 16), // Smaller icon
                label: Text(
                  _selectedTime == null
                      ? 'Time'
                      : 'Time: ${_selectedTime!.format(context)}',
                  style: const TextStyle(fontSize: 12), // Smaller text
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 14, 14),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Smaller padding
                  minimumSize: const Size(80, 32), // Smaller minimum size
                  textStyle: const TextStyle(fontSize: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _pickTime,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                height: 32,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                      _selectedTime = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ),
              SizedBox(
                height: 32,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
              ),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: _combinedDateTime == null
                      ? null
                      : () => Navigator.of(context).pop(_combinedDateTime),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 14, 14),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(90, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Set Schedule', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}