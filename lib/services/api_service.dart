import '../models/project.dart';
import '../models/employee.dart';
import '../models/performance_metric.dart';

abstract class ApiService {
  Future<List<Project>> getProjects();
  Future<List<Employee>> getEmployees();
  Future<List<PerformanceMetric>> getPerformanceMetrics();
  Future<List<String>> getNotifications();
}
