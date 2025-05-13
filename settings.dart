import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'loginR.dart'; // 로그인 화면 import
import 'start.dart'; // 앱 첫 화면
import 'alarm.dart';
import 'profile.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  static const String correctPassword = '1234'; // 정적 상수로 선언

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 나가기 버튼을 눌렀을 때 처리 (이전 화면으로 돌아가기)
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('주소 관리'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // 주소 관리로 이동하는 코드
            },
          ),
          ListTile(
            title: const Text('비밀번호 재설정'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // 비밀번호 재설정 화면으로 이동하는 코드
            },
          ),
          ListTile(
            title: const Text('알람 설정'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlarmManagementPage(), // 알람 설정 화면으로 이동
                ),
              );
            },
          ),
          ListTile(
            title: const Text('이메일 변경'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // 이메일 변경 화면으로 이동하는 코드
            },
          ),
          ListTile(
            title: const Text('프로필 사진 변경'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(), // 프로필 화면으로 이동
                ),
              );
            },
          ),
          ListTile(
            title: const Text('전화번호 변경'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // 전화번호 변경 화면으로 이동하는 코드
            },
          ),
          ListTile(
            title: const Text('로그아웃'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('로그아웃 하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 팝업 닫기 (아니오)
                        },
                        child: const Text('아니오'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 팝업 닫고 로그인 화면으로 이동
                          Navigator.of(context).pop(); // 먼저 팝업 닫기
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => loginR()),
                                (Route<dynamic> route) => false, // 모든 이전 화면 제거
                          );
                        },
                        child: const Text('예'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('회원 탈퇴'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              final TextEditingController pwController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('회원 탈퇴'),
                    content: TextField(
                      controller: pwController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '비밀번호를 입력하세요',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (pwController.text == correctPassword) {
                            Navigator.of(context).pop(); // 비번 입력창 닫기
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('회원 탈퇴'),
                                  content: const Text('정말 회원 탈퇴하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 팝업 닫기
                                      },
                                      child: const Text('아니오'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context) => const StartScreen()),
                                              (Route<dynamic> route) => false,
                                        );
                                      },
                                      child: const Text('예'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Navigator.of(context).pop(); // 비번 입력창 닫기
                            Fluttertoast.showToast(
                              msg: "비밀번호를 잘못 입력하셨습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
