import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'chat/chat1.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _idSearchController =
  TextEditingController();

  final String serverUrl =
      'https://test-celtic-libs-listen.trycloudflare.com';

  late final String baseUrl = '$serverUrl/api/users';

  List<Map<String, String>> usersList = [];

  bool isLoading = true;
  bool _isSearching = false;
  bool _isFetchingUsers = false;
  bool _isInitializing = true;

  String myCurrentUserId = '';

  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        _showError('يجب تسجيل الدخول أولاً');
        return;
      }

      final uid = firebaseUser.uid;
      final email = firebaseUser.email;

      Map<String, dynamic>? mongoUser;

      // البحث باستخدام Firebase UID للحصول على MongoDB _id.
      try {
        final response = await http
            .get(
          Uri.parse(
            '$baseUrl/${Uri.encodeComponent(uid)}',
          ),
        )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            mongoUser = Map<String, dynamic>.from(decoded);
          }
        }
      } catch (e) {
        debugPrint('UID lookup error: $e');
      }

      // استخدام البريد الإلكتروني كخيار احتياطي.
      if ((mongoUser == null ||
          (mongoUser['_id']?.toString().isEmpty ?? true)) &&
          email != null &&
          email.isNotEmpty) {
        try {
          final response = await http
              .get(
            Uri.parse(
              '$serverUrl/users/check/${Uri.encodeComponent(email)}',
            ),
          )
              .timeout(const Duration(seconds: 12));

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            if (decoded is Map) {
              mongoUser = Map<String, dynamic>.from(decoded);
            }
          }
        } catch (e) {
          debugPrint('Email lookup error: $e');
        }
      }

      final mongoId = mongoUser?['_id']?.toString() ?? '';

      if (mongoId.isEmpty) {
        _showError(
          'لم يتم العثور على حسابك في قاعدة البيانات. '
              'تأكد من تسجيل بيانات المستخدم في MongoDB.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        myCurrentUserId = mongoId;
      });

      initSocket();
      await fetchAllUsers();
    } catch (e) {
      debugPrint('Chat initialization error: $e');
      _showError('حدث خطأ أثناء تهيئة الدردشة');
    } finally {
      _isInitializing = false;
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    debugPrint('Chat error: $message');

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  void initSocket() {
    if (myCurrentUserId.isEmpty) return;

    try {
      socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .build(),
      );

      socket!.onConnect((_) {
        debugPrint('Chat list connected: ${socket!.id}');
        socket!.emit('join', myCurrentUserId);
      });

      socket!.on('new_message', (dynamic data) {
        if (data is! Map) return;

        final message = Map<String, dynamic>.from(data);

        final senderId = message['senderId']?.toString() ?? '';
        final receiverId = message['receiverId']?.toString() ?? '';

        final belongsToCurrentUser =
            senderId == myCurrentUserId ||
                receiverId == myCurrentUserId;

        if (!belongsToCurrentUser || !mounted) return;

        if (!_isSearching) {
          fetchAllUsers(showLoading: false);
        }
      });

      socket!.onConnectError((error) {
        debugPrint('Chat list socket connection error: $error');
      });

      socket!.onError((error) {
        debugPrint('Chat list socket error: $error');
      });

      socket!.on('chat_error', (dynamic data) {
        debugPrint('Chat list error: $data');
      });

      socket!.connect();
    } catch (e) {
      debugPrint('Socket initialization error: $e');
    }
  }

  Future<void> fetchAllUsers({bool showLoading = true}) async {
    if (!mounted ||
        _isFetchingUsers ||
        myCurrentUserId.isEmpty) {
      return;
    }

    _isFetchingUsers = true;

    if (showLoading) {
      setState(() => isLoading = true);
    }

    try {
      final url = Uri.parse(
        '$baseUrl?currentUserId='
            '${Uri.encodeQueryComponent(myCurrentUserId)}',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! List) {
          throw const FormatException(
            'استجابة المستخدمين ليست قائمة صحيحة',
          );
        }

        final List<Map<String, String>> fetchedUsers = [];

        for (final item in decoded) {
          if (item is! Map) continue;

          final user = Map<String, dynamic>.from(item);
          final userId = user['_id']?.toString() ?? '';

          if (userId.isEmpty || userId == myCurrentUserId) {
            continue;
          }

          final username =
              user['username']?.toString().trim() ?? '';
          final avatar =
              user['avatarUrl']?.toString().trim() ?? '';
          final lastMessageText =
              user['lastMessageText']?.toString().trim() ?? '';
          final bio = user['bio']?.toString().trim() ?? '';

          fetchedUsers.add({
            'userId': userId,
            'userName':
            username.isNotEmpty ? username : 'بدون اسم',
            'userImage': avatar,
            'lastMessage': lastMessageText.isNotEmpty
                ? lastMessageText
                : (bio.isNotEmpty ? bio : 'مستخدم في التطبيق'),
            'lastMessageTime':
            user['lastMessageTime']?.toString() ?? '',
          });
        }

        fetchedUsers.sort((a, b) {
          final dateA = DateTime.tryParse(
            a['lastMessageTime'] ?? '',
          ) ??
              DateTime.fromMillisecondsSinceEpoch(0);

          final dateB = DateTime.tryParse(
            b['lastMessageTime'] ?? '',
          ) ??
              DateTime.fromMillisecondsSinceEpoch(0);

          return dateB.compareTo(dateA);
        });

        if (mounted) {
          setState(() {
            usersList = fetchedUsers;
          });
        }
      } else {
        debugPrint(
          'Fetch users failed: '
              '${response.statusCode} ${response.body}',
        );

        if (mounted && showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر تحميل المستخدمين'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Fetch users error: $e');

      if (mounted && showLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء الاتصال بالسيرفر'),
          ),
        );
      }
    } finally {
      _isFetchingUsers = false;

      if (mounted && showLoading) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> searchUserById(String searchId) async {
    final id = searchId.trim();

    if (id.isEmpty) {
      _isSearching = false;
      await fetchAllUsers();
      return;
    }

    if (!mounted || myCurrentUserId.isEmpty) return;

    _isSearching = true;
    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
        '$baseUrl/${Uri.encodeComponent(id)}',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! Map) {
          throw const FormatException(
            'استجابة البحث غير صحيحة',
          );
        }

        final user = Map<String, dynamic>.from(decoded);
        final userId = user['_id']?.toString() ?? '';
        final username =
            user['username']?.toString().trim() ?? '';
        final avatar =
            user['avatarUrl']?.toString().trim() ?? '';
        final bio = user['bio']?.toString().trim() ?? '';

        if (mounted) {
          setState(() {
            if (userId.isEmpty || userId == myCurrentUserId) {
              usersList = [];
            } else {
              usersList = [
                {
                  'userId': userId,
                  'userName':
                  username.isNotEmpty ? username : 'بدون اسم',
                  'userImage': avatar,
                  'lastMessage': bio.isNotEmpty
                      ? bio
                      : 'تم العثور على المستخدم',
                  'lastMessageTime': '',
                },
              ];
            }
          });
        }
      } else {
        debugPrint(
          'Search failed: ${response.statusCode} ${response.body}',
        );

        if (mounted) {
          setState(() => usersList = []);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم العثور على المستخدم'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Search user error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء البحث'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildUserAvatar(String? imageUrl, String userName) {
    final url = imageUrl?.trim() ?? '';
    final validUrl =
        url.startsWith('https://') || url.startsWith('http://');

    if (validUrl) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF00A878),
        child: ClipOval(
          child: Image.network(
            url,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon(userName);
            },
          ),
        ),
      );
    }

    return _buildFallbackIcon(userName);
  }

  Widget _buildFallbackIcon(String userName) {
    final name = userName.trim();

    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color(0xFF00A878),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '👤',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserTile(
      Map<String, String> user,
      bool isDark,
      ) {
    return Card(
      elevation: 0,
      color: isDark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF8F9FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: _buildUserAvatar(
          user['userImage'],
          user['userName'] ?? '',
        ),
        title: Text(
          user['userName'] ?? 'بدون اسم',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          user['lastMessage'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        trailing: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: Color(0xFF00A878),
        ),
        onTap: () async {
          if (myCurrentUserId.isEmpty) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat1(
                userId: user['userId']!,
                userName: user['userName']!,
                userImage: user['userImage']!,
                currentUserId: myCurrentUserId,
              ),
            ),
          );

          if (mounted && !_isSearching) {
            await fetchAllUsers();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    socket?.off('new_message');
    socket?.off('chat_error');
    socket?.disconnect();
    socket?.dispose();

    _idSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'المستخدمين والرسائل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              onPressed: isLoading || _isInitializing
                  ? null
                  : () {
                _isSearching = false;
                _idSearchController.clear();
                fetchAllUsers();
              },
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث المستخدمين',
            ),
          ],
        ),
        body: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idSearchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: searchUserById,
                      onChanged: (value) {
                        if (value.trim().isEmpty &&
                            _isSearching) {
                          _isSearching = false;
                          fetchAllUsers();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث باستخدام MongoDB ID...',
                        prefixIcon:
                        const Icon(Icons.badge_outlined),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0F2F5),
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A878),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : () => searchUserById(
                        _idSearchController.text,
                      ),
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : usersList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 48,
                      color: isDark
                          ? Colors.white30
                          : Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لم يتم العثور على أي مستخدم',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : Colors.black45,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        _isSearching = false;
                        _idSearchController.clear();
                        fetchAllUsers();
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        'إعادة المحاولة',
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: () async {
                  if (_isSearching) {
                    await searchUserById(
                      _idSearchController.text,
                    );
                  } else {
                    await fetchAllUsers();
                  }
                },
                child: ListView.separated(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: usersList.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildUserTile(
                      usersList[index],
                      isDark,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}