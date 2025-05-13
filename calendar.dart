// lib/calendar.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, String>>> _events = {};

  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
  ];

  Color _selectedDialogColor = Colors.red; // shared for add/edit dialogs

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEventsFromFirestore();
  }

  Future<void> _loadEventsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('calendarEvents').get();
    final Map<DateTime, List<Map<String, String>>> loadedEvents = {};

    for (var doc in snapshot.docs) {
      final dateParts = doc.id.split('-').map(int.parse).toList();
      final date = DateTime(dateParts[0], dateParts[1], dateParts[2]);
      final events = List<Map<String, String>>.from((doc['events'] as List).map((e) {
        return {
          'title': e['title'],
          'subtitle': e['subtitle'],
          'color': e['color'] ?? Colors.green.value.toString(),
        };
      }));
      loadedEvents[date] = events;
    }

    setState(() {
      _events = loadedEvents;
    });
  }

  Future<void> _saveEventToFirestore(DateTime date, String title, String subtitle, String color) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final docId = '${normalized.year}-${normalized.month}-${normalized.day}';
    final newEvent = {'title': title, 'subtitle': subtitle, 'color': color};

    await FirebaseFirestore.instance
        .collection('calendarEvents')
        .doc(docId)
        .set({
      'events': FieldValue.arrayUnion([newEvent])
    }, SetOptions(merge: true));
  }

  Future<void> _deleteEventFromFirestore(DateTime date, Map<String, String> targetEvent) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final docId = '${normalized.year}-${normalized.month}-${normalized.day}';
    final docRef = FirebaseFirestore.instance.collection('calendarEvents').doc(docId);

    final doc = await docRef.get();
    if (!doc.exists) return;
    final List<dynamic> currentEvents = List.from(doc['events'] ?? []);

    currentEvents.removeWhere((e) =>
    e['title'] == targetEvent['title'] &&
        e['subtitle'] == targetEvent['subtitle'] &&
        e['color'] == targetEvent['color']
    );

    await docRef.set({'events': currentEvents}, SetOptions(merge: true));

    setState(() {
      _events[normalized] = currentEvents.map((e) => Map<String, String>.from(e)).toList();
    });
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  void _showScheduleDialog(DateTime date) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final normalized = DateTime(date.year, date.month, date.day);
    _selectedDialogColor = availableColors[0];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('${normalized.year}-${normalized.month}-${normalized.day} 일정 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(hintText: '일정 제목')),
              const SizedBox(height: 8),
              TextField(controller: subtitleController, decoration: const InputDecoration(hintText: '일정 설명')),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('색상: '),
                  const SizedBox(width: 8),
                  DropdownButton<Color>(
                    value: _selectedDialogColor,
                    items: availableColors.map((color) {
                      return DropdownMenuItem(
                        value: color,
                        child: CircleAvatar(backgroundColor: color, radius: 10),
                      );
                    }).toList(),
                    onChanged: (color) {
                      if (color != null) {
                        setState(() => _selectedDialogColor = color);
                        setStateDialog(() {});
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                final subtitle = subtitleController.text.trim();
                if (title.isNotEmpty) {
                  final event = {
                    'title': title,
                    'subtitle': subtitle,
                    'color': _selectedDialogColor.value.toString(),
                  };
                  setState(() {
                    _events.putIfAbsent(normalized, () => []).add(event);
                  });
                  Navigator.pop(context);
                  _saveEventToFirestore(normalized, title, subtitle, _selectedDialogColor.value.toString());
                }
              },
              child: const Text('추가'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(DateTime date, Map<String, String> oldEvent) {
    final titleController = TextEditingController(text: oldEvent['title']);
    final subtitleController = TextEditingController(text: oldEvent['subtitle']);
    _selectedDialogColor = Color(int.parse(oldEvent['color']!));

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('일정 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(hintText: '일정 제목')),
              const SizedBox(height: 8),
              TextField(controller: subtitleController, decoration: const InputDecoration(hintText: '일정 설명')),
              const SizedBox(height: 12),
              DropdownButton<Color>(
                value: _selectedDialogColor,
                items: availableColors.map((color) => DropdownMenuItem(
                  value: color,
                  child: CircleAvatar(backgroundColor: color, radius: 10),
                )).toList(),
                onChanged: (color) {
                  if (color != null) {
                    setState(() => _selectedDialogColor = color);
                    setStateDialog(() {});
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newEvent = {
                  'title': titleController.text.trim(),
                  'subtitle': subtitleController.text.trim(),
                  'color': _selectedDialogColor.value.toString(),
                };
                setState(() {
                  _events[date]!.remove(oldEvent);
                  _events[date]!.add(newEvent);
                });
                await _deleteEventFromFirestore(date, oldEvent);
                await _saveEventToFirestore(date, newEvent['title']!, newEvent['subtitle']!, newEvent['color']!);
                Navigator.pop(context);
              },
              child: const Text('수정'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
        _selectedDay = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text('${_focusedDay.year}년 ${_focusedDay.month}월'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _showScheduleDialog(_selectedDay!);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            headerVisible: false,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              weekendTextStyle: const TextStyle(color: Colors.red),
              markerDecoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.take(3).map((event) {
                    final colorValue = int.tryParse((event as Map<String, String>)['color'] ?? '') ?? Colors.green.value;
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('날짜를 선택해주세요'))
                : _getEventsForDay(_selectedDay!).isEmpty
                ? const Center(child: Text('일정이 없습니다'))
                : ListView.separated(
              itemCount: _getEventsForDay(_selectedDay!).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final event = _getEventsForDay(_selectedDay!)[index];
                final colorValue = int.tryParse(event['color'] ?? '') ?? Colors.green.value;
                final color = Color(colorValue);
                return ListTile(
                  leading: Icon(Icons.circle, size: 10, color: color),
                  title: Text(event['title'] ?? ''),
                  subtitle: event['subtitle'] != null && event['subtitle']!.isNotEmpty
                      ? Text(event['subtitle']!)
                      : null,
                  onTap: () => _showEditDialog(_selectedDay!, event),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () async {
                      await _deleteEventFromFirestore(_selectedDay!, event);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
