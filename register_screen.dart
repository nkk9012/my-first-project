import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginR.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _pwController = TextEditingController();
  final _pwCheckController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedTelecom;
  final List<String> _telecomOptions = ['SKT', 'KT', 'LGU+', '알뜰폰'];

  List<bool> _genderSelection = [false, false];
  List<bool> _nationalitySelection = [true, false];

  bool _isParentTab = true;
  bool _termsAgreed = false;
  String? _pwMatchMessage;
  String? _pwRuleMessage;
  String? _phoneVerificationMessage;
  bool _phoneVerified = false;

  bool _showPassword = false;
  bool _showPasswordCheck = false;

  String? _emailErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isParentTab = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pwController.dispose();
    _pwCheckController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidPassword(String pw) {
    final regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$%^&*])[A-Za-z\d!@#\$%^&*]{8,16}$');
    return regex.hasMatch(pw);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return regex.hasMatch(email);
  }

  void _validateEmail(String value) {
    setState(() {
      _emailErrorMessage = _isValidEmail(value)
          ? null
          : '이메일 형식에 맞지 않습니다 ex) xxxx@gmail.com';
    });
  }

  void _toggleGender(int index) {
    setState(() {
      _genderSelection = List.generate(_genderSelection.length, (i) => i == index);
    });
  }

  void _toggleNationality(int index) {
    setState(() {
      _nationalitySelection = List.generate(_nationalitySelection.length, (i) => i == index);
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (_isValidPassword(value)) {
        _pwRuleMessage = '비밀번호 조건 충족 완료';
      } else {
        _pwRuleMessage = '비밀번호는 8~16자, 영문 대/소문자, 숫자, 특수문자를 포함해야 합니다';
      }

      if (_pwCheckController.text.isNotEmpty) {
        _pwMatchMessage = _pwCheckController.text != _pwController.text
            ? '비밀번호가 동일하지 않습니다'
            : null;
      }
    });
  }

  void _validatePasswordMatch(String value) {
    setState(() {
      _pwMatchMessage = value != _pwController.text
          ? '비밀번호가 동일하지 않습니다'
          : null;
    });
  }

  void _verifyPhoneNumber() {
    setState(() {
      final phone = _phoneController.text.trim();
      if (phone.length >= 10) {
        _phoneVerified = true;
        _phoneVerificationMessage = '인증 완료';
      } else {
        _phoneVerified = false;
        _phoneVerificationMessage = '휴대폰 번호를 다시 확인해주세요';
      }
    });
  }

  void _submitForm() {
    if (_pwRuleMessage != '비밀번호 조건 충족 완료') {
      _showMessage('비밀번호 조건을 확인해주세요', isError: true);
      return;
    }
    if (_pwMatchMessage != null) {
      _showMessage('비밀번호가 동일하지 않습니다', isError: true);
      return;
    }
    if (!_phoneVerified) {
      _showMessage('휴대폰 인증을 완료해주세요', isError: true);
      return;
    }
    if (!_termsAgreed) {
      _showMessage('약관에 동의해야 회원가입이 가능합니다', isError: true);
      return;
    }
    registerUser();
    _showMessage('회원가입이 완료되었습니다!');
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: '이메일 주소'),
            keyboardType: TextInputType.emailAddress,
            onChanged: _validateEmail,
          ),
          if (_emailErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _emailErrorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pwController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              suffixIcon: Listener(
                onPointerDown: (_) => setState(() => _showPassword = true),
                onPointerUp: (_) => setState(() => _showPassword = false),
                child: const Icon(Icons.remove_red_eye),
              ),
            ),
            onChanged: _validatePassword,
          ),
          if (_pwRuleMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _pwRuleMessage!,
                style: TextStyle(
                  color: _pwRuleMessage == '비밀번호 조건 충족 완료' ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pwCheckController,
            obscureText: !_showPasswordCheck,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              suffixIcon: Listener(
                onPointerDown: (_) => setState(() => _showPasswordCheck = true),
                onPointerUp: (_) => setState(() => _showPasswordCheck = false),
                child: const Icon(Icons.remove_red_eye),
              ),
            ),
            onChanged: _validatePasswordMatch,
          ),
          if (_pwMatchMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _pwMatchMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '이름'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '생년월일 8자리'),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: _genderSelection,
                  onPressed: _toggleGender,
                  borderRadius: BorderRadius.circular(8.0),
                  constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100),
                  children: const [Text('남자'), Text('여자')],
                ),
                const SizedBox(height: 10),
                ToggleButtons(
                  isSelected: _nationalitySelection,
                  onPressed: _toggleNationality,
                  borderRadius: BorderRadius.circular(8.0),
                  constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100),
                  fillColor: Colors.green,
                  selectedColor: Colors.white,
                  selectedBorderColor: Colors.green,
                  children: const [Text('내국인'), Text('외국인')],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedTelecom,
            items: _telecomOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTelecom = newValue;
              });
            },
            decoration: const InputDecoration(
              labelText: '통신사 선택',
              prefixIcon: Icon(Icons.signal_cellular_alt),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '휴대폰번호',
                    prefixIcon: Icon(Icons.phone_android_outlined),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _verifyPhoneNumber,
                child: const Text('인증 요청'),
              ),
            ],
          ),
          if (_phoneVerificationMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _phoneVerificationMessage!,
                style: TextStyle(
                  color: _phoneVerified ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Row(
              children: [
                Checkbox(
                  value: _termsAgreed,
                  onChanged: (bool? value) {
                    setState(() => _termsAgreed = value ?? false);
                  },
                  visualDensity: VisualDensity.compact,
                ),
                const Text('만 14세 인증 약관 전체동의', style: TextStyle(fontSize: 14)),
              ],
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('여기에 약관 상세 내용이 표시됩니다.'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('회원가입 완료', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '부모'), Tab(text: '자녀')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(),
          _buildForm(),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _pwController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'birth': _birthController.text.trim(),
        'phone': _phoneController.text.trim(),
        'telecom': _selectedTelecom,
        'gender': _genderSelection[0] ? '남자' : '여자',
        'nationality': _nationalitySelection[0] ? '내국인' : '외국인',
        'role': _isParentTab ? 'parent' : 'child',
      });

      _showMessage('회원가입 완료! 로그인 페이지로 이동합니다');
      print('회원가입 성공 → 로그인 화면으로 이동합니다');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => loginR()),
      );

    } catch (e) {
      _showMessage('회원가입 실패: $e', isError: true);
    }
  }
}
