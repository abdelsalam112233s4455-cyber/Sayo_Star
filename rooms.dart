import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String serverUrl = 'https://judicial-seating-watch-clubs.trycloudflare.com';

const Color primaryColor = Color(0xFF8B2BE2);

const Color backgroundColor = Color(0xFFF7F8FA);

const Color textColor = Color(0xFF34343A);

// ================================================================
// ROOMS PAGE
// ================================================================

class Rooms extends StatefulWidget {
  const Rooms({super.key});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> {
  final TextEditingController searchController = TextEditingController();

  bool searching = false;

  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==============================================================
  // جلب جميع المستخدمين
  // ==============================================================

  Future<void> loadUsers() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/users'));

      debugPrint('👥 Users status: ${response.statusCode}');
      debugPrint('📦 Users response: ${response.body}');

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        users = data['users'] ?? [];
      });
    } catch (e) {
      debugPrint('❌ خطأ جلب المستخدمين: $e');
    }
  }

  // ==============================================================
  // البحث بالـ Firebase UID
  // ==============================================================

  Future<void> searchUser() async {
    final String id = searchController.text.trim();

    if (id.isEmpty) {
      loadUsers();
      return;
    }

    setState(() {
      searching = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/users/by-uid/${Uri.encodeComponent(id)}'),
      );

      debugPrint('🔎 Search status: ${response.statusCode}');
      debugPrint('📦 Search response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          users = [data];
        });
      } else {
        if (!mounted) return;

        setState(() {
          users = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على هذا المستخدم'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ خطأ البحث: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء البحث'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F1014)
            : const Color(0xFFF7F8FA),

        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: loadUsers,

                color: primaryColor,

                backgroundColor: isDark
                    ? const Color(0xFF202127)
                    : Colors.white,

                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: RoomsSearchBar(
                        controller: searchController,
                        searching: searching,
                        onSearch: searchUser,
                      ),
                    ),

                    const SliverToBoxAdapter(child: RoomsBanner()),

                    const SliverToBoxAdapter(child: RoomsHeader()),

                    SliverToBoxAdapter(child: UsersList(users: users)),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),

              Positioned(
                bottom: 20,
                left: 16,
                child: CreateRoomButton(
                  onPressed: () {
                    debugPrint('إنشاء غرفة');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SEARCH BAR
// ================================================================

class RoomsSearchBar extends StatelessWidget {
  final TextEditingController controller;

  final bool searching;

  final VoidCallback onSearch;

  const RoomsSearchBar({
    super.key,
    required this.controller,
    required this.searching,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color widgetColor = isDark ? const Color(0xFF1B1D23) : Colors.white;

    final Color borderColor = isDark
        ? const Color(0xFF2B2E36)
        : const Color(0xFFEDEEF2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: widgetColor,
                borderRadius: BorderRadius.circular(14),

                border: Border.all(color: borderColor),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.25 : 0.025,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                textDirection: TextDirection.ltr,

                style: TextStyle(
                  color: isDark ? Colors.white : textColor,
                  fontSize: 14,
                ),

                cursorColor: primaryColor,

                onSubmitted: (_) => onSearch(),

                decoration: InputDecoration(
                  hintText: 'بحث عن ID',

                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF777C87) : Colors.grey,
                    fontSize: 13,
                  ),

                  prefixIcon: searching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: onSearch,
                          icon: Icon(
                            Icons.search,
                            color: isDark
                                ? const Color(0xFF9DA2AD)
                                : Colors.grey,
                          ),
                        ),

                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.clear();

                            FocusScope.of(context).unfocus();

                            onSearch();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? const Color(0xFF9DA2AD)
                                : Colors.grey,
                            size: 20,
                          ),
                        )
                      : null,

                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          TrophyButton(
            onPressed: () {
              debugPrint('تم الضغط على زر الكأس');
            },
          ),
        ],
      ),
    );
  }
}

// ================================================================
// TROPHY
// ================================================================

class TrophyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TrophyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1B1D23) : Colors.white,

      borderRadius: BorderRadius.circular(14),

      child: InkWell(
        onTap: onPressed,

        borderRadius: BorderRadius.circular(14),

        child: Icon(Icons.emoji_events, color: Color(0xFFFFB800), size: 45),
      ),
    );
  }
}

// ================================================================
// BANNER
// ================================================================

class RoomsBanner extends StatelessWidget {
  const RoomsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 113,

      margin: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF401078), Color(0xFF7027A8)],
        ),

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF401078).withValues(alpha: 0.18),

            blurRadius: 18,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: const Center(
        child: Text(
          'مكان صورة البانر',

          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

// ================================================================
// ROOMS HEADER
// ================================================================

class RoomsHeader extends StatelessWidget {
  const RoomsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),

      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: primaryColor, size: 22),

          const SizedBox(width: 8),

          Text(
            'الكل',

            style: TextStyle(
              color: isDark ? Colors.white : textColor,

              fontSize: 17,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// USERS LIST
// ================================================================

class UsersList extends StatelessWidget {
  final List<dynamic> users;

  const UsersList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (users.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),

        padding: const EdgeInsets.symmetric(vertical: 45),

        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF191B20) : Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: isDark ? const Color(0xFF292C34) : Colors.transparent,
          ),
        ),

        child: Column(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 45,

              color: isDark ? const Color(0xFF6F7480) : const Color(0xFFB7BBC2),
            ),

            const SizedBox(height: 10),

            Text(
              'لا يوجد مستخدمون',

              style: TextStyle(
                color: isDark
                    ? const Color(0xFF969BA6)
                    : const Color(0xFF8C9199),

                fontSize: 14,

                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.symmetric(horizontal: 14),

      itemCount: users.length,

      itemBuilder: (context, index) {
        final Map<String, dynamic> user = Map<String, dynamic>.from(
          users[index],
        );

        return UserCard(user: user);
      },
    );
  }
}

// ================================================================
// USER CARD
// ================================================================

class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserCard({super.key, required this.user});

  String get username => user['username']?.toString().trim().isNotEmpty == true
      ? user['username'].toString()
      : 'مستخدم';

  String get avatar => user['avatar']?.toString() ?? '';

  String get country => user['country']?.toString() ?? '';

  String get age => user['age']?.toString() ?? '';

  String get gender => user['gender']?.toString() ?? '';

  String get bio => user['bio']?.toString() ?? '';

  String get email => user['email']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = isDark ? const Color(0xFF191B20) : Colors.white;

    final Color mainText = isDark ? const Color(0xFFF2F3F5) : textColor;

    final Color secondaryText = isDark
        ? const Color(0xFF969BA6)
        : const Color(0xFF858B94);

    final Color borderColor = isDark
        ? const Color(0xFF292C34)
        : const Color(0xFFEDEEF2);

    return Container(
      height: 112,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: borderColor),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.025),

            blurRadius: 12,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // ------------------------------------------------------
          // الصورة
          // ------------------------------------------------------
          UserAvatar(avatar: avatar, size: 78),

          const SizedBox(width: 12),

          // ------------------------------------------------------
          // المعلومات
          // ------------------------------------------------------
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 15,

                          fontWeight: FontWeight.w800,

                          color: mainText,
                        ),
                      ),
                    ),

                    if (gender.isNotEmpty) ...[
                      const SizedBox(width: 6),

                      GenderBadge(gender: gender),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    if (age.isNotEmpty)
                      _SmallInfo(icon: Icons.cake_outlined, text: age),

                    if (age.isNotEmpty && country.isNotEmpty)
                      const SizedBox(width: 10),

                    if (country.isNotEmpty)
                      Flexible(
                        child: _SmallInfo(
                          icon: Icons.location_on_outlined,
                          text: country,
                        ),
                      ),
                  ],
                ),

                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 5),

                  Text(
                    bio,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(fontSize: 11, color: secondaryText),
                  ),
                ],

                if (email.isNotEmpty) ...[
                  const SizedBox(height: 3),

                  Text(
                    email,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 9,

                      color: isDark
                          ? const Color(0xFF686D77)
                          : const Color(0xFFB0B4BA),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 5),

          Icon(
            Icons.chevron_left_rounded,

            color: isDark ? const Color(0xFF737884) : const Color(0xFFB5BAC2),

            size: 23,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// USER AVATAR
// ================================================================

class UserAvatar extends StatelessWidget {
  final String avatar;

  final double size;

  const UserAvatar({super.key, required this.avatar, required this.size});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,

      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: isDark
              ? const [Color(0xFF303542), Color(0xFF352842)]
              : const [Color(0xFFE5E9FF), Color(0xFFF4E9FF)],
        ),
      ),

      padding: const EdgeInsets.all(2),

      child: ClipOval(child: _buildImage(isDark)),
    );
  }

  Widget _buildImage(bool isDark) {
    if (avatar.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF252830) : const Color(0xFFF0F2F7),

        child: Icon(
          Icons.person_rounded,

          color: isDark ? const Color(0xFF8D94A2) : const Color(0xFF8991A0),

          size: 37,
        ),
      );
    }

    try {
      String image = avatar.trim();

      // لو Base64 بالشكل:
      // data:image/jpeg;base64,XXXXX

      if (image.contains(',')) {
        image = image.split(',').last;
      }

      final Uint8List bytes = base64Decode(image);

      return Image.memory(
        bytes,

        fit: BoxFit.cover,

        errorBuilder: (context, error, stackTrace) {
          return _defaultAvatar(isDark);
        },
      );
    } catch (e) {
      debugPrint('❌ Avatar decode error: $e');

      return _defaultAvatar(isDark);
    }
  }

  Widget _defaultAvatar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF252830) : const Color(0xFFF0F2F7),

      child: Icon(
        Icons.person_rounded,

        color: isDark ? const Color(0xFF8D94A2) : const Color(0xFF8991A0),

        size: 37,
      ),
    );
  }
}

// ================================================================
// GENDER BADGE
// ================================================================

class GenderBadge extends StatelessWidget {
  final String gender;

  const GenderBadge({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final bool male = gender.toLowerCase() == 'male' || gender == 'ذكر';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

      decoration: BoxDecoration(
        color: male ? const Color(0xFFE9F1FF) : const Color(0xFFFFEAF4),

        borderRadius: BorderRadius.circular(8),
      ),

      child: Icon(
        male ? Icons.male_rounded : Icons.female_rounded,

        size: 13,

        color: male ? const Color(0xFF5686E8) : const Color(0xFFE56B9A),
      ),
    );
  }
}

// ================================================================
// SMALL INFO
// ================================================================

class _SmallInfo extends StatelessWidget {
  final IconData icon;

  final String text;

  const _SmallInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        Icon(
          icon,

          size: 13,

          color: isDark ? const Color(0xFF8B919C) : const Color(0xFF9CA2AB),
        ),

        const SizedBox(width: 3),

        Flexible(
          child: Text(
            text,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 10,

              color: isDark ? const Color(0xFF9A9FAA) : const Color(0xFF858B94),

              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// CREATE ROOM BUTTON
// ================================================================

class CreateRoomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateRoomButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,

      icon: const Icon(Icons.add, color: Colors.white),

      label: const Text(
        'إنشاء غرفة',

        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,

        foregroundColor: Colors.white,

        elevation: 5,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
