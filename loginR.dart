import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'parents.dart';
import 'me.dart';

class loginR extends StatefulWidget {
  @override
  State<loginR> createState() => _loginRState();
}

class _loginRState extends State<loginR> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in'),
        elevation: 0.0,
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              Center(
                child: Image(
                  image: AssetImage('assets/image/seaotter.png'),
                  width: 200.0,
                ),
              ),
              Form(
                child: Theme(
                  data: ThemeData(
                      primaryColor: Colors.grey,
                      inputDecorationTheme: InputDecorationTheme(
                          labelStyle: TextStyle(color: Colors.teal, fontSize: 15.0))),
                  child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Builder(builder: (context) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(labelText: 'Enter Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextField(
                            controller: controller2,
                            decoration: InputDecoration(labelText: 'Enter password'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(height: 40.0),
                          ElevatedButton(
                            onPressed: loginUser,
                            child: Icon(Icons.arrow_forward, color: Colors.white, size: 35.0),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  // 나중에 아이디 찾기 페이지로 이동
                                },
                                child: Text('아이디 찾기'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // 나중에 비밀번호 찾기 페이지로 이동
                                },
                                child: Text('비밀번호 찾기'),
                              ),
                            ],
                          )
                        ],
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> loginUser() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: controller.text.trim(),
        password: controller2.text.trim(),
      );

      final uid = credential.user!.uid;
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final role = snapshot['role'];

      if (role == 'parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParentsScreen()),
        );
      } else if (role == 'child') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MeScreen()),
        );
      } else {
        showSnackBar(context, Text('역할 정보가 없습니다'));
      }
    } catch (e) {
      showSnackBar(context, Text('로그인 실패: $e'));
    }
  }

  }


void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(255, 112, 48, 48),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class NextPage extends StatelessWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();  // 이 페이지에 내용을 추가할 수 있어
  }
}