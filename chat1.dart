import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Chat1 extends StatefulWidget {
  final String userId;
  final String userName;
  final String userImage;
  final String currentUserId;

  const Chat1({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.currentUserId,
  });

  @override
  State<Chat1> createState() => _Chat1State();
}

class _Chat1State extends State<Chat1> {
  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final String serverUrl =
      'https://test-celtic-libs-listen.trycloudflare.com';

  IO.Socket? socket;

  final List<Map<String, dynamic>> messages = [];

  bool isLoading = true;
  bool isSending = false;
  bool isSocketReady = false;

  String get myCurrentUserId => widget.currentUserId.trim();

  String get receiverId => widget.userId.trim();

  @override
  void initState() {
    super.initState();
    fetchMessages();
    initSocket();
  }

  // ========================================
  // Load conversation history
  // ========================================

  Future<void> fetchMessages() async {
    if (myCurrentUserId.isEmpty || receiverId.isEmpty) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final url = Uri.parse(
        '$serverUrl/api/messages/'
            '${Uri.encodeComponent(myCurrentUserId)}/'
            '${Uri.encodeComponent(receiverId)}',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint(
          'Fetch messages failed: '
              '${response.statusCode} ${response.body}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر تحميل الرسائل'),
            ),
          );
        }

        return;
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException(
          'استجابة الرسائل غير صحيحة',
        );
      }

      final loadedMessages = <Map<String, dynamic>>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        final message = Map<String, dynamic>.from(item);

        final senderId =
            message['senderId']?.toString() ?? '';
        final messageReceiverId =
            message['receiverId']?.toString() ?? '';
        final text =
            message['messageText']?.toString() ?? '';

        if (senderId.isEmpty ||
            messageReceiverId.isEmpty ||
            text.isEmpty) {
          continue;
        }

        loadedMessages.add({
          '_id': message['_id']?.toString() ?? '',
          'senderId': senderId,
          'receiverId': messageReceiverId,
          'messageText': text,
          'createdAt': message['createdAt']?.toString() ??
              DateTime.now().toIso8601String(),
        });
      }

      loadedMessages.sort((a, b) {
        final dateA = DateTime.tryParse(
          a['createdAt']?.toString() ?? '',
        ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final dateB = DateTime.tryParse(
          b['createdAt']?.toString() ?? '',
        ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return dateA.compareTo(dateB);
      });

      if (!mounted) return;

      setState(() {
        messages
          ..clear()
          ..addAll(loadedMessages);
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Fetch messages error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تحميل المحادثة'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ========================================
  // Socket.IO
  // ========================================

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
        debugPrint('Chat1 socket connected: ${socket!.id}');

        isSocketReady = false;

        socket!.emitWithAck(
          'join',
          myCurrentUserId,
          ack: (dynamic response) {
            _handleJoinResponse(response);
          },
        );
      });

      socket!.on('joined', (dynamic response) {
        _handleJoinResponse(response);
      });

      socket!.on('receive_message', (dynamic data) {
        _handleIncomingMessage(data);
      });

      socket!.on('chat_error', (dynamic data) {
        debugPrint('Chat1 socket error: $data');

        if (!mounted || data is! Map) return;

        final message =
            data['message']?.toString() ?? 'حدث خطأ في الدردشة';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });

      socket!.onConnectError((error) {
        debugPrint('Chat1 connection error: $error');
        isSocketReady = false;
      });

      socket!.onDisconnect((_) {
        debugPrint('Chat1 socket disconnected');
        isSocketReady = false;
      });

      socket!.onError((error) {
        debugPrint('Chat1 socket error: $error');
      });

      socket!.connect();
    } catch (e) {
      debugPrint('Chat1 socket initialization error: $e');
    }
  }

  void _handleJoinResponse(dynamic response) {
    if (response is! Map) return;

    final success = response['success'] == true;

    if (!mounted) {
      isSocketReady = success;
      return;
    }

    setState(() {
      isSocketReady = success;
    });

    if (!success) {
      debugPrint('Socket join rejected: $response');
    } else {
      debugPrint('Socket join successful: $myCurrentUserId');
    }
  }

  void _handleIncomingMessage(dynamic data) {
    if (data is! Map) return;

    final message = Map<String, dynamic>.from(data);

    final senderId = message['senderId']?.toString() ?? '';
    final messageReceiverId =
        message['receiverId']?.toString() ?? '';
    final text = message['messageText']?.toString() ?? '';

    if (senderId.isEmpty ||
        messageReceiverId.isEmpty ||
        text.isEmpty) {
      return;
    }

    final belongsToThisConversation =
        (senderId == myCurrentUserId &&
            messageReceiverId == receiverId) ||
            (senderId == receiverId &&
                messageReceiverId == myCurrentUserId);

    if (!belongsToThisConversation) return;

    final messageId = message['_id']?.toString() ?? '';

    if (messageId.isNotEmpty &&
        messages.any((item) => item['_id'] == messageId)) {
      return;
    }

    final isDuplicate = messages.any((item) {
      return item['senderId']?.toString() == senderId &&
          item['receiverId']?.toString() == messageReceiverId &&
          item['messageText']?.toString() == text &&
          item['_id']?.toString().startsWith('temp_') != true &&
          _isNearlySameTime(
            item['createdAt']?.toString(),
            message['createdAt']?.toString(),
          );
    });

    if (isDuplicate) return;

    if (!mounted) return;

    setState(() {
      messages.add({
        '_id': messageId,
        'senderId': senderId,
        'receiverId': messageReceiverId,
        'messageText': text,
        'createdAt': message['createdAt']?.toString() ??
            DateTime.now().toIso8601String(),
      });

      messages.sort((a, b) {
        final dateA = DateTime.tryParse(
          a['createdAt']?.toString() ?? '',
        ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final dateB = DateTime.tryParse(
          b['createdAt']?.toString() ?? '',
        ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return dateA.compareTo(dateB);
      });
    });

    _scrollToBottom();
  }

  bool _isNearlySameTime(String? first, String? second) {
    if (first == null || second == null) return false;

    final firstDate = DateTime.tryParse(first);
    final secondDate = DateTime.tryParse(second);

    if (firstDate == null || secondDate == null) return false;

    return firstDate.difference(secondDate).inSeconds.abs() <= 3;
  }

  // ========================================
  // Send message
  // ========================================

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || isSending) return;

    if (myCurrentUserId.isEmpty || receiverId.isEmpty) {
      _showMessageError('معرف المستخدم غير صحيح');
      return;
    }

    if (socket == null || !socket!.connected || !isSocketReady) {
      _showMessageError(
        'جارٍ الاتصال بالدردشة، حاول مرة أخرى بعد لحظة',
      );

      if (socket != null && !socket!.connected) {
        socket!.connect();
      }

      return;
    }

    setState(() {
      isSending = true;
    });

    _messageController.clear();

    final temporaryId =
        'temp_${DateTime.now().microsecondsSinceEpoch}';

    final temporaryMessage = <String, dynamic>{
      '_id': temporaryId,
      'senderId': myCurrentUserId,
      'receiverId': receiverId,
      'messageText': text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(temporaryMessage);
    });

    _scrollToBottom();

    try {
      final completer = Completer<dynamic>();

      socket!.emitWithAck(
        'send_message',
        {
          'receiverId': receiverId,
          'messageText': text,
        },
        ack: (dynamic response) {
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        },
      );

      final dynamic response = await completer.future.timeout(
        const Duration(seconds: 20),
      );

      if (response is! Map || response['success'] != true) {
        if (mounted) {
          setState(() {
            messages.removeWhere(
                  (message) => message['_id'] == temporaryId,
            );
          });
        }

        final errorMessage = response is Map
            ? response['message']?.toString() ??
            'تعذر إرسال الرسالة'
            : 'استجابة السيرفر غير صحيحة';

        _showMessageError(errorMessage);
        return;
      }

      final dynamic returnedMessage = response['message'];

      if (returnedMessage is Map) {
        final savedMessage =
        Map<String, dynamic>.from(returnedMessage);

        if (mounted) {
          setState(() {
            final index = messages.indexWhere(
                  (message) => message['_id'] == temporaryId,
            );

            final replacement = <String, dynamic>{
              '_id': savedMessage['_id']?.toString() ?? '',
              'senderId':
              savedMessage['senderId']?.toString() ??
                  myCurrentUserId,
              'receiverId':
              savedMessage['receiverId']?.toString() ??
                  receiverId,
              'messageText':
              savedMessage['messageText']?.toString() ?? text,
              'createdAt':
              savedMessage['createdAt']?.toString() ??
                  DateTime.now().toIso8601String(),
            };

            if (index != -1) {
              messages[index] = replacement;
            } else if (!messages.any(
                  (message) =>
              message['_id'] == replacement['_id'] &&
                  replacement['_id'] != '',
            )) {
              messages.add(replacement);
            }

            messages.sort((a, b) {
              final dateA = DateTime.tryParse(
                a['createdAt']?.toString() ?? '',
              ) ??
                  DateTime.fromMillisecondsSinceEpoch(0);

              final dateB = DateTime.tryParse(
                b['createdAt']?.toString() ?? '',
              ) ??
                  DateTime.fromMillisecondsSinceEpoch(0);

              return dateA.compareTo(dateB);
            });
          });
        }

        _scrollToBottom();
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          messages.removeWhere(
                (message) => message['_id'] == temporaryId,
          );
        });
      }

      _showMessageError('انتهت مهلة إرسال الرسالة');
    } catch (e) {
      debugPrint('Send message error: $e');

      if (mounted) {
        setState(() {
          messages.removeWhere(
                (message) => message['_id'] == temporaryId,
          );
        });
      }

      _showMessageError('حدث خطأ أثناء إرسال الرسالة');
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  void _showMessageError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ========================================
  // Scroll
  // ========================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ========================================
  // Avatar
  // ========================================

  Widget _buildAvatar({double radius = 22}) {
    final url = widget.userImage.trim();

    if (url.startsWith('https://') ||
        url.startsWith('http://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF00A878),
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF00A878),
      child: Text(
        widget.userName.trim().isNotEmpty
            ? widget.userName.trim()[0].toUpperCase()
            : '👤',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ========================================
  // Message bubble
  // ========================================

  Widget _buildMessageBubble(
      Map<String, dynamic> message,
      bool isDark,
      ) {
    final senderId = message['senderId']?.toString() ?? '';
    final isMine = senderId == myCurrentUserId;

    final text = message['messageText']?.toString() ?? '';
    final dateString = message['createdAt']?.toString() ?? '';

    final date = DateTime.tryParse(dateString);
    final time = date == null
        ? ''
        : '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    final isTemporary =
        message['_id']?.toString().startsWith('temp_') ?? false;

    final bubbleColor = isMine
        ? const Color(0xFFDCF8C6)
        : (isDark ? const Color(0xFF292929) : Colors.white);

    final textColor = isMine
        ? const Color(0xFF17251A)
        : (isDark ? Colors.white : Colors.black87);

    return Align(
      alignment:
      isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 10,
        ),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 6),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMine
                        ? Colors.black54
                        : (isDark ? Colors.white54 : Colors.black45),
                    fontSize: 10,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isTemporary ? Icons.access_time : Icons.done_all,
                    size: 14,
                    color: isTemporary
                        ? Colors.black45
                        : const Color(0xFF388E3C),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // Build
  // ========================================

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        isDark ? const Color(0xFF101114) : const Color(0xFFF2F4F5),
        appBar: AppBar(
          elevation: 1,
          titleSpacing: 0,
          title: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isSocketReady ? 'متصل بالدردشة' : 'الدردشة',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSocketReady
                            ? Colors.green
                            : (isDark
                            ? Colors.white60
                            : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : messages.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 58,
                      color: isDark
                          ? Colors.white30
                          : Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ابدأ المحادثة بإرسال رسالة',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(
                    messages[index],
                    isDark,
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF191A1E)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization:
                        TextCapitalization.sentences,
                        onSubmitted: (_) => sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF292A2F)
                              : const Color(0xFFF2F4F5),
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: const Color(0xFF00A878),
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: isSending ? null : sendMessage,
                        borderRadius: BorderRadius.circular(50),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: isSending
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket?.off('receive_message');
    socket?.off('joined');
    socket?.off('chat_error');
    socket?.disconnect();
    socket?.dispose();

    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}