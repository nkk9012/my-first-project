import 'package:flutter/material.dart';
import 'settings.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar를 사용하지 않고 body에서 직접 요소 배치
      body: Stack( // 요소들을 겹쳐서 배치하기 위해 Stack 사용
        children: [
          // 주요 콘텐츠 (프로필, 버튼들)
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0), // 상단 여백 조절
            child: Center( // 가운데 정렬
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // 컬럼 상단 정렬
                crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
                children: <Widget>[
                  // 1. 원형 프로필 이미지 (가운데 상단)
                  CircleAvatar(
                    radius: 60.0, // 원의 크기 조절
                    backgroundColor: Colors.green[200], // 배경색 (ParentsScreen과 구분)
                    // backgroundImage: AssetImage('assets/my_profile_image.png'), // 실제 이미지 사용 시
                    child: Icon( // 이미지 없을 때 아이콘 표시
                      Icons.person,
                      size: 80.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40.0), // 프로필과 버튼 사이 간격

                  // 2. 캘린더, 알람, 게시판, 부모위치 버튼들 (2x2 그리드 형태)
                  Expanded( // 남은 공간 최대한 활용
                    child: GridView.count(
                      crossAxisCount: 2, // 가로에 2개씩 배치
                      crossAxisSpacing: 20.0, // 가로 간격
                      mainAxisSpacing: 20.0, // 세로 간격
                      shrinkWrap: true, // GridView가 차지하는 공간을 자식 위젯 크기에 맞춤
                      physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화 (화면에 다 보인다고 가정)
                      children: <Widget>[
                        _buildFeatureButton(context, Icons.calendar_today, '캘린더', () {
                          // 캘린더 버튼 클릭 시 동작
                          print('내 캘린더 버튼 클릭됨');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => MyCalendarScreen()));
                        }),
                        _buildFeatureButton(context, Icons.alarm, '알람', () {
                          // 알람 버튼 클릭 시 동작
                          print('내 알람 버튼 클릭됨');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => MyAlarmScreen()));
                        }),
                        _buildFeatureButton(context, Icons.article, '게시판', () {
                          // 게시판 버튼 클릭 시 동작
                          print('내 게시판 버튼 클릭됨');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => MyBoardScreen()));
                        }),
                        _buildFeatureButton(context, Icons.location_on, '부모 위치', () {
                          // 부모 위치 버튼 클릭 시 동작
                          print('부모 위치 버튼 클릭됨');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => ParentLocationScreen()));
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. 설정 버튼 (우측 상단)
          Positioned( // Stack 안에서 위치를 직접 지정
            top: 40.0, // 상단에서 떨어진 거리
            right: 10.0, // 오른쪽에서 떨어진 거리
            child: IconButton(
              icon: const Icon(Icons.settings, size: 30.0, color: Colors.grey), // 설정 아이콘
              onPressed: () {
                // 설정 버튼 클릭 시 동작
                print('설정 버튼 클릭됨');
                // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())); // 설정 화면으로 이동
              },
            ),
          ),
        ],
      ),
    );
  }

  // 기능 버튼 위젯 템플릿 (ParentsScreen과 동일)
  Widget _buildFeatureButton(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return Card( // 카드 형태로 감싸서 입체감 효과
      elevation: 4.0, // 그림자 깊이
      shape: RoundedRectangleBorder( // 모서리 둥글게
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell( // 클릭 가능한 영역으로 만듦
        onTap: onTap, // 클릭 시 실행될 함수
        borderRadius: BorderRadius.circular(15.0), // InkWell의 둥근 모서리 설정 (Card와 동일하게)
        child: Center( // 카드 내용 중앙 정렬
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
              children: <Widget>[
                Icon(
                  icon,
                  size: 50.0, // 아이콘 크기
                  color: Theme.of(context).primaryColor, // 테마 기본 색상 사용
                ),
                const SizedBox(height: 8.0), // 아이콘과 텍스트 사이 간격
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}