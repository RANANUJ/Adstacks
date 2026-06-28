import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';

class TopBarWidget extends StatefulWidget {
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const TopBarWidget({
    super.key,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Retrieve initial query without listening
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    _searchController = TextEditingController(text: provider.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    // Sync external clears (like clicking close button)
    if (_searchController.text != provider.searchQuery) {
      _searchController.text = provider.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: provider.searchQuery.length),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.topBarBg,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Drawer Menu Toggle for Mobile
          if (widget.showMenuButton) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: widget.onMenuPressed,
            ),
            const SizedBox(width: 8),
          ],

          // Search Field
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.glassBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search projects or categories...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                            onPressed: () {
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),

          // Notifications Center
          _buildNotificationButton(context, provider),

          const SizedBox(width: 20),
          
          // Verticle Divider
          Container(
            height: 24,
            width: 1,
            color: AppColors.glassBorder,
          ),

          const SizedBox(width: 20),

          // Profile Section
          _buildProfile(context, provider),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, DashboardProvider provider) {
    final list = provider.notifications;
    final badgeCount = list.length;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: AppColors.bgEnd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onSelected: (_) {},
      itemBuilder: (BuildContext context) {
        if (list.isEmpty) {
          return [
            const PopupMenuItem(
              enabled: false,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          ];
        }

        return [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: AppColors.glassBorder),
              ],
            ),
          ),
          ...list.map((notification) {
            return PopupMenuItem<String>(
              value: notification,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryStart,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ];
      },
    );
  }

  Widget _buildProfile(BuildContext context, DashboardProvider provider) {
    // Current user represents Anuj Rana
    final user = provider.employees.firstWhere(
      (e) => e.name == 'Anuj Rana',
      orElse: () => const Employee(
        id: 'user_anuj',
        name: 'Anuj Rana',
        role: 'Admin',
        avatarUrl: '',
        email: 'anuj.rana@adstacks.com',
      ),
    );

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              user.role,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryStart, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryStart.withOpacity(0.2),
                blurRadius: 6,
              )
            ],
            image: user.avatarUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(user.avatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: user.avatarUrl.isEmpty
              ? const Center(
                  child: Text(
                    'AR',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
