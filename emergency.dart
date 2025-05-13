import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // url_launcher 패키지 임포트

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  // 비상 연락처 목록 (필요에 따라 수정하세요)
  final List<Map<String, String>> emergencyContacts = const [
    {'name': '보호자 1', 'number': '010-1111-1111'},
    {'name': '보호자 2', 'number': '010-2222-2222'},
    {'name': '경찰서', 'number': '112'},
    {'name': '소방서', 'number': '119'},
  ];

  // 전화 걸기 기능을 수행하는 함수
  Future<void> _launchPhoneCall(String phoneNumber, BuildContext context) async {
    final Uri launchUri = Uri(
      scheme: 'tel', // 전화 걸기 스킴
      path: phoneNumber, // 전화번호
    );
    // 해당 URI를 실행할 수 있는지 확인 후 실행
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // 실행할 수 없는 경우 (예: 전화 기능이 없는 기기) 사용자에게 알림
      print('Could not launch $launchUri');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('전화 걸기 기능을 사용할 수 없습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비상 연락'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center( // 컬럼 자체를 가운데 정렬
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 세로 상단 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
            children: <Widget>[
              // 1. 비상등 아이콘 (가운데 상단)
              Icon(
                Icons.warning, // 비상등 아이콘
                size: 100.0, // 아이콘 크기
                color: Colors.red, // 아이콘 색상
              ),
              const SizedBox(height: 30.0), // 아이콘과 텍스트 사이 간격

              // 2. 비상 연락처 텍스트
              const Text(
                '비상 연락처',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0), // 텍스트와 연락처 목록 사이 간격

              // 3. 비상 연락처 목록 및 전화 아이콘
              Expanded( // 남은 공간 활용 (스크롤 가능하게 하려면 ListView로 변경)
                child: SingleChildScrollView( // 목록이 길어지면 스크롤 가능하게
                  child: Column( // 연락처 항목들을 세로로 나열
                    children: emergencyContacts.map((contact) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // 각 연락처 항목 간 세로 간격
                        child: SizedBox( // Row가 부모 너비를 최대한 사용하도록 제한 (가운데 정렬된 Column의 자식이므로 Center 안에 있음)
                          width: double.infinity, // 최대한 넓게 (Center 안에서 효과 발휘)
                          child: Row( // 연락처 이름/번호와 전화 아이콘을 가로로 배치
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 끝으로 배치
                            children: [
                              // 연락처 이름 (선택 사항) 및 번호
                              Text(
                                // 연락처 이름도 표시하려면 '${contact['name']}: ${contact['number']}' 사용
                                '${contact['number']}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // 전화 아이콘 버튼
                              IconButton(
                                icon: const Icon(Icons.phone, color: Colors.green), // 전화 아이콘
                                onPressed: () {
                                  // 전화 아이콘 클릭 시 해당 번호로 전화 걸기 함수 호출
                                  _launchPhoneCall(contact['number']!, context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(), // map 결과를 List로 변환
                  ),
                ),
              ),
              // 하단 여백이 필요하다면 여기에 const SizedBox 추가
            ],
          ),
        ),
      ),
    );
  }
}
