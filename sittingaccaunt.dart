import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '/mainscreen/home.dart';

// ignore: non_constant_identifier_names
final host_link_timer =
    "https://exotic-singer-bathroom-disciplines.trycloudflare.com";

// ignore: camel_case_types
class Sittingaccaunt extends StatefulWidget {
  const Sittingaccaunt({super.key});

  @override
  State<Sittingaccaunt> createState() => _Sittingaccaunt();
}

// ignore: camel_case_types
class _Sittingaccaunt extends State<Sittingaccaunt> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? selectedGender;
  String? selectedCountry;
  String? selectedAge;

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

  // ============================================================
  // SnackBar موحد
  // ============================================================

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
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
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),

              const SizedBox(width: 12),

              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // SnackBar نجاح
  // ============================================================

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
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

              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // محاولة استخراج رسالة مفهومة من رد السيرفر
  // ============================================================

  String _getServerErrorMessage(http.Response response) {
    final String body = response.body.trim();

    if (body.isEmpty) {
      return 'حدث خطأ أثناء إرسال البيانات. رمز الخطأ: ${response.statusCode}';
    }

    try {
      final dynamic decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        final possibleMessages = [
          decoded['message'],
          decoded['error'],
          decoded['msg'],
          decoded['detail'],
          decoded['reason'],
        ];

        for (final value in possibleMessages) {
          if (value != null &&
              value.toString().trim().isNotEmpty) {
            return value.toString().trim();
          }
        }
      }
    } catch (_) {
      // الرد ليس JSON، سنستخدم النص كما هو
    }

    if (body.length <= 300) {
      return body;
    }

    return 'حدث خطأ أثناء إرسال البيانات. رمز الخطأ: ${response.statusCode}';
  }

  // ============================================================
  // اختيار الصورة من الملفات
  // ============================================================

  Future<File?> pickImageFromPhone() async {
    try {
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
    } catch (e) {
      _showErrorSnackBar(
        'تعذر اختيار الصورة من الملفات',
      );
      return null;
    }
  }

  // ============================================================
  // التصوير بالكاميرا
  // ============================================================

  Future<File?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      _showErrorSnackBar(
        'تعذر فتح الكاميرا أو التقاط الصورة',
      );
      return null;
    }
  }

  // ============================================================
  // اختيار مصدر الصورة
  // ============================================================

  Future<void> _showImagePicker() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            28,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'اختيار صورة الملف الشخصي',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'اختر الطريقة التي تريد استخدامها',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    // ==================================================
                    // الكاميرا
                    // ==================================================

                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          Navigator.pop(sheetContext);

                          final File? image =
                          await pickImageFromCamera();

                          if (image != null && mounted) {
                            setState(() {
                              _selectedImage = image;
                            });

                            debugPrint(
                              '📸 تم التقاط الصورة: ${image.path}',
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withOpacity(.15),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 34,
                                color: Color.fromARGB(
                                  255,
                                  238,
                                  18,
                                  128,
                                ),
                              ),

                              SizedBox(height: 10),

                              Text(
                                'التصوير',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                'استخدم الكاميرا',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ==================================================
                    // الملفات
                    // ==================================================

                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          Navigator.pop(sheetContext);

                          final File? image =
                          await pickImageFromPhone();

                          if (image != null && mounted) {
                            setState(() {
                              _selectedImage = image;
                            });

                            debugPrint(
                              '🖼️ تم اختيار الصورة: ${image.path}',
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withOpacity(.15),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.folder_rounded,
                                size: 34,
                                color: Color.fromARGB(
                                  255,
                                  238,
                                  18,
                                  128,
                                ),
                              ),

                              SizedBox(height: 10),

                              Text(
                                'الملفات',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                'اختر من الجهاز',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // حفظ البيانات
  // ============================================================

  Future<void> _submitAndSaveData() async {
    final String username = _nameController.text.trim();

    // ------------------------------------------------------------
    // التحقق من الاسم
    // ------------------------------------------------------------

    if (username.isEmpty) {
      _showErrorSnackBar(
        'يرجى إدخال الاسم',
      );
      return;
    }

    // ------------------------------------------------------------
    // التحقق من النوع
    // ------------------------------------------------------------

    if (selectedGender == null ||
        selectedGender!.isEmpty) {
      _showErrorSnackBar(
        'يرجى اختيار الجنس',
      );
      return;
    }

    // ------------------------------------------------------------
    // التحقق من الصورة قبل بدء الإرسال
    // ------------------------------------------------------------

    if (_selectedImage == null) {
      _showErrorSnackBar(
        'عليك اختيار صورة للبروفايل',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // المستخدم الحالي
      // ----------------------------------------------------------

      final User? currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _showErrorSnackBar(
          'لم يتم العثور على حساب مسجل حاليًا',
        );
        return;
      }

      final String email = currentUser.email ?? '';

      if (email.isEmpty) {
        _showErrorSnackBar(
          'لم يتم العثور على بريد الحساب',
        );
        return;
      }

      // ----------------------------------------------------------
      // الصورة
      // ----------------------------------------------------------

      final File imageFile = _selectedImage!;

      final int size = await imageFile.length();

      final double sizeMB =
          size / (1024 * 1024);

      // الحد الأقصى 2MB حسب الكود الأصلي
      if (sizeMB > 2) {
        _showErrorSnackBar(
          'حجم الصورة كبير جدًا. الحد الأقصى المسموح 2 ميجابايت',
        );
        return;
      }

      final List<int> imageBytes =
      await imageFile.readAsBytes();

      final String avatarBase64 =
      base64Encode(imageBytes);

      // ----------------------------------------------------------
      // البيانات
      // ----------------------------------------------------------

      final Map<String, dynamic> userData = {
        'username': username,
        'country': selectedCountry ?? '',
        'age': selectedAge ?? '',
        'gender': selectedGender,
        'bio': _bioController.text.trim(),
        'avatarUrl': avatarBase64,
      };

      // ----------------------------------------------------------
      // إرسال البيانات للسيرفر
      // ----------------------------------------------------------

      http.Response response;

      try {
        response = await http.put(
          Uri.parse(
            '$host_link_timer/users/iditto/${Uri.encodeComponent(email)}',
          ),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(userData),
        );
      } on SocketException {
        _showErrorSnackBar(
          'لا يوجد اتصال بالإنترنت أو لا يمكن الوصول إلى السيرفر',
        );
        return;
      } on http.ClientException {
        _showErrorSnackBar(
          'تعذر الاتصال بالسيرفر',
        );
        return;
      } on FormatException {
        _showErrorSnackBar(
          'عنوان السيرفر غير صحيح',
        );
        return;
      }

      // ----------------------------------------------------------
      // التحقق من نتيجة السيرفر
      // ----------------------------------------------------------

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        final String serverMessage =
        _getServerErrorMessage(response);

        _showErrorSnackBar(
          serverMessage,
        );

        debugPrint(
          '❌ Server Status: ${response.statusCode}',
        );

        debugPrint(
          '❌ Server Response: ${response.body}',
        );

        return;
      }

      // ----------------------------------------------------------
      // نجاح
      // ----------------------------------------------------------

      debugPrint(
        '🟢 تم إرسال بيانات المستخدم للسيرفر',
      );

      if (!mounted) return;

      _showSuccessSnackBar(
        'تم حفظ البيانات بنجاح! 🚀',
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
            (route) => false,
      );
    } on SocketException {
      _showErrorSnackBar(
        'لا يوجد اتصال بالإنترنت',
      );
    } catch (e) {
      // ----------------------------------------------------------
      // أي خطأ غير معروف
      // ----------------------------------------------------------

      debugPrint(
        '❌ Unexpected Error: $e',
      );

      _showErrorSnackBar(
        'حدث خطأ غير متوقع أثناء حفظ البيانات',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // الشاشة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 18),

                // =================================================
                // صورة البروفايل
                // =================================================

                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.08,
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
                            color:
                            Colors.grey.shade400,
                          ),
                        ),
                      ),

                      // =================================================
                      // زر الكاميرا
                      // =================================================

                      Container(
                        width: 35,
                        height: 35,
                        decoration:
                        const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Color.fromARGB(
                              255,
                              238,
                              18,
                              128,
                            ),
                          ),
                          onPressed:
                          _showImagePicker,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "يجب ان يكون نوع الصوره png",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // الاسم
                // =================================================

                const Text(
                  'ادخل اﻷسم المراد',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                TextField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  decoration:
                  const InputDecoration(
                    hintText: 'الاسم',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // =================================================
                // النوع
                // =================================================

                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration:
                  const InputDecoration(
                    labelText: 'النوع',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text(
                    'اختر النوع',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'ذكر',
                      child: Text('♂️ذكر'),
                    ),
                    DropdownMenuItem(
                      value: 'أنثى',
                      child: Text('♀️أنثى'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  'اريد ان تكون الدول فقط العربيه.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                // =================================================
                // الدولة والعمر
                // =================================================

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                          border: Border.all(
                            color: Colors.black45,
                            width: 1.2,
                          ),
                        ),
                        child:
                        DropdownButtonHideUnderline(
                          child:
                          DropdownButton<String>(
                            value: selectedCountry,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black54,
                            ),
                            hint: const Text(
                              'إختيار الدولة',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            isExpanded: true,
                            items: arabCountries
                                .map(
                                  (String country) {
                                return DropdownMenuItem<
                                    String>(
                                  value: country,
                                  child: Text(
                                    country,
                                    style:
                                    const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCountry =
                                    value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                          border: Border.all(
                            color: Colors.black45,
                            width: 1.2,
                          ),
                        ),
                        child:
                        DropdownButtonHideUnderline(
                          child:
                          DropdownButton<String>(
                            value: selectedAge,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black54,
                            ),
                            hint: const Text(
                              'إختيار العمر',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            isExpanded: true,
                            items: ageList.map(
                                  (String age) {
                                return DropdownMenuItem<
                                    String>(
                                  value: age,
                                  child: Text(
                                    age,
                                    style:
                                    const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
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
                const SizedBox(height: 16),

                // =================================================
                // البايو
                // =================================================

                TextField(
                  controller: _bioController,
                  textDirection:
                  TextDirection.rtl,
                  decoration:
                  const InputDecoration(
                    hintText: 'بايو',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // زر الحفظ
                // =================================================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _submitAndSaveData,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color.fromARGB(
                        255,
                        219,
                        8,
                        226,
                      ),
                      elevation: 0,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                        AlwaysStoppedAnimation<
                            Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text(
                      'حفظ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
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