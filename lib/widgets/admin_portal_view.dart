import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../models/project.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';
import 'admin_dialogs.dart';

class AdminPortalView extends StatefulWidget {
  const AdminPortalView({super.key});

  @override
  State<AdminPortalView> createState() => _AdminPortalViewState();
}

class _AdminPortalViewState extends State<AdminPortalView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final projects = provider.projects;
    final employees = provider.employees;

    // Calculate quick stats
    final totalProjects = projects.length;
    final totalStaff = employees.length;
    final activeAlerts = provider.notifications.length;
    
    double avgProgress = 0.0;
    if (projects.isNotEmpty) {
      final sum = projects.fold<double>(0, (prev, p) => prev + p.progress);
      avgProgress = sum / projects.length;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isMobile = width < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            const Text(
              'Admin Control Portal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'System management console for AdStacks Media. Perform CRUD on active records.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),

            const SizedBox(height: 24),

            // KPI Stats Row (Responsive wrap on mobile)
            isMobile 
              ? Column(
                  children: [
                    _buildKPICard('Registry Projects', '$totalProjects', Icons.folder_copy_rounded, Colors.purple),
                    const SizedBox(height: 12),
                    _buildKPICard('Active Staff', '$totalStaff', Icons.groups_rounded, Colors.cyan),
                    const SizedBox(height: 12),
                    _buildKPICard('Avg Completion', '${(avgProgress * 100).toInt()}%', Icons.donut_large_rounded, Colors.green),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildKPICard('Registry Projects', '$totalProjects', Icons.folder_copy_rounded, Colors.purple)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKPICard('Active Staff', '$totalStaff', Icons.groups_rounded, Colors.cyan)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKPICard('Avg Completion', '${(avgProgress * 100).toInt()}%', Icons.donut_large_rounded, Colors.green)),
                  ],
                ),

            const SizedBox(height: 24),

            // Quick Actions Panel
            _buildQuickActions(context),

            const SizedBox(height: 24),

            // Tabs Header
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryStart,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: 'Project Registry'),
                  Tab(text: 'Employee Directory'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab View Content (Fixed size or constrained)
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProjectRegistry(context, provider.filteredProjects, isMobile),
                  _buildEmployeeDirectory(context, provider.filteredEmployees, isMobile),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                val,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryStart.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryStart.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Operations Console',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Onboard Project'),
                onPressed: () => AdminDialogs.showProjectDialog(context),
                style: _buildActionButtonStyle(AppColors.primaryStart),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Staff Member'),
                onPressed: () => AdminDialogs.showEmployeeDialog(context),
                style: _buildActionButtonStyle(AppColors.secondaryStart),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.campaign_rounded, size: 18),
                label: const Text('Broadcast Alert'),
                onPressed: () => AdminDialogs.showAnnouncementDialog(context),
                style: _buildActionButtonStyle(AppColors.warningStart),
              ),
            ],
          )
        ],
      ),
    );
  }

  ButtonStyle _buildActionButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
    );
  }

  // ----------------------------------------------------
  // Project Registry Builder
  // ----------------------------------------------------
  Widget _buildProjectRegistry(BuildContext context, List<Project> list, bool isMobile) {
    if (list.isEmpty) {
      return _buildEmptyState('No projects registered.', Icons.folder_open_rounded);
    }

    if (isMobile) {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, idx) {
          final project = list[idx];
          return _buildMobileProjectCard(context, project);
        },
      );
    }

    // Wide Web Layout Table
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg.withOpacity(0.02),
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.glassBg),
          dataRowMaxHeight: 64,
          columns: const [
            DataColumn(label: Text('Project Info', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Category', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Progress', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
          ],
          rows: list.map((project) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        'Assignees: ${project.assignees.length}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(project.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                DataCell(
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: LinearProgressIndicator(
                          value: project.progress,
                          backgroundColor: AppColors.glassBorder,
                          color: AppColors.primaryStart,
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(project.progress * 100).toInt()}%', style: const TextStyle(color: AppColors.textPrimary, fontSize: 11)),
                    ],
                  ),
                ),
                DataCell(_buildStatusChip(project.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.cyan, size: 18),
                        tooltip: 'Edit details',
                        onPressed: () => AdminDialogs.showProjectDialog(context, project: project),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        tooltip: 'Delete project',
                        onPressed: () => _confirmDeleteDialog(context, project.title, () {
                          Provider.of<DashboardProvider>(context, listen: false).deleteProject(project.id);
                          Provider.of<DashboardProvider>(context, listen: false).addNotification('Project "${project.title}" deleted.');
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileProjectCard(BuildContext context, Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(project.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                _buildStatusChip(project.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Category: ${project.category}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: project.progress, minHeight: 4, backgroundColor: AppColors.glassBorder, color: AppColors.primaryStart),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(project.progress * 100).toInt()}%', style: const TextStyle(color: AppColors.textPrimary, fontSize: 11)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.cyan, size: 18),
                  onPressed: () => AdminDialogs.showProjectDialog(context, project: project),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  onPressed: () => _confirmDeleteDialog(context, project.title, () {
                    Provider.of<DashboardProvider>(context, listen: false).deleteProject(project.id);
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    Color col;
    String txt;

    switch (status) {
      case ProjectStatus.completed:
        col = AppColors.successStart;
        txt = 'Completed';
        break;
      case ProjectStatus.inProgress:
        col = AppColors.secondaryStart;
        txt = 'In Progress';
        break;
      case ProjectStatus.delayed:
        col = AppColors.errorStart;
        txt = 'Delayed';
        break;
      case ProjectStatus.notStarted:
      default:
        col = AppColors.textMuted;
        txt = 'Not Started';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: col.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: col.withOpacity(0.3)),
      ),
      child: Text(
        txt,
        style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ----------------------------------------------------
  // Employee Directory Builder
  // ----------------------------------------------------
  Widget _buildEmployeeDirectory(BuildContext context, List<Employee> list, bool isMobile) {
    if (list.isEmpty) {
      return _buildEmptyState('No employees found.', Icons.people_outline_rounded);
    }

    if (isMobile) {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, idx) {
          final emp = list[idx];
          return _buildMobileEmployeeCard(context, emp);
        },
      );
    }

    // Wide Web Layout Table
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg.withOpacity(0.02),
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.glassBg),
          dataRowMaxHeight: 64,
          columns: const [
            DataColumn(label: Text('Staff Member', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Designation', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email Address', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tenure', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
          ],
          rows: list.map((emp) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryStart.withOpacity(0.5)),
                          image: emp.avatarUrl.isNotEmpty ? DecorationImage(image: NetworkImage(emp.avatarUrl), fit: BoxFit.cover) : null,
                        ),
                        child: emp.avatarUrl.isEmpty
                            ? Center(
                                child: Text(
                                  emp.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: AppColors.primaryStart, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(emp.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                DataCell(Text(emp.role, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                DataCell(Text(emp.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                DataCell(Text('${emp.yearsAtCompany ?? 1} yrs', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.cyan, size: 18),
                        tooltip: 'Edit profile',
                        onPressed: () => AdminDialogs.showEmployeeDialog(context, employee: emp),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        tooltip: 'De-register',
                        onPressed: () {
                          // Prevent self-deletion of primary developer account
                          if (emp.name == 'Anuj Rana') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cannot remove the primary administrator account (Anuj Rana).'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          _confirmDeleteDialog(context, emp.name, () {
                            Provider.of<DashboardProvider>(context, listen: false).deleteEmployee(emp.id);
                            Provider.of<DashboardProvider>(context, listen: false).addNotification('Staff member "${emp.name}" removed from registry.');
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileEmployeeCard(BuildContext context, Employee emp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryStart.withOpacity(0.5)),
            image: emp.avatarUrl.isNotEmpty ? DecorationImage(image: NetworkImage(emp.avatarUrl), fit: BoxFit.cover) : null,
          ),
          child: emp.avatarUrl.isEmpty
              ? Center(child: Text(emp.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.primaryStart, fontWeight: FontWeight.bold)))
              : null,
        ),
        title: Text(emp.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${emp.role} • ${emp.email}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.cyan, size: 16),
              onPressed: () => AdminDialogs.showEmployeeDialog(context, employee: emp),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
              onPressed: () {
                if (emp.name == 'Anuj Rana') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot remove the primary developer account (Anuj Rana).'), backgroundColor: Colors.red),
                  );
                  return;
                }
                _confirmDeleteDialog(context, emp.name, () {
                  Provider.of<DashboardProvider>(context, listen: false).deleteEmployee(emp.id);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Helpers
  // ----------------------------------------------------
  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 36),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(BuildContext context, String recordName, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgEnd,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.glassBorder)),
          title: const Text('Confirm Deletion', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete "$recordName"? This action is permanent and will remove them from all linked registries.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$recordName" deleted successfully!'), backgroundColor: Colors.redAccent),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
