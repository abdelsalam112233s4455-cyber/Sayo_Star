import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '/home/me/sitting/sittingaccaunt.dart';
import '/theme.dart';
import '../../infouser/terms.dart';
import '/infouser/auth.dart';

final serverUrl =
    'https://exotic-singer-bathroom-disciplines.trycloudflare.com';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool islod = false;
  Future<void> showLogoutDialog() async {
    bool deleteAccountData = false;
    bool isDeleting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final bool isDark =
            Theme.of(dialogContext).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor:
              isDark ? const Color(0xFF181A1F) : Colors.white,
              surfaceTintColor: Colors.transparent,

              title: Text(
                'تسجيل الخروج',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFF1F1F3)
                      : const Color(0xFF171A21),
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'هل تريد تسجيل الخروج؟ أنت متأكد؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFB5BAC4)
                          : const Color(0xFF555A63),
                    ),
                  ),

                  const SizedBox(height: 16),

                  CheckboxListTile(
                    value: deleteAccountData,
                    onChanged: isDeleting
                        ? null
                        : (value) {
                      setDialogState(() {
                        deleteAccountData = value ?? false;
                      });
                    },
                    title: Text(
                      'هل تريد مسح بيانات الحساب كاملة؟',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFE5E6EA)
                            : const Color(0xFF34343A),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF9C27B0),
                  ),
                ],
              ),

              actionsAlignment: MainAxisAlignment.spaceEvenly,

              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'إغلاق',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9DA2AC)
                          : Colors.grey,
                    ),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    const Color(0xFF9C27B0).withValues(alpha: 0.6),
                    disabledForegroundColor: Colors.white,
                  ),

                  onPressed: isDeleting
                      ? null
                      : () async {
                    // تسجيل الخروج العادي
                    if (!deleteAccountData) {
                      setDialogState(() {
                        isDeleting = true;
                      });

                      try {
                        await FirebaseAuth.instance.signOut();

                        if (!mounted) return;

                        Navigator.pop(dialogContext);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Auth(),
                          ),
                              (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;

                        setDialogState(() {
                          isDeleting = false;
                        });

                        ScaffoldMessenger.of(this.context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'حدث خطأ أثناء تسجيل الخروج',
                            ),
                          ),
                        );
                      }

                      return;
                    }

                    // بداية حذف البيانات
                    setDialogState(() {
                      isDeleting = true;
                    });

                    try {
                      final User? user =
                          FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        throw Exception(
                          'لم يتم العثور على الحساب الحالي',
                        );
                      }

                      final String email = user.email ?? '';

                      if (email.isEmpty) {
                        throw Exception(
                          'لم يتم العثور على البريد الإلكتروني للحساب',
                        );
                      }

                      // حذف بيانات المستخدم من السيرفر أولًا
                      final response = await http.delete(
                        Uri.parse(
                          '$serverUrl/users/${Uri.encodeComponent(email)}',
                        ),
                        headers: {
                          "Accept": "application/json",
                        },
                      );

                      if (response.statusCode != 200) {
                        throw Exception(
                          'فشل حذف بيانات الحساب من السيرفر',
                        );
                      }

                      // بعد نجاح السيرفر نحذف حساب Firebase
                      await user.delete();

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Auth(),
                        ),
                            (route) => false,
                      );

                      ScaffoldMessenger.of(
                        this.context,
                      ).showSnackBar(
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
                                'تم حذف حسابك وتسجيل الخروج بنجاح',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor:
                          const Color(0xFF1E222B),
                          behavior:
                          SnackBarBehavior.floating,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          duration:
                          const Duration(seconds: 2),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;

                      setDialogState(() {
                        isDeleting = false;
                      });

                      if (e.code == 'requires-recent-login') {
                        ScaffoldMessenger.of(this.context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'لأسباب أمنية، يجب تسجيل الدخول مرة أخرى قبل حذف الحساب',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(this.context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'حدث خطأ أثناء حذف الحساب: ${e.message ?? e.code}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;

                      setDialogState(() {
                        isDeleting = false;
                      });

                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'حدث خطأ أثناء حذف البيانات: $e',
                          ),
                        ),
                      );
                    }
                  },

                  child: isDeleting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'موافق',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? const Color(0xFF101114)
        : const Color(0xFFF8F9FA);

    final Color titleColor = isDark
        ? const Color(0xFFF1F1F3)
        : const Color(0xFF171A21);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildSectionHeader('الحساب'),

          _buildSettingsTile(
            icon: Icons.edit_note,
            iconColor: const Color.fromARGB(255, 33, 150, 243),
            iconBackground: isDark
                ? const Color(0xFF17314A)
                : const Color.fromARGB(255, 224, 239, 250),
            title: 'تعديل الحساب',
            subtitle: 'تعديل الاسم، البريد، والصورة الشخصية',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Sittingaccaunt()),
              );
            },
          ),

          const SizedBox(height: 15),

          _buildSectionHeader('التفضيلات والتطبيق'),

          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            iconColor: const Color.fromARGB(255, 156, 39, 176),
            iconBackground: isDark
                ? const Color(0xFF32203A)
                : const Color.fromARGB(255, 243, 229, 245),
            title: 'الإشعارات',
            subtitle: 'التحكم في التنبيهات والأصوات',
            onTap: () {},
          ),

          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            iconColor: const Color.fromARGB(255, 103, 58, 183),
            iconBackground: isDark
                ? const Color(0xFF29213D)
                : const Color.fromARGB(255, 237, 231, 246),
            title: 'المظهر والوضع الداكن',
            subtitle: 'تغيير ثيم التطبيق (فاتح / داكن)',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ThemeSelectionDialog(),
              );
            },
          ),

          const SizedBox(height: 15),

          _buildSectionHeader('الدعم والخصوصية'),

          _buildSettingsTile(
            icon: Icons.description_outlined,
            iconColor: const Color.fromARGB(255, 255, 152, 0),
            iconBackground: isDark
                ? const Color(0xFF3A2C18)
                : const Color.fromARGB(255, 255, 243, 224),
            title: 'سياسات التطبيق',
            subtitle: 'سياسه البقاق لحمايتك وحمايه غيرك...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsAndConditions(),
                ),
              );
            },
          ),

          _buildSettingsTile(
            icon: Icons.logout_rounded,
            iconColor: const Color.fromARGB(255, 229, 57, 53),
            iconBackground: isDark
                ? const Color(0xFF3A2020)
                : const Color.fromARGB(255, 255, 235, 238),
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من الحساب الحالي',
            onTap: () {
              showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: isDark ? const Color(0xFFD0D2D7) : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
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
                  child: Icon(icon, color: iconColor, size: 22),
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

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9AA1AD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF181A1F) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.palette_rounded,
                color: Colors.blue,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'اختر مظهر التطبيق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFF1F1F3)
                    : const Color(0xFF171A21),
              ),
            ),

            const SizedBox(height: 20),

            _buildThemeOption(
              context: context,
              title: 'الوضع الفاتح',
              subtitle: 'ألوان واضحة ومريحة في النهار',
              icon: Icons.light_mode_rounded,
              iconColor: Colors.amber,
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 10),

            _buildThemeOption(
              context: context,
              title: 'الوضع الداكن',
              subtitle: 'ألوان مظلمة توفر البطارية والعين',
              icon: Icons.dark_mode_rounded,
              iconColor: Colors.indigoAccent,
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 10),

            _buildThemeOption(
              context: context,
              title: 'تلقائي (حسب النظام)',
              subtitle: 'يتغير تلقائياً مع إعدادات جهازك',
              icon: Icons.brightness_auto_rounded,
              iconColor: Colors.teal,
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color unselectedBackground = isDark
        ? const Color(0xFF22252B)
        : const Color(0xFFF3F4F6);

    final Color titleColor = isDark
        ? const Color(0xFFE5E6EA)
        : const Color(0xFF34343A);

    final Color subtitleColor = isDark
        ? const Color(0xFF9DA2AC)
        : Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.12)
              : unselectedBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Colors.blue : titleColor,
                    ),
                  ),

                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.blue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
