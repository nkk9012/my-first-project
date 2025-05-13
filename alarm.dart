import 'package:flutter/material.dart';

class AlarmManagementPage extends StatefulWidget {
  const AlarmManagementPage({super.key});

  @override
  State<AlarmManagementPage> createState() => _AlarmManagementPageState();
}

class _AlarmManagementPageState extends State<AlarmManagementPage> {
  bool isAllAlarm = false;
  bool isPartialAlarm = false;
  bool isAllOn = false;

  Map<String, bool> partialAlarms = {
    '뭘로 쓰지1': false,
    '뭘로 쓰지2': false,
    '뭘로 쓰지3': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알람 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 전체 알람 설정
            ListTile(
              title: const Text('전체 알람 설정'),
              leading: Radio<bool>(
                value: true,
                groupValue: isAllAlarm,
                onChanged: (_) {
                  setState(() {
                    isAllAlarm = true;
                    isPartialAlarm = false;
                  });
                },
              ),
            ),
            if (isAllAlarm)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAllOn = true;
                        for (var key in partialAlarms.keys) {
                          partialAlarms[key] = true;
                        }
                      });
                      print('전체 알람 켜짐');
                    },
                    child: const Text('전체 알람 켜기'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAllOn = false;
                        for (var key in partialAlarms.keys) {
                          partialAlarms[key] = false;
                        }
                      });
                      print('전체 알람 꺼짐');
                    },
                    child: const Text('전체 알람 끄기'),
                  ),
                ],
              ),

            const Divider(),

            // 부분 알람 설정
            ListTile(
              title: const Text('부분 알람 설정'),
              leading: Radio<bool>(
                value: true,
                groupValue: isPartialAlarm,
                onChanged: (_) {
                  setState(() {
                    isAllAlarm = false;
                    isPartialAlarm = true;
                  });
                },
              ),
            ),

            // 중간 알람 목록 + 하단 안내문구
            Expanded(
              child: Column(
                children: [
                  if (isPartialAlarm)
                    ...partialAlarms.entries.map((entry) {
                      return SwitchListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (val) {
                          setState(() {
                            partialAlarms[entry.key] = val;
                          });
                          print('${entry.key} ${val ? '켜짐' : '꺼짐'}');
                        },
                      );
                    }).toList(),

                  const Spacer(), // 아래쪽으로 밀어주기
                  const Text(
                    '"중요 업데이트 권장 알람은 따로 설정 불가합니다"',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
