import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';

class ProjectList extends StatelessWidget {
  const ProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final projects = provider.filteredProjects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ongoing Projects',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Showing ${projects.length} results',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (projects.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  color: AppColors.textMuted,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects found matching your search.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          // Adaptive Grid or List depending on screen width
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 220,
                ),
                itemBuilder: (context, index) {
                  return _buildProjectCard(context, projects[index]);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    // Status color selection
    Color statusColor;
    switch (project.status) {
      case ProjectStatus.completed:
        statusColor = AppColors.successStart;
        break;
      case ProjectStatus.inProgress:
        statusColor = AppColors.secondaryStart;
        break;
      case ProjectStatus.delayed:
        statusColor = AppColors.errorStart;
        break;
      case ProjectStatus.notStarted:
      default:
        statusColor = AppColors.textMuted;
        break;
    }

    final deadlineStr = DateFormat('MMM dd, yyyy').format(project.deadline);
    final daysRemaining = project.deadline.difference(DateTime.now()).inDays;
    
    String statusLabel = project.statusText;

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category & Status tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryStart.withOpacity(0.2)),
                ),
                child: Text(
                  project.category,
                  style: const TextStyle(
                    color: AppColors.primaryStart,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Project Title
          Text(
            project.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 6),

          // Project Description
          Expanded(
            child: Text(
              project.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // Progress section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              Text(
                '${(project.progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: project.progress,
              backgroundColor: AppColors.glassBorder,
              color: statusColor,
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 12),

          // Footer: Assignees & Deadline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Overlapping assignees list
              SizedBox(
                height: 28,
                width: project.assignees.isEmpty ? 0 : 30.0 + (project.assignees.length - 1) * 16.0,
                child: Stack(
                  children: List.generate(
                    project.assignees.length,
                    (index) {
                      final employee = project.assignees[index];
                      return Positioned(
                        left: index * 16.0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bgEnd, width: 1.5),
                            image: employee.avatarUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(employee.avatarUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: employee.avatarUrl.isEmpty
                              ? Center(
                                  child: Text(
                                    employee.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Deadline or remaining days text
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.textMuted,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    daysRemaining > 0 
                        ? '$daysRemaining days left' 
                        : (daysRemaining == 0 ? 'Due today' : 'Overdue'),
                    style: TextStyle(
                      color: daysRemaining < 3 && project.status != ProjectStatus.completed
                          ? AppColors.errorStart
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: daysRemaining < 3 && project.status != ProjectStatus.completed
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
