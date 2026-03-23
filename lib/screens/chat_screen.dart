import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/messages_chat_store.dart';

/// WhatsApp-style chat; all data from [MessagesChatStore].
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.threadId,
    required this.isDoctor,
  });

  final String threadId;
  final bool isDoctor;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  static const _textColor = Color(0xFF111118);
  /// Received (left) bubbles.
  static const _bubbleReceivedBg = Colors.white;
  /// Sent (right) bubbles — light baby blue.
  static const _bubbleSentBg = Color(0xFFE3F2FD);
  static const _headerBlue = Color(0xFF2D9CDB);
  static const _primary = Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    MessagesChatStore.version.addListener(_onStore);
    MessagesChatStore.markThreadRead(widget.threadId, widget.isDoctor);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    MessagesChatStore.version.removeListener(_onStore);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  String _timeLabel(DateTime t) {
    return DateFormat.jm().format(t);
  }

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    MessagesChatStore.sendMessage(widget.threadId, text, widget.isDoctor);
    _input.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final thread = MessagesChatStore.thread(widget.threadId, widget.isDoctor);
    if (thread == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _headerBlue,
          foregroundColor: Colors.white,
          title: const Text('Chat'),
        ),
        body: const Center(child: Text('Conversation not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: _headerBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: thread.useNetworkAvatar &&
                      (thread.avatarUrl != null && thread.avatarUrl!.isNotEmpty)
                  ? NetworkImage(thread.avatarUrl!)
                  : null,
              child: !thread.useNetworkAvatar ||
                      thread.avatarUrl == null ||
                      thread.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 22)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                thread.contactName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: thread.messages.length,
              itemBuilder: (context, index) {
                final m = thread.messages[index];
                final sent = m.isSentByMe;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment:
                        sent ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color:
                              sent ? _bubbleSentBg : _bubbleReceivedBg,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(sent ? 12 : 2),
                            bottomRight: Radius.circular(sent ? 2 : 12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  m.text,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.35,
                                    color: _textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _timeLabel(m.at),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Material(
            color: const Color(0xFFF0F0F0),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: _primary,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
