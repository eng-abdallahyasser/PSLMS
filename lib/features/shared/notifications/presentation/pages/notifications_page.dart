import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/shared/notifications/presentation/cubit/notification_cubit.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all read',
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          return switch (state) {
            NotificationInitial() => const SizedBox.shrink(),
            NotificationsLoading() => const AppLoadingWidget(),
            NotificationsLoaded(:final notifications) => _buildList(notifications),
            NotificationsError(:final message) =>
              AppErrorWidget(message: message, onRetry: () => context.read<NotificationCubit>().getNotifications()),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildList(List notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No notifications', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<NotificationCubit>().getNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: notification.isRead ? Colors.grey[200] : Colors.blue[100],
                child: Icon(
                  Icons.notifications,
                  color: notification.isRead ? Colors.grey : Colors.blue,
                ),
              ),
              title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
              subtitle: notification.body != null ? Text(notification.body!, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
              trailing: notification.isRead
                  ? null
                  : IconButton(
                      icon: Icon(Icons.mark_email_read, size: 20, color: Colors.blue[400]),
                      onPressed: () => context.read<NotificationCubit>().markAsRead(notification.id),
                    ),
            ),
          );
        },
      ),
    );
  }
}
