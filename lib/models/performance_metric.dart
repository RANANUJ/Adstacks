class PerformanceMetric {
  final String label; // e.g. "Jan", "Feb" or "Week 1", "Week 2"
  final double rating; // e.g. percentage or rating out of 100
  final int completedTasks;
  final int activeProjects;

  const PerformanceMetric({
    required this.label,
    required this.rating,
    required this.completedTasks,
    required this.activeProjects,
  });
}
