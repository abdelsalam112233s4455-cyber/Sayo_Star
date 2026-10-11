import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../mainscreen/home.dart';

final String host_link_timer =
    "https://exotic-singer-bathroom-disciplines.trycloudflare.com";

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late final isDark =
      Theme.of(context).brightness == Brightness.dark;

  String selectedType = "ملاحظة عامة";

  TextEditingController note = TextEditingController();

  String massage = "";

  bool isLoading = false;

  Future<void> sendnote() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$host_link_timer/users/note'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'des': note.text,
          'type': selectedType,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          massage = data["message"].toString().trim();
        });

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'حدث خطأ أثناء إرسال الملاحظة',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الملاحظات',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF181A1F)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF292C34)
                      : const Color(0xFFE7E7EC),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2BE2)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.feedback_outlined,
                      size: 32,
                      color: Color(0xFF8B2BE2),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'رأيك يهمنا ❤️',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF202124),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'ساعدنا في تحسين SaYo Star من خلال مشاركة رأيك أو ملاحظاتك.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark
                          ? const Color(0xFF9DA2AC)
                          : const Color(0xFF777B84),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'نوع الملاحظة',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF34343A),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1C1E24)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF292C34)
                      : const Color(0xFFE2E4E8),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'ملاحظة عامة',
                      child: Text('ملاحظة عامة'),
                    ),
                    DropdownMenuItem(
                      value: 'اقتراح',
                      child: Text('اقتراح'),
                    ),
                    DropdownMenuItem(
                      value: 'مشكلة',
                      child: Text('الإبلاغ عن مشكلة'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'اكتب ملاحظتك',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF34343A),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: note,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظتك هنا...',
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : sendnote,
                icon: isLoading
                    ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  size: 19,
                ),
                label: Text(
                  isLoading
                      ? 'جاري الإرسال...'
                      : 'إرسال الملاحظة',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}