import 'package:flutter/foundation.dart';

/// Single chat line (frontend-only).
@immutable
class ChatBubble {
  const ChatBubble({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.at,
  });

  final String id;
  final String text;
  final bool isSentByMe;
  final DateTime at;
}

/// One row in Messages list + its conversation history.
class ConversationThread {
  ConversationThread({
    required this.id,
    required this.contactName,
    this.avatarUrl,
    this.useNetworkAvatar = false,
    required List<ChatBubble> initialMessages,
    required this.lastTimeDisplay,
    this.unreadCount = 0,
  }) : messages = List<ChatBubble>.from(initialMessages) {
    _syncPreviewFromMessages();
  }

  final String id;
  final String contactName;
  final String? avatarUrl;
  /// If false, UI shows [Icons.person] like current Messages screen.
  final bool useNetworkAvatar;

  final List<ChatBubble> messages;
  late String lastPreviewText;
  String lastTimeDisplay;
  int unreadCount;

  void _syncPreviewFromMessages() {
    if (messages.isEmpty) {
      lastPreviewText = '';
      return;
    }
    lastPreviewText = messages.last.text;
  }

  void appendOutgoing(String text) {
    final now = DateTime.now();
    messages.add(ChatBubble(
      id: 'local-${now.millisecondsSinceEpoch}',
      text: text,
      isSentByMe: true,
      at: now,
    ));
    lastPreviewText = text;
    lastTimeDisplay = 'Just now';
  }

  void markRead() {
    unreadCount = 0;
  }
}

/// In-memory chats for patient vs doctor roles. No API.
class MessagesChatStore {
  MessagesChatStore._();

  static final ValueNotifier<int> version = ValueNotifier(0);

  static final Map<String, ConversationThread> _patientThreads = {};
  static final Map<String, ConversationThread> _doctorThreads = {};

  static bool _patientSeeded = false;
  static bool _doctorSeeded = false;

  /// Pushed [MessagesScreen] routes (not the tab); hides tab badge while open.
  static int _overlayMessagesScreenDepth = 0;

  static Map<String, ConversationThread> _mapForRole(bool isDoctor) =>
      isDoctor ? _doctorThreads : _patientThreads;

  static void _notify() => version.value++;

  static void ensureSeeded(bool isDoctor) {
    if (isDoctor) {
      if (_doctorSeeded) return;
      _doctorSeeded = true;
      _seedDoctorThreads();
    } else {
      if (_patientSeeded) return;
      _patientSeeded = true;
      _seedPatientThreads();
    }
    _notify();
  }

  static void _seedPatientThreads() {
    // Patient chats with doctors / pharmacy — distinct mock histories.
    _patientThreads['pt-dr-sarah'] = ConversationThread(
      id: 'pt-dr-sarah',
      contactName: 'Dr. Sarah Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?img=68',
      useNetworkAvatar: true,
      lastTimeDisplay: '10:30 AM',
      unreadCount: 1,
      initialMessages: [
        ChatBubble(
          id: 'm1',
          text: 'Hello! How can I help you today?',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatBubble(
          id: 'm2',
          text: 'I have a question about my appointment.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
        ),
        ChatBubble(
          id: 'm3',
          text: 'Sure, go ahead.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(hours: 2, minutes: 4)),
        ),
      ],
    );

    _patientThreads['pt-dr-maher'] = ConversationThread(
      id: 'pt-dr-maher',
      contactName: 'Dr. Maher Mahmoud',
      lastTimeDisplay: 'Yesterday',
      unreadCount: 0,
      initialMessages: [
        ChatBubble(
          id: 'm1',
          text: 'Your appointment is confirmed for next Tuesday.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ChatBubble(
          id: 'm2',
          text: 'Thank you! Should I fast before the visit?',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 1, minutes: 2)),
        ),
        ChatBubble(
          id: 'm3',
          text: 'No fasting needed for this visit.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 1, minutes: 1)),
        ),
      ],
    );

    _patientThreads['pt-dr-ali'] = ConversationThread(
      id: 'pt-dr-ali',
      contactName: 'Dr. Ali Ahmed',
      lastTimeDisplay: 'Monday',
      unreadCount: 1,
      initialMessages: [
        ChatBubble(
          id: 'm1',
          text: 'Please send me the lab results when you have them.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ChatBubble(
          id: 'm2',
          text: 'I will upload them this evening.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 3, minutes: 10)),
        ),
      ],
    );

    _patientThreads['pt-pharmacy'] = ConversationThread(
      id: 'pt-pharmacy',
      contactName: 'Stitch Pharmacy',
      lastTimeDisplay: '2 days ago',
      unreadCount: 0,
      initialMessages: [
        ChatBubble(
          id: 'm1',
          text: 'Your order #1234 is ready for pickup.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ChatBubble(
          id: 'm2',
          text: 'What are your opening hours?',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 2, minutes: 30)),
        ),
        ChatBubble(
          id: 'm3',
          text: 'We are open 9 AM – 9 PM daily.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 2, minutes: 29)),
        ),
      ],
    );

    _patientThreads['pt-dr-emily'] = ConversationThread(
      id: 'pt-dr-emily',
      contactName: 'Dr. Emily Chen',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      useNetworkAvatar: true,
      lastTimeDisplay: '1 week ago',
      unreadCount: 0,
      initialMessages: [
        ChatBubble(
          id: 'm1',
          text: 'See you tomorrow at 10 AM.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ChatBubble(
          id: 'm2',
          text: 'I might be 5 minutes late — traffic.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 7, minutes: 5)),
        ),
        ChatBubble(
          id: 'm3',
          text: 'No problem, we will hold your slot.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 7, minutes: 4)),
        ),
      ],
    );

    for (final t in _patientThreads.values) {
      t._syncPreviewFromMessages();
    }
  }

  static void _seedDoctorThreads() {
    // Doctor chats with patients — different people & copy than patient list.
    _doctorThreads['doc-jordan'] = ConversationThread(
      id: 'doc-jordan',
      contactName: 'Jordan Lee',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      useNetworkAvatar: true,
      lastTimeDisplay: '9:12 AM',
      unreadCount: 1,
      initialMessages: [
        ChatBubble(
          id: 'd1',
          text: 'Hi doctor, is it OK to take painkillers before the procedure?',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ChatBubble(
          id: 'd2',
          text: 'Take only what we discussed in clinic — avoid aspirin.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(minutes: 50)),
        ),
      ],
    );

    _doctorThreads['doc-priya'] = ConversationThread(
      id: 'doc-priya',
      contactName: 'Priya Sharma',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      useNetworkAvatar: true,
      lastTimeDisplay: 'Yesterday',
      unreadCount: 0,
      initialMessages: [
        ChatBubble(
          id: 'd1',
          text: 'The cream you prescribed is helping a lot.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        ),
        ChatBubble(
          id: 'd2',
          text: 'Great to hear. Finish the full course.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        ),
      ],
    );

    _doctorThreads['doc-marcus'] = ConversationThread(
      id: 'doc-marcus',
      contactName: 'Marcus Cole',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
      useNetworkAvatar: true,
      lastTimeDisplay: 'Mon',
      unreadCount: 0,
      initialMessages: [
        ChatBubble(
          id: 'd1',
          text: 'My BP readings this week: 128/82, 130/80.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 4)),
        ),
        ChatBubble(
          id: 'd2',
          text: 'Looks stable. Keep logging twice daily.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 4, minutes: 15)),
        ),
      ],
    );

    _doctorThreads['doc-sarah-a'] = ConversationThread(
      id: 'doc-sarah-a',
      contactName: 'Sarah Ahmed',
      avatarUrl: 'https://i.pravatar.cc/150?img=16',
      useNetworkAvatar: true,
      lastTimeDisplay: '3 days ago',
      unreadCount: 1,
      initialMessages: [
        ChatBubble(
          id: 'd1',
          text: 'Can I reschedule my cleaning to next week?',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ChatBubble(
          id: 'd2',
          text: 'Yes — I sent available slots in the portal.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 3, minutes: 20)),
        ),
      ],
    );

    _doctorThreads['doc-mariam'] = ConversationThread(
      id: 'doc-mariam',
      contactName: 'Mariam Adel',
      avatarUrl: 'https://i.pravatar.cc/150?img=45',
      useNetworkAvatar: true,
      lastTimeDisplay: '1 week ago',
      unreadCount: 0,
      initialMessages: [
        ChatBubble(
          id: 'd1',
          text: 'Thank you for the referral to the lab.',
          isSentByMe: false,
          at: DateTime.now().subtract(const Duration(days: 8)),
        ),
        ChatBubble(
          id: 'd2',
          text: 'You are welcome. Let me know the results.',
          isSentByMe: true,
          at: DateTime.now().subtract(const Duration(days: 8, minutes: 2)),
        ),
      ],
    );

    for (final t in _doctorThreads.values) {
      t._syncPreviewFromMessages();
    }
  }

  /// Stable order for the Messages list (matches original mock list order).
  static const List<String> patientThreadOrder = [
    'pt-dr-sarah',
    'pt-dr-maher',
    'pt-dr-ali',
    'pt-pharmacy',
    'pt-dr-emily',
  ];

  static const List<String> doctorThreadOrder = [
    'doc-jordan',
    'doc-priya',
    'doc-marcus',
    'doc-sarah-a',
    'doc-mariam',
  ];

  static List<ConversationThread> orderedThreads(bool isDoctor) {
    ensureSeeded(isDoctor);
    final m = _mapForRole(isDoctor);
    final order = isDoctor ? doctorThreadOrder : patientThreadOrder;
    return order.map((id) => m[id]!).toList();
  }

  static ConversationThread? thread(String id, bool isDoctor) {
    ensureSeeded(isDoctor);
    return _mapForRole(isDoctor)[id];
  }

  static void sendMessage(String threadId, String text, bool isDoctor) {
    final t = thread(threadId, isDoctor);
    if (t == null || text.trim().isEmpty) return;
    t.appendOutgoing(text.trim());
    _notify();
  }

  static void markThreadRead(String threadId, bool isDoctor) {
    final t = thread(threadId, isDoctor);
    t?.markRead();
    _notify();
  }

  /// Sum of [ConversationThread.unreadCount] for the current role (local only).
  static int totalUnreadCount(bool isDoctor) {
    ensureSeeded(isDoctor);
    var sum = 0;
    for (final t in _mapForRole(isDoctor).values) {
      sum += t.unreadCount;
    }
    return sum;
  }

  /// Call from a **pushed** Messages route (e.g. doctor dashboard) so the tab
  /// badge hides while that screen is visible.
  static void registerOverlayMessagesScreenOpened() {
    _overlayMessagesScreenDepth++;
    _notify();
  }

  static void registerOverlayMessagesScreenClosed() {
    if (_overlayMessagesScreenDepth > 0) {
      _overlayMessagesScreenDepth--;
    }
    _notify();
  }

  static int get overlayMessagesScreenDepth => _overlayMessagesScreenDepth;

  /// Local-only: mark a thread as having new unread (e.g. mock “incoming” message).
  static void bumpUnread(String threadId, bool isDoctor, {int delta = 1}) {
    final t = thread(threadId, isDoctor);
    if (t == null || delta <= 0) return;
    t.unreadCount += delta;
    _notify();
  }
}
