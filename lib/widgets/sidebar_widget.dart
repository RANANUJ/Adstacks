import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';

class SidebarWidget extends StatelessWidget {
  final bool isDrawer;

  const SidebarWidget({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final activeTab = provider.activeTab;

    return Container(
      width: 250,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDrawer ? AppColors.bgStart : AppColors.sidebarBg,
        border: isDrawer
            ? null
            : const Border(
                right: BorderSide(color: AppColors.glassBorder, width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryStart, AppColors.primaryEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryStart.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AdStacks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Main Navigation Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'MENU',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Navigation Links
          _buildNavItem(
            context,
            title: 'Home',
            icon: Icons.grid_view_rounded,
            isActive: activeTab == 'Home',
            onTap: () {
              provider.setActiveTab('Home');
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _buildNavItem(
            context,
            title: 'Projects',
            icon: Icons.folder_copy_rounded,
            isActive: activeTab == 'Projects',
            onTap: () {
              provider.setActiveTab('Projects');
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _buildNavItem(
            context,
            title: 'Employees',
            icon: Icons.people_alt_rounded,
            isActive: activeTab == 'Employees',
            onTap: () {
              provider.setActiveTab('Employees');
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _buildNavItem(
            context,
            title: 'Settings',
            icon: Icons.settings_rounded,
            isActive: activeTab == 'Settings',
            onTap: () {
              provider.setActiveTab('Settings');
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _buildNavItem(
            context,
            title: 'Admin Portal',
            icon: Icons.admin_panel_settings_rounded,
            isActive: activeTab == 'Admin Portal',
            onTap: () {
              provider.setActiveTab('Admin Portal');
              if (isDrawer) Navigator.pop(context);
            },
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          // Workspaces Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'WORKSPACES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          _buildWorkspaceItem(
            title: 'Marketing & SEO',
            color: Colors.cyan,
          ),
          _buildWorkspaceItem(
            title: 'Flutter Development',
            color: Colors.purple,
          ),
          _buildWorkspaceItem(
            title: 'UI/UX Design',
            color: Colors.pink,
          ),
          _buildWorkspaceItem(
            title: 'Security Operations',
            color: Colors.amber,
          ),

          const Spacer(),

          // Connection status
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Connected to Appwrite',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return _HoverableWidget(
      builder: (context, isHovered) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0x338B5CF6), Color(0x11D946EF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : (isHovered ? const LinearGradient(
                      colors: [Color(0x1FFFFFFF), Color(0x08FFFFFF)],
                    ) : null),
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: AppColors.primaryStart.withOpacity(0.5))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? AppColors.primaryStart
                      : (isHovered ? AppColors.textPrimary : AppColors.textSecondary),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.textPrimary
                        : (isHovered ? AppColors.textPrimary : AppColors.textSecondary),
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryStart,
                      shape: BoxShape.circle,
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceItem({
    required String title,
    required Color color,
  }) {
    return _HoverableWidget(
      builder: (context, isHovered) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isHovered ? AppColors.glassBg : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Simple Helper to handle Hover state in widgets
class _HoverableWidget extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;

  const _HoverableWidget({required this.builder});

  @override
  State<_HoverableWidget> createState() => _HoverableWidgetState();
}

class _HoverableWidgetState extends State<_HoverableWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}
