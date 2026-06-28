import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/employee.dart';
import '../models/performance_metric.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;

  DashboardProvider(this._apiService);

  bool _isLoading = false;
  String? _errorMessage;
  
  List<Project> _projects = [];
  List<Employee> _employees = [];
  List<PerformanceMetric> _performanceMetrics = [];
  List<String> _notifications = [];

  // Active state for navigation sidebar
  String _activeTab = 'Home';

  // Search input filter
  String _searchQuery = '';

  // Selected date on custom calendar
  DateTime _selectedDate = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Project> get projects => _projects;
  List<Employee> get employees => _employees;
  List<PerformanceMetric> get performanceMetrics => _performanceMetrics;
  List<String> get notifications => _notifications;
  String get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  DateTime get selectedDate => _selectedDate;

  // Filtered projects list based on search query
  List<Project> get filteredProjects {
    if (_searchQuery.trim().isEmpty) {
      return _projects;
    }
    final query = _searchQuery.toLowerCase();
    return _projects.where((project) {
      return project.title.toLowerCase().contains(query) ||
             project.category.toLowerCase().contains(query) ||
             project.description.toLowerCase().contains(query);
    }).toList();
  }

  // Filtered employees list based on search query
  List<Employee> get filteredEmployees {
    if (_searchQuery.trim().isEmpty) {
      return _employees;
    }
    final query = _searchQuery.toLowerCase();
    return _employees.where((emp) {
      return emp.name.toLowerCase().contains(query) ||
             emp.role.toLowerCase().contains(query) ||
             emp.email.toLowerCase().contains(query);
    }).toList();
  }

  // Count of items in different project states
  int get countCompletedProjects => _projects.where((p) => p.status == ProjectStatus.completed).length;
  int get countInProgressProjects => _projects.where((p) => p.status == ProjectStatus.inProgress).length;
  int get countDelayedProjects => _projects.where((p) => p.status == ProjectStatus.delayed).length;

  // Setters and Actions
  void setActiveTab(String tab) {
    if (_activeTab != tab) {
      _activeTab = tab;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Admin CRUD Operations
  void addProject(Project project) {
    _projects.insert(0, project);
    notifyListeners();
  }

  void updateProject(Project updated) {
    final idx = _projects.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _projects[idx] = updated;
      notifyListeners();
    }
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(Employee updated) {
    final idx = _employees.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _employees[idx] = updated;
      
      // Update employee details in any project assignees lists
      for (int i = 0; i < _projects.length; i++) {
        final project = _projects[i];
        final empIndex = project.assignees.indexWhere((a) => a.id == updated.id);
        if (empIndex != -1) {
          final updatedAssignees = List<Employee>.from(project.assignees);
          updatedAssignees[empIndex] = updated;
          _projects[i] = Project(
            id: project.id,
            title: project.title,
            description: project.description,
            progress: project.progress,
            status: project.status,
            assignees: updatedAssignees,
            deadline: project.deadline,
            category: project.category,
          );
        }
      }
      notifyListeners();
    }
  }

  void deleteEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    // Remove deleted employee from project assignees as well
    for (int i = 0; i < _projects.length; i++) {
      final updatedAssignees = _projects[i].assignees.where((a) => a.id != id).toList();
      _projects[i] = Project(
        id: _projects[i].id,
        title: _projects[i].title,
        description: _projects[i].description,
        progress: _projects[i].progress,
        status: _projects[i].status,
        assignees: updatedAssignees,
        deadline: _projects[i].deadline,
        category: _projects[i].category,
      );
    }
    notifyListeners();
  }

  void addNotification(String message) {
    _notifications.insert(0, message);
    notifyListeners();
  }

  /// Get list of events (birthdays / anniversaries) on the selected date
  List<String> getEventsForSelectedDate() {
    final events = <String>[];
    for (var emp in _employees) {
      if (emp.birthday != null && 
          emp.birthday!.month == _selectedDate.month && 
          emp.birthday!.day == _selectedDate.day) {
        events.add('🎂 ${emp.name}\'s Birthday!');
      }
      if (emp.anniversary != null && 
          emp.anniversary!.month == _selectedDate.month && 
          emp.anniversary!.day == _selectedDate.day) {
        final years = emp.yearsAtCompany ?? 1;
        events.add('🎉 ${emp.name}\'s Work Anniversary ($years ${years == 1 ? 'Year' : 'Years'})!');
      }
    }
    return events;
  }

  /// Load all data asynchronously from the ApiService
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch in parallel for better speed
      final results = await Future.wait([
        _apiService.getProjects(),
        _apiService.getEmployees(),
        _apiService.getPerformanceMetrics(),
        _apiService.getNotifications(),
      ]);

      _projects = List<Project>.from(results[0] as Iterable);
      _employees = List<Employee>.from(results[1] as Iterable);
      _performanceMetrics = List<PerformanceMetric>.from(results[2] as Iterable);
      _notifications = List<String>.from(results[3] as Iterable);
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
