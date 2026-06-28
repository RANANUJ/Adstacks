import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/topbar_widget.dart';
import '../widgets/hero_banner.dart';
import '../widgets/project_list.dart';
import '../widgets/performance_chart.dart';
import '../widgets/right_sidebar_widget.dart';
import '../widgets/admin_portal_view.dart';
import '../models/employee.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load dashboard data on mount
    Future.microtask(() {
      if (mounted) {
        Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: const Drawer(
        elevation: 0,
        child: SidebarWidget(isDrawer: true),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgStart, AppColors.bgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Builder(
            builder: (context) {
              if (provider.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryStart),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Connecting to Appwrite API Layer...',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              if (provider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        onPressed: () => provider.loadDashboardData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryStart,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Responsive Layout builder
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  
                  final bool isDesktop = width >= 1100;
                  final bool isTablet = width >= 750 && width < 1100;
                  final bool isMobile = width < 750;

                  return Row(
                    children: [
                      // 1. Sidebar (Only visible directly on Desktop)
                      if (isDesktop) const SidebarWidget(isDrawer: false),

                      // 2. Main content area (Always visible)
                      Expanded(
                        child: Column(
                          children: [
                            // Top Bar (Toggle Drawer on mobile/tablet)
                            TopBarWidget(
                              showMenuButton: !isDesktop,
                              onMenuPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            ),

                            // Main Scrollable Dashboard contents
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24.0),
                                child: _buildBodyContent(provider.activeTab, isDesktop, isTablet),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. Right Sidebar (Visible on Desktop and Tablet)
                      if (isDesktop || isTablet) const RightSidebarWidget(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(String activeTab, bool isDesktop, bool isTablet) {
    switch (activeTab) {
      case 'Admin Portal':
        return const AdminPortalView();
      case 'Projects':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Project Catalog',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 6),
            Text('Browse and search through all ongoing and completed projects.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 24),
            ProjectList(),
          ],
        );
      case 'Employees':
        return const _EmployeeDirectoryView();
      case 'Settings':
        return const _SettingsView();
      case 'Home':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome greeting Hero banner
            const HeroBanner(),
            
            const SizedBox(height: 24),

            // Layout splits for middle sections
            const PerformanceChart(),
            const SizedBox(height: 24),
            const ProjectList(),
            
            if (!isDesktop && !isTablet) ...[
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              
              // Append Right Sidebar widgets at bottom of mobile feed
              const Text(
                'Calendar & Events',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const RightSidebarWidget(isSidebar: false),
            ],
          ],
        );
    }
  }
}

// Private Sub-view representing Employee Grid View
class _EmployeeDirectoryView extends StatelessWidget {
  const _EmployeeDirectoryView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final list = provider.filteredEmployees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Employee Staff Directory',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text('Directory index of all active developers, designers, and admins.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            int crossCount = 3;
            if (width < 600) crossCount = 1;
            else if (width < 900) crossCount = 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 160,
              ),
              itemBuilder: (context, idx) {
                final emp = list[idx];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.glassBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryStart, width: 1.5),
                          image: emp.avatarUrl.isNotEmpty ? DecorationImage(image: NetworkImage(emp.avatarUrl), fit: BoxFit.cover) : null,
                        ),
                        child: emp.avatarUrl.isEmpty
                            ? Center(
                                child: Text(
                                  emp.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: AppColors.primaryStart, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        emp.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emp.role,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// Private Sub-view representing Settings
class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Console Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text('Configure preferences and system endpoints.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('System Configurations', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSettingItem(Icons.dark_mode_rounded, 'Interface Theme', 'Dark Glassmorphism (Locked)'),
              const Divider(),
              _buildSettingItem(Icons.api_rounded, 'Backend Service Node', 'Appwrite API Service Gateway (Mock Mode)'),
              const Divider(),
              _buildSettingItem(Icons.security_rounded, 'Encryption Level', 'TLS 1.3 / AES-256 Bit'),
              const Divider(),
              _buildSettingItem(Icons.info_outline_rounded, 'Version Release', 'v0.1.0-alpha'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryStart, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(val, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
