import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../mainscreen/home.dart';

final host_link_timer =
    "https://exotic-singer-bathroom-disciplines.trycloudflare.com";

// ignore: camel_case_types
class Complete_Registration extends StatefulWidget {
  const Complete_Registration({super.key});

  @override
  State<Complete_Registration> createState() => _Complete_Registration();
}

// ignore: camel_case_types
class _Complete_Registration extends State<Complete_Registration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? selectedCountry;
  String? selectedAge;
  String selectedGender = '';

  bool _isLoading = false;
  File? _selectedImage;

  IconData myIcon = Icons.person;

  final List<String> arabCountries = [
    '🇪🇬 مصر',
    '🇸🇦 السعودية',
    '🇦🇪 الإمارات',
    '🇰🇼 الكويت',
    '🇯🇴 الأردن',
    '🇶🇦 قطر',
    '🇧🇭 البحرين',
    '🇴🇲 عُمان',
    '🇮🇶 العراق',
    '🇱🇧 لبنان',
    '🇸🇾 سوريا',
    '🇵🇸 فلسطين',
    '🇹🇳 تونس',
    '🇩🇿 الجزائر',
    '🇲🇦 المغرب',
    '🇸🇩 السودان',
    '🇱🇾 ليبيا',
    '🇲🇷 موريتانيا',
    '🇸🇴 الصومال',
    '🇩🇯 جيبوتي',
    '🇰🇲 جزر القمر',
  ];

  List<String> get ageList =>
      List.generate(40, (index) => (16 + index).toString());

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<File?> pickImageFromPhone() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile == null) {
      return null;
    }

    return File(pickedFile.path);
  }

  Future<void> _submitAndSaveData() async {
    final String username = _nameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5BD09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'يرجى ادخال الأسم',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5BD09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'يرجى ادخال الجنس',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE60606),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Text(
                  'لم يتم العثور علي مسجل حاليا',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E222B),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final String email = currentUser.email ?? '';

      String avatarBase64 = '';

      if (_selectedImage != null) {
        final file = File(_selectedImage!.path);
        final size = await file.length();
        final sizeMB = size / (1024 * 1024);

        if (sizeMB > 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDA0606),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '''رجاء استخدم صوره اقل حجما
                     عن 5mb''',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1E222B),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        final List<int> imageBytes = await _selectedImage!.readAsBytes();

        avatarBase64 = base64Encode(imageBytes);
      } else {
        setState(() {
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDA0606),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Text(
                  'عليك إختيار صوره للبروفايل',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E222B),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final Map<String, dynamic> userData = {
        'email': email,
        'username': username,
        'country': selectedCountry ?? '',
        'age': selectedAge ?? 0,
        'gender': selectedGender,
        'bio': _bioController.text.trim(),
        'avatarUrl': avatarBase64,
        'uid': FirebaseAuth.instance.currentUser?.uid,
      };

      final response = await http.post(
        Uri.parse('$host_link_timer/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to send data to server. '
          'Status code: ${response.statusCode}',
        );
      }

      debugPrint('🟢 تم إرسال بيانات المستخدم للسيرفر');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تم حفظ البيانات بنجاح! 🚀',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ Server Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 228, 38, 5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                '''حدث خطأ أثناء إرسال البيانات
               يرجى المحاولة لاحقاً.
               او تأكد منان نوع الصوره png''',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildGenderAvatar({
    required String genderKey,
    required String title,
    required String imageRoot,
  }) {
    final bool isSelected = selectedGender == genderKey;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color genderCardColor = isDark
        ? const Color(0xFF181A1F)
        : Colors.grey.shade200;

    final Color genderBorderColor = isSelected
        ? const Color(0xff00bfa5)
        : (isDark ? const Color(0xFF292C34) : Colors.grey.shade300);

    final Color titleColor = isDark
        ? const Color(0xFFF1F1F3)
        : const Color(0xff2D3142);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = genderKey;
        });
      },
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 5,
                  child: Container(
                    width: 130,
                    height: 55,
                    decoration: BoxDecoration(
                      color: genderCardColor,
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(130, 55),
                      ),
                      border: Border.all(
                        color: genderBorderColor,
                        width: isSelected ? 2.5 : 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.25 : 0.06,
                          ),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      imageRoot,
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 60,
                        color: isDark ? const Color(0xFF858A95) : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: titleColor,
            ),
          ),
          if (genderKey == 'male' && selectedGender.isEmpty)
            const Text(
              'لم يتم إدخال الجنس*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? const Color(0xFF101114)
        : const Color(0xFFF8F9FA);

    final Color primaryText = isDark
        ? const Color(0xFFF1F1F3)
        : const Color(0xFF2D3142);

    final Color secondaryText = isDark ? const Color(0xFF9DA2AC) : Colors.grey;

    final Color fieldColor = isDark ? const Color(0xFF1C1E24) : Colors.white;

    final Color borderColor = isDark ? const Color(0xFF292C34) : Colors.black45;

    final Color dropdownIconColor = isDark
        ? const Color(0xFF9DA2AC)
        : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'أهلاً بك في SaYo Star',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '~ أكمل معلومات لمطابقة أصدقاء مناسبين بدقة',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: secondaryText),
                ),

                const SizedBox(height: 18),

                // =========================
                // صورة البروفايل
                // =========================
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fieldColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.30 : 0.08,
                              ),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: isDark
                                      ? const Color(0xFF858A95)
                                      : Colors.grey.shade400,
                                ),
                        ),
                      ),

                      // =========================
                      // زر الكاميرا
                      // =========================
                      Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final File? image = await pickImageFromPhone();

                            if (image != null) {
                              setState(() {
                                _selectedImage = image;
                              });

                              debugPrint('📸 تم اختيار الصورة: ${image.path}');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  "يجب ان يكون نوع الصوره png",
                  style: TextStyle(color: secondaryText, fontSize: 13),
                ),

                const SizedBox(height: 5),

                // =========================
                // الاسم
                // =========================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: TextField(
                    controller: _nameController,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: primaryText, fontSize: 14),
                    cursorColor: const Color(0xff00bfa5),
                    decoration: InputDecoration(
                      hintText: 'الاسم',
                      hintStyle: TextStyle(color: secondaryText, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // =========================
                // الدولة والعمر
                // =========================
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: fieldColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCountry,
                            dropdownColor: fieldColor,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: dropdownIconColor,
                            ),
                            hint: Text(
                              'إختيار الدولة',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),
                            isExpanded: true,
                            items: arabCountries.map((String country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(
                                  country,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: primaryText,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCountry = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: fieldColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedAge,
                            dropdownColor: fieldColor,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: dropdownIconColor,
                            ),
                            hint: Text(
                              'إختيار العمر',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),
                            isExpanded: true,
                            items: ageList.map((String age) {
                              return DropdownMenuItem<String>(
                                value: age,
                                child: Text(
                                  age,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: primaryText,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedAge = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  'اريد ان تكون الدول فقط العربيه.',
                  style: TextStyle(color: secondaryText, fontSize: 13),
                ),

                const SizedBox(height: 16),

                // =========================
                // اختيار الجنس
                // =========================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGenderAvatar(
                      genderKey: 'male',
                      title: 'ذكر',
                      imageRoot: 'asset/male.jpeg',
                    ),
                    _buildGenderAvatar(
                      genderKey: 'female',
                      title: 'أنثى',
                      imageRoot: "asset/female.jpeg",
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // =========================
                // البايو
                // =========================
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: TextField(
                    controller: _bioController,
                    textDirection: TextDirection.rtl,
                    maxLines: null,
                    style: TextStyle(color: primaryText, fontSize: 14),
                    cursorColor: const Color(0xff00bfa5),
                    decoration: InputDecoration(
                      hintText: 'بايو',
                      hintStyle: TextStyle(color: secondaryText, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // =========================
                // الخطوة التالية
                // =========================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitAndSaveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00bfa5),
                      disabledBackgroundColor: const Color(
                        0xff00bfa5,
                      ).withValues(alpha: 0.55),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'الخطوة التالية',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
