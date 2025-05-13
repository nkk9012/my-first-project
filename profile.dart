import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final String _defaultImage = 'assets/image/seaotter.png';
  String? _currentAssetImage;

  void _setDefaultProfile() {
    setState(() {
      _selectedImage = null;
      _currentAssetImage = _defaultImage;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _currentAssetImage = null;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 80,
        backgroundImage: FileImage(_selectedImage!),
      );
    } else if (_currentAssetImage != null) {
      return CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage(_currentAssetImage!),
      );
    } else {
      return const CircleAvatar(
        radius: 80,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 80, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = 170; //  버튼 너비 설정

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('프로필 설정'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          Center(child: _buildProfileImage()),
          const SizedBox(height: 100),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: _setDefaultProfile,
              child: const Text('기본 프로필 설정'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text('앨범에서 사진 선택'),
            ),
          ),
        ],
      ),
    );
  }
}
