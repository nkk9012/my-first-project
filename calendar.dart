import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now(); // 현재 보고 있는 달
  DateTime? _selectedDay; // 선택된 날짜
  CalendarFormat _calendarFormat = CalendarFormat.month; // month 형식 고정
  Map<DateTime, List<String>> _events = {}; // 일정 저장용 맵

  // 날짜별 일정 가져오기
  List<String> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  // 일정 추가/삭제 다이얼로그
  void _showScheduleDialog(DateTime date) {
    final controller = TextEditingController();
    final normalized = DateTime(date.year, date.month, date.day);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${normalized.year}-${normalized.month}-${normalized.day} 일정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '일정을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _events.putIfAbsent(normalized, () => []).add(controller.text);
              });
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _events.remove(normalized);
              });
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  // 년/월 클릭 시 선택 다이얼로그
  void _selectYearMonth() async {
    final now = DateTime.now();
    final yearList = List.generate(11, (i) => now.year - 5 + i);
    final monthList = List.generate(12, (i) => i + 1);

    int selectedYear = _focusedDay.year;
    int selectedMonth = _focusedDay.month;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('날짜 선택'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatefulBuilder(
              builder: (context, setStateDialog) => DropdownButton<int>(
                value: selectedYear,
                items: yearList
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y년')))
                    .toList(),
                onChanged: (y) {
                  if (y != null) {
                    setStateDialog(() => selectedYear = y);
                  }
                },
              ),
            ),
            StatefulBuilder(
              builder: (context, setStateDialog) => DropdownButton<int>(
                value: selectedMonth,
                items: monthList
                    .map((m) => DropdownMenuItem(value: m, child: Text('$m월')))
                    .toList(),
                onChanged: (m) {
                  if (m != null) {
                    setStateDialog(() => selectedMonth = m);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(selectedYear, selectedMonth);
              });
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yearMonthText = '${_focusedDay.year}년 ${_focusedDay.month}월';

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _selectYearMonth, // 제목 클릭 시 드롭다운 열기
          child: Text(yearMonthText),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showScheduleDialog(selectedDay);
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            onFormatChanged: (_) {}, // 포맷 변경 막기
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              weekendTextStyle: const TextStyle(color: Colors.red), // 주말 빨간색
              markerDecoration: const BoxDecoration( // 일정 있을 때 점 표시
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 12),

          // 일정 목록 영역
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('날짜를 선택해주세요'))
                : _getEventsForDay(_selectedDay!).isEmpty
                ? const Center(child: Text('일정이 없습니다'))
                : ListView.builder(
              itemCount: _getEventsForDay(_selectedDay!).length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.circle, size: 10, color: Colors.green),
                  title: Text(_getEventsForDay(_selectedDay!)[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}