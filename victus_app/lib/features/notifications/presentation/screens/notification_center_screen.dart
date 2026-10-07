import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'backup':
        return Icons.cloud_done_outlined;
      case 'invoice':
        return Icons.receipt_long_outlined;
      case 'ticket':
        return Icons.support_agent;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (notifier.unreadCount > 0)
            TextButton(
              onPressed: () {
                notifier.markAllAsRead();
              },
              child: const Text('Mark all as read', style: TextStyle(color: Colors.white70)),
            )
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: notification.isRead ? Colors.transparent : Colors.white.withOpacity(0.05),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white12,
                        child: Icon(
                          _getIconForType(notification.type),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      if (!notification.isRead)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeago.format(notification.timestamp),
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!notification.isRead) {
                      notifier.markAsRead(notification.id);
                    }
                  },
                );
              },
            ),
    );
  }
}
