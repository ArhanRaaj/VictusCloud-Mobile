import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type; // e.g., 'alert', 'backup', 'invoice', 'ticket'

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super([]) {
    _loadDummyData();
  }

  void _loadDummyData() {
    state = [
      AppNotification(
        id: '1',
        title: 'Server Crash Alert',
        body: 'Server Node-01 has gone offline.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'alert',
      ),
      AppNotification(
        id: '2',
        title: 'Backup Completed',
        body: 'Automated backup for Node-02 finished successfully.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'backup',
      ),
      AppNotification(
        id: '3',
        title: 'Invoice Due',
        body: 'Your invoice for this month is due in 3 days.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'invoice',
      ),
      AppNotification(
        id: '4',
        title: 'Ticket Update',
        body: 'Support has replied to your ticket #1024.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'ticket',
        isRead: true,
      ),
    ];
  }

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];
  }

  void markAllAsRead() {
    state = [
      for (final n in state) n.copyWith(isRead: true)
    ];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});
