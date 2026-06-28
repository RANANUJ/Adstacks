import '../models/project.dart';
import '../models/employee.dart';
import '../models/performance_metric.dart';
import 'api_service.dart';

class MockApiService implements ApiService {
  @override
  Future<List<Employee>> getEmployees() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();

    return [
      Employee(
        id: 'emp_1',
        name: 'Anuj Rana',
        role: 'Admin',
        avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=120',
        email: 'anuj.rana@adstacks.com',
        birthday: DateTime(now.year, now.month, now.day - 5),
        anniversary: DateTime(now.year - 1, now.month, now.day - 20),
        yearsAtCompany: 1,
      ),
      Employee(
        id: 'emp_2',
        name: 'John Doe',
        role: 'UI/UX Designer',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=120',
        email: 'john.doe@adstacks.com',
        // Birthday is TODAY
        birthday: DateTime(1995, now.month, now.day),
        anniversary: DateTime(2022, now.month, now.day - 12),
        yearsAtCompany: 4,
      ),
      Employee(
        id: 'emp_3',
        name: 'Alice Smith',
        role: 'Backend Engineer',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120',
        email: 'alice.smith@adstacks.com',
        birthday: DateTime(1994, now.month, now.day + 15),
        // Anniversary is TODAY
        anniversary: DateTime(now.year - 3, now.month, now.day),
        yearsAtCompany: 3,
      ),
      Employee(
        id: 'emp_4',
        name: 'Bob Johnson',
        role: 'Project Manager',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120',
        email: 'bob.johnson@adstacks.com',
        // Birthday is TOMORROW
        birthday: DateTime(1990, now.month, now.day + 1),
        anniversary: DateTime(2021, 2, 14),
        yearsAtCompany: 5,
      ),
      Employee(
        id: 'emp_5',
        name: 'Carol White',
        role: 'Marketing Lead',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=120',
        email: 'carol.white@adstacks.com',
        birthday: DateTime(1993, now.month + 1, 10),
        anniversary: DateTime(now.year - 2, now.month, now.day + 1), // Anniversary TOMORROW
        yearsAtCompany: 2,
      ),
      Employee(
        id: 'emp_6',
        name: 'Dave Brown',
        role: 'QA Specialist',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=120',
        email: 'dave.brown@adstacks.com',
        birthday: DateTime(1996, now.month, now.day + 4),
        anniversary: DateTime(2023, 8, 25),
        yearsAtCompany: 3,
      ),
    ];
  }

  @override
  Future<List<Project>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final employees = await getEmployees();
    final now = DateTime.now();

    // Map employees by ID for easy reference
    final empMap = {for (var e in employees) e.id: e};

    return [
      Project(
        id: 'proj_1',
        title: 'AdStacks Office Dashboard',
        description: 'Building a premium, glassmorphic office management dashboard in Flutter with beautiful state tracking and performance widgets.',
        progress: 0.75,
        status: ProjectStatus.inProgress,
        assignees: [
          empMap['emp_1']!, // Anuj Rana
          empMap['emp_2']!, // John Doe
          empMap['emp_3']!, // Alice Smith
        ],
        deadline: now.add(const Duration(days: 10)),
        category: 'Flutter Dev',
      ),
      Project(
        id: 'proj_2',
        title: 'Marketing Campaign Q3',
        description: 'Coordinating SEO, SEM, and performance marketing assets for upcoming seasonal brand campaigns.',
        progress: 0.45,
        status: ProjectStatus.inProgress,
        assignees: [
          empMap['emp_5']!, // Carol White
          empMap['emp_6']!, // Dave Brown
        ],
        deadline: now.add(const Duration(days: 25)),
        category: 'Marketing',
      ),
      Project(
        id: 'proj_3',
        title: 'API Overhaul & Microservices',
        description: 'Refactoring central server endpoints, integrating Appwrite services, and optimizing database indices.',
        progress: 0.30,
        status: ProjectStatus.delayed,
        assignees: [
          empMap['emp_3']!, // Alice Smith
          empMap['emp_4']!, // Bob Johnson
        ],
        deadline: now.add(const Duration(days: 4)),
        category: 'Backend',
      ),
      Project(
        id: 'proj_4',
        title: 'Client Webapp Redesign',
        description: 'Revamping primary client-facing dashboards and portal screens for cleaner user workflows.',
        progress: 1.0,
        status: ProjectStatus.completed,
        assignees: [
          empMap['emp_2']!, // John Doe
          empMap['emp_4']!, // Bob Johnson
        ],
        deadline: now.subtract(const Duration(days: 2)),
        category: 'UI/UX Design',
      ),
      Project(
        id: 'proj_5',
        title: 'Security Compliance Audit',
        description: 'Evaluating internal systems against modern security compliance benchmarks and data logging requirements.',
        progress: 0.0,
        status: ProjectStatus.notStarted,
        assignees: [
          empMap['emp_4']!, // Bob Johnson
          empMap['emp_6']!, // Dave Brown
        ],
        deadline: now.add(const Duration(days: 45)),
        category: 'Operations',
      ),
    ];
  }

  @override
  Future<List<PerformanceMetric>> getPerformanceMetrics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      PerformanceMetric(label: 'Jan', rating: 65, completedTasks: 12, activeProjects: 4),
      PerformanceMetric(label: 'Feb', rating: 78, completedTasks: 15, activeProjects: 5),
      PerformanceMetric(label: 'Mar', rating: 72, completedTasks: 14, activeProjects: 5),
      PerformanceMetric(label: 'Apr', rating: 85, completedTasks: 22, activeProjects: 6),
      PerformanceMetric(label: 'May', rating: 94, completedTasks: 27, activeProjects: 7),
      PerformanceMetric(label: 'Jun', rating: 91, completedTasks: 20, activeProjects: 6),
    ];
  }

  @override
  Future<List<String>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      'John Doe is celebrating their birthday today! 🎂 Send them a wish.',
      'API Overhaul project is marked as "Delayed". Action required.',
      'Weekly sync is scheduled today at 3:00 PM in Conference Room A.',
      'Anuj Rana uploaded a new Figma frame to AdStacks Office Dashboard.',
    ];
  }
}
