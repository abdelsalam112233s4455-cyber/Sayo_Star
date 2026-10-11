import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:sayo/infouser/auth.dart';

import '../home/me/sittings.dart';
import 'me/nots.dart';

String serverUrl =
    'https://test-celtic-libs-listen.trycloudflare.com';

class Me extends StatefulWidget {
  const Me({super.key});

  @override
  State<Me> createState() => _MeState();
}

class _MeState extends State<Me> {
  String username = 'جاري التحميل...';
  String avatar = '';
  String uid = 'جاري التحميل...';
  String bio = 'جاري التحميل...';
  String country = 'جاري التحميل...';
  String age = 'جاري التحميل...';

  bool isLoading = true;

  Future<void> inviteFriend() async {
    final Uri inviteLink = Uri.parse('https://wa.me/201205021784');

    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'SaYo Star',
          text:
              'انضم إليّ في SaYo Star ❤️\n\n'
              'تطبيق للتعرف على أصدقاء جدد والتواصل معهم.\n\n'
              'تواصل معنا عبر واتساب:\n'
              '$inviteLink',
        ),
      );
    } catch (e) {
      debugPrint('❌ خطأ في المشاركة: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.email == null) {
      if (mounted) {
        setState(() {
          username = 'مستخدم';
          avatar = '';
          isLoading = false;
        });
      }
      return;
    }

    final String email = currentUser.email!;

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/users/check/${Uri.encodeComponent(email)}'),
        headers: {"Accept": "application/json"},
      );

      debugPrint('📧 Email: $email');
      debugPrint('📡 Status: ${response.statusCode}');
      debugPrint('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final String rawName = data['username']?.toString().trim() ?? '';

        final String rawbio = data['bio']?.toString().trim() ?? '';

        final String rawAvatar = data['avatarUrl']?.toString().trim() ?? '';

        final String rawuid = data['uid']?.toString().trim() ?? '';

        final String rawcountry = data['country']?.toString().trim() ?? '';

        final String rawage = data['age']?.toString().trim() ?? '';

        if (mounted) {
          setState(() {
            username = rawName.isNotEmpty ? rawName : 'مستخدم';
            uid = rawuid;
            bio = rawbio;
            country = rawcountry;
            age = rawage;
            avatar = rawAvatar;
            isLoading = false;
          });
        }

        debugPrint('✅ Username: $username');
        debugPrint('🖼️ Avatar received: ${avatar.isNotEmpty}');
      } else {
        if (mounted) {
          setState(() {
            username = 'فشل جلب البيانات';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب بيانات المستخدم: $e');

      if (mounted) {
        setState(() {
          username = 'حدث خطأ في الاتصال';
          isLoading = false;
        });
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final bool isDark =
            Theme.of(dialogContext).brightness == Brightness.dark;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF181A1F) : Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 27,
                ),
                const SizedBox(width: 10),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFF1F1F3)
                        : const Color(0xFF171A21),
                  ),
                ),
              ],
            ),
            content: Text(
              'هل تريد تسجيل الخروج من حسابك؟',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? const Color(0xFFB5BAC4) : Colors.black54,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFB5BAC4) : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Auth()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color pageBackground = isDark
        ? const Color(0xFF101114)
        : const Color(0xFFF6F8FC);

    final Color primaryText = isDark
        ? const Color(0xFFF1F1F3)
        : const Color(0xFF171A21);

    final Color _ = isDark ? const Color(0xFF9DA2AC) : const Color(0xFF9AA1AD);

    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            backgroundColor: pageBackground,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: pageBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'الملف الشخصي',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: IconButton(
                    tooltip: 'تسجيل الخروج',
                    onPressed: () => logout(context),
                    icon: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // التعديل الوحيد:
            // إضافة RefreshIndicator لتحديث بيانات الصفحة بالسحب لأسفل.
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: getUserData,
                color: const Color(0xFF8B2BE2),
                backgroundColor: isDark ? const Color(0xFF181A1F) : Colors
                    .white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                  child: Column(
                    children: [
                      _buildProfileHeader(
                        context,
                        username.isNotEmpty ? user : null,
                      ),

                      const SizedBox(height: 22),

                      _buildStatsCard(context),

                      const SizedBox(height: 18),

                      // ===============================
                      // معلومات المستخدم
                      // ===============================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF181A1F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF292D35)
                                : const Color(0xFFE9E9EF),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 21,
                                  color: const Color(0xFF8B2BE2),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'معلومات عني',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF202124),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 20,
                                  color: const Color(0xFF8B2BE2),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "الدوله",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? const Color(0xFF8E949F)
                                        : const Color(0xFF777B84),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  country,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF202124),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Icon(
                                  Icons.cake_rounded,
                                  size: 20,
                                  color: const Color(0xFFFF8F00),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'العمر',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? const Color(0xFF8E949F)
                                        : const Color(0xFF777B84),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  age,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF202124),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF292D35)
                                  : const Color(0xFFE9E9EF),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              'نبذة عني',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF8E949F)
                                    : const Color(0xFF777B84),
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              bio,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: isDark
                                    ? const Color(0xFFD5D8DE)
                                    : const Color(0xFF454851),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      _buildProfileTile(
                        context: context,
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBackground: isDark
                            ? const Color(0xFF302348)
                            : const Color(0xFFF0EAFF),
                        title: 'محفظة',
                        //subtitle: 'إدارة رصيدك وعملياتك',
                        onTap: () {},
                      ),

                      _buildProfileTile(
                        context: context,
                        icon: Icons.person_add_alt_1_rounded,
                        iconColor: const Color(0xFF00A878),
                        iconBackground: isDark
                            ? const Color(0xFF16372E)
                            : const Color(0xFFE5F8F2),
                        title: 'ادعو صديق',
                        onTap: inviteFriend,
                      ),

                      _buildProfileTile(
                        context: context,
                        icon: Icons.support_agent_rounded,
                        iconColor: const Color(0xFF25D366),
                        iconBackground: isDark
                            ? const Color(0xFF14382B)
                            : const Color(0xFFE8F9EE),
                        title: 'المساعدة والدعم',
                        onTap: () async {
                          final Uri whatsappUrl = Uri.parse("https://wa.me/9647857706451");

                          if (await canLaunchUrl(whatsappUrl)) {
                            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),

                      _buildProfileTile(
                        context: context,
                        icon: Icons.sticky_note_2_rounded,
                        iconColor: const Color(0xFFFFA000),
                        iconBackground: isDark
                            ? const Color(0xFF3A3018)
                            : const Color(0xFFFFF4DD),
                        title: 'ملاحظات',
                        //subtitle: 'ملاحظاتك عن التطبيق',
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>FeedbackPage()),
                          );
                        },
                      ),

                      _buildProfileTile(
                        context: context,
                        icon: Icons.settings_rounded,
                        iconColor: const Color(0xFF64748B),
                        iconBackground: isDark
                            ? const Color(0xFF252930)
                            : const Color(0xFFF0F2F5),
                        title: 'الإعدادات',
                        //subtitle: 'إدارة إعدادات الحساب والتطبيق',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Settings(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'SaYo Star',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF747A85)
                              : const Color(0xFFB0B6C1),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'تواصل • تعرّف • استمتع',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF696F7A)
                              : const Color(0xFFB8BDC7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        )
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryText = isDark
        ? const Color(0xFFF1F1F3)
        : const Color(0xFF16181D);

    final Color uidBackground = isDark ? const Color(0xFF181A1F) : Colors.white;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C9FF5), Color(0xFF5D7FE0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C8FEA).withValues(alpha: 0.25),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF242A38)
                      : const Color(0xFFE9F0FF),
                ),
                clipBehavior: Clip.antiAlias,
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: isDark
                      ? const Color(0xFF242A38)
                      : const Color(0xFFE9F0FF),
                  backgroundImage: avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : null,
                  child: avatar.isNotEmpty
                      ? ClipOval(
                          child: Image.memory(
                            base64Decode(avatar),
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: isDark ? const Color(0xFF9DA2AC) : Colors.grey,
                        ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          username,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: primaryText,
          ),
        ),

        const SizedBox(height: 7),

        GestureDetector(
          onTap: () async {
            if (uid.isEmpty) return;

            await Clipboard.setData(ClipboardData(text: uid));

            if (context.mounted) {
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
                        'تم نسخ الـ ID بنجاح',
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
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: uidBackground,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(color: const Color(0xFF292C34))
                  : null,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fingerprint_rounded,
                  size: 14,
                  color: Color(0xFF9AA1AD),
                ),
                const SizedBox(width: 6),
                Text(
                  user?.uid ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9AA1AD),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.copy_rounded,
                  size: 12,
                  color: Color(0xFF5D7FE0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A1F) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: const Color(0xFF292C34)) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(context, value: '0', label: 'المتابعون'),
          ),
          _buildDivider(context),
          Expanded(
            child: _buildStatItem(context, value: '0', label: 'متابع'),
          ),
          _buildDivider(context),
          Expanded(
            child: _buildStatItem(context, value: '0', label: 'الزوار'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: isDark ? const Color(0xFFF1F1F3) : const Color(0xFF171A21),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9AA1AD),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 1,
      height: 32,
      color: isDark ? const Color(0xFF30333B) : const Color(0xFFE9EBEF),
    );
  }

  Widget _buildProfileTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    //required String subtitle,
    required VoidCallback onTap,
    bool premium = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color tileColor = isDark ? const Color(0xFF181A1F) : Colors.white;

    final Color titleColor = isDark
        ? const Color(0xFFE5E6EA)
        : const Color(0xFF1B1D22);

    final Color arrowBackground = isDark
        ? const Color(0xFF24272E)
        : const Color(0xFFF6F7F9);

    final Color arrowColor = isDark
        ? const Color(0xFF858B96)
        : const Color(0xFF9DA3AC);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(19),
        border: isDark ? Border.all(color: const Color(0xFF292C34)) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ),

                          if (premium) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF3A3018)
                                    : const Color(0xFFFFF3C7),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB77A00),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 3),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: arrowBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: arrowColor,
                    size: 20,
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
