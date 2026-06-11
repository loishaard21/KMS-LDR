import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/guest/screens/guest_dashboard_screen.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final String? subLabel;

  const MenuItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.index,
    this.subLabel,
  });
}

// Admin (superadmin) menu items — matches user spec exactly
const List<MenuItem> adminMenuItems = [
  MenuItem(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, index: 0),
  MenuItem(label: 'All Posts', icon: Icons.article_outlined, activeIcon: Icons.article, index: 1, subLabel: 'Post'),
  MenuItem(label: 'Add Post', icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, index: 2, subLabel: 'Post'),
  MenuItem(label: 'Kelola Panduan', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, index: 3),
  MenuItem(label: 'Kelola Regulasi', icon: Icons.gavel_outlined, activeIcon: Icons.gavel, index: 4),
  MenuItem(label: 'Agenda', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, index: 5),
  MenuItem(label: 'Kontak', icon: Icons.support_agent_outlined, activeIcon: Icons.support_agent, index: 6),
];

// Operator menu items — matches user spec exactly
const List<MenuItem> operatorMenuItems = [
  MenuItem(label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, index: 0),
  MenuItem(label: 'Kelola Seminar', icon: Icons.book_outlined, activeIcon: Icons.book, index: 1),
  MenuItem(label: 'Kelola Materi', icon: Icons.description_outlined, activeIcon: Icons.description, index: 2),
  MenuItem(label: 'Kelola Artikel', icon: Icons.newspaper_outlined, activeIcon: Icons.newspaper, index: 3),
  MenuItem(label: 'Kelola Regulasi', icon: Icons.gavel_outlined, activeIcon: Icons.gavel, index: 4),
  MenuItem(label: 'Kelola Evaluasi', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, index: 5),
];

class AdminDrawer extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const AdminDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.role == 'superadmin';
    final menuItems = isAdmin ? adminMenuItems : operatorMenuItems;

    // Group items by subLabel for admin (Post sub-menu)
    String? currentGroup;

    return Drawer(
      backgroundColor: const Color(0xFF1A2332),
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            // Brand Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF2D3748), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0052CC), Color(0xFF00B4D8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KMS Pemprov',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        'Lampung',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // User Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF2D3748), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF0052CC), Color(0xFF00B4D8)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isAdmin ? 'Super Admin' : 'Operator',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final isActive = currentIndex == item.index;

                  // Show sub-section header for Post group
                  final bool showGroupHeader = isAdmin &&
                      item.subLabel != null &&
                      item.subLabel != currentGroup;
                  if (showGroupHeader) {
                    currentGroup = item.subLabel;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showGroupHeader) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 14, top: 10, bottom: 4),
                          child: Text(
                            item.subLabel!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              onItemSelected(item.index);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF0052CC) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? item.activeIcon : item.icon,
                                    size: 18,
                                    color: isActive ? Colors.white : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isActive ? Colors.white : const Color(0xFF94A3B8),
                                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isActive)
                                    const Icon(Icons.chevron_right, size: 16, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Logout
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF2D3748), width: 1)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(authProvider.notifier).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const GuestDashboardScreen()),
                      (route) => false,
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: Color(0xFF94A3B8)),
                        SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
