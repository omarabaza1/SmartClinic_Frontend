import 'package:flutter/material.dart';

import '../services/messages_chat_store.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    this.isDoctor = false,
    this.registerOverlayTabBadge = false,
  });

  /// When true, logged-in user is a doctor (list = patients). When false, patient (doctors / pharmacy).
  final bool isDoctor;

  /// When this screen is opened via [Navigator.push] (not the bottom tab), set true so the
  /// Messages tab red dot hides while this route is visible.
  final bool registerOverlayTabBadge;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    MessagesChatStore.ensureSeeded(widget.isDoctor);
    if (widget.registerOverlayTabBadge) {
      MessagesChatStore.registerOverlayMessagesScreenOpened();
    }
  }

  @override
  void dispose() {
    if (widget.registerOverlayTabBadge) {
      MessagesChatStore.registerOverlayMessagesScreenClosed();
    }
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Full list from store; filtering applied in build only.
  List<ConversationThread> _filteredThreads(
    List<ConversationThread> fullConversations,
  ) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return fullConversations;
    return fullConversations.where((t) {
      final name = t.contactName.toLowerCase();
      final preview = t.lastPreviewText.toLowerCase();
      return name.contains(q) || preview.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF111118);
    const grayText = Color(0xFF636388);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: textColor),
            tooltip: 'Search',
            onPressed: () => _searchFocus.requestFocus(),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: MessagesChatStore.version,
        builder: (context, _, __) {
          final fullConversations =
              MessagesChatStore.orderedThreads(widget.isDoctor);
          final filteredConversations =
              _filteredThreads(fullConversations);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon:
                        const Icon(Icons.search, color: grayText, size: 22),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            color: grayText,
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredConversations.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No conversations found',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: grayText,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: filteredConversations.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final t = filteredConversations[index];
                          final hasUnread = t.unreadCount > 0;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => ChatScreen(
                                      threadId: t.id,
                                      isDoctor: widget.isDoctor,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Hero(
                                        tag: 'msg_avatar_${t.id}',
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              const Color(0xFFF1F5F9),
                                          backgroundImage: t.useNetworkAvatar &&
                                                  (t.avatarUrl != null &&
                                                      t.avatarUrl!.isNotEmpty)
                                              ? NetworkImage(t.avatarUrl!)
                                              : null,
                                          child: !t.useNetworkAvatar ||
                                                  t.avatarUrl == null ||
                                                  t.avatarUrl!.isEmpty
                                              ? const Icon(
                                                  Icons.person,
                                                  color: Color(0xFF94A3B8),
                                                  size: 30,
                                                )
                                              : null,
                                        ),
                                      ),
                                      if (hasUnread)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E88E5),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                t.contactName,
                                                style: TextStyle(
                                                  fontWeight: hasUnread
                                                      ? FontWeight.w800
                                                      : FontWeight.bold,
                                                  fontSize: 16,
                                                  color: textColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              t.lastTimeDisplay,
                                              style: const TextStyle(
                                                color: grayText,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t.lastPreviewText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: grayText,
                                            fontSize: 14,
                                            fontWeight: hasUnread
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
