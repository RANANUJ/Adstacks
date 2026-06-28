import 'employee.dart';

enum ProjectStatus {
  notStarted,
  inProgress,
  completed,
  delayed,
}

class Project {
  final String id;
  final String title;
  final String description;
  final double progress; // 0.0 to 1.0
  final ProjectStatus status;
  final List<Employee> assignees;
  final DateTime deadline;
  final String category;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.status,
    required this.assignees,
    required this.deadline,
    required this.category,
  });

  String get statusText {
    switch (status) {
      case ProjectStatus.notStarted:
        return 'Not Started';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.delayed:
        return 'Delayed';
    }
  }
}
