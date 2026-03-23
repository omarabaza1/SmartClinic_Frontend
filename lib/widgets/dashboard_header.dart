import 'package:flutter/material.dart';

/// Reusable dashboard header with avatar, greeting, username,
/// notifications icon, and optional logout icon.
class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final ImageProvider avatarImage;
  final VoidCallback onNotificationTap;
  final VoidCallback? onLogoutTap;
  /// When set, tapping the avatar runs this (e.g. open Profile tab / screen).
  final VoidCallback? onAvatarTap;
  final String greeting;
  final int? notificationCount;

  const DashboardHeader({
    super.key,
    required this.username,
    required this.avatarImage,
    required this.onNotificationTap,
    this.onLogoutTap,
    this.onAvatarTap,
    this.greeting = 'Good evening,',
    this.notificationCount,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF111118);

    return AppBar(
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: onAvatarTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAvatarTap,
                    customBorder: const CircleBorder(),
                    child: Tooltip(
                      message: 'Profile',
                      child: ClipOval(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: avatarImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : ClipOval(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: avatarImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            greeting,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            username,
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        if (onLogoutTap != null)
          IconButton(
            onPressed: onLogoutTap,
            icon: const Icon(
              Icons.logout_rounded,
              color: textColor,
              size: 22,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: onNotificationTap,
            icon: (notificationCount != null && notificationCount! > 0)
                ? Badge(
                    label: Text('${notificationCount!}'),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: textColor,
                      size: 26,
                    ),
                  )
                : const Icon(
                    Icons.notifications_none_outlined,
                    color: textColor,
                    size: 26,
                  ),
          ),
        ),
      ],
    );
  }
}

