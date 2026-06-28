import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../models/project.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';

class AdminDialogs {
  /// Show Dialog to Add or Edit a Project
  static void showProjectDialog(BuildContext context, {Project? project}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _ProjectFormDialog(project: project),
    );
  }

  /// Show Dialog to Add or Edit an Employee
  static void showEmployeeDialog(BuildContext context, {Employee? employee}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _EmployeeFormDialog(employee: employee),
    );
  }

  /// Show Dialog to Broadcast a Global Announcement
  static void showAnnouncementDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => const _AnnouncementDialog(),
    );
  }
}

// ----------------------------------------------------
// Project Form Dialog Implementation (Supports Add/Edit)
// ----------------------------------------------------
class _ProjectFormDialog extends StatefulWidget {
  final Project? project;
  const _ProjectFormDialog({this.project});

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  String _category = 'Flutter Dev';
  ProjectStatus _status = ProjectStatus.notStarted;
  double _progress = 0.0;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  
  final List<String> _selectedEmployeeIds = [];

  final List<String> _categories = [
    'Flutter Dev',
    'UI/UX Design',
    'Backend',
    'Marketing',
    'Operations',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    
    if (p != null) {
      _category = _categories.contains(p.category) ? p.category : _categories.first;
      _status = p.status;
      _progress = p.progress;
      _deadline = p.deadline;
      _selectedEmployeeIds.addAll(p.assignees.map((e) => e.id));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final allEmployees = provider.employees;
    final isEditing = widget.project != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.bgEnd,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 20,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Project Details' : 'Onboard New Project',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Dialog Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text('Project Title', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration('Enter project name...'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Project title is required' : null,
                      ),
                      
                      const SizedBox(height: 16),

                      // Description
                      const Text('Description', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration('Enter summary or goals...'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                      ),

                      const SizedBox(height: 16),

                      // Category and Status row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Category', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: _buildDropdownDecoration(),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _category,
                                      dropdownColor: AppColors.bgEnd,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                      items: _categories.map((c) {
                                        return DropdownMenuItem(value: c, child: Text(c));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _category = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: _buildDropdownDecoration(),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<ProjectStatus>(
                                      value: _status,
                                      dropdownColor: AppColors.bgEnd,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                      items: ProjectStatus.values.map((status) {
                                        String label = 'Not Started';
                                        if (status == ProjectStatus.inProgress) label = 'In Progress';
                                        if (status == ProjectStatus.completed) label = 'Completed';
                                        if (status == ProjectStatus.delayed) label = 'Delayed';
                                        return DropdownMenuItem(value: status, child: Text(label));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _status = val;
                                            if (val == ProjectStatus.completed) {
                                              _progress = 1.0;
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Progress Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Development Progress', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('${(_progress * 100).toInt()}%', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Slider(
                        value: _progress,
                        min: 0.0,
                        max: 1.0,
                        activeColor: AppColors.primaryStart,
                        inactiveColor: AppColors.glassBorder,
                        onChanged: _status == ProjectStatus.completed 
                            ? null // Fixed to 100% if completed
                            : (val) => setState(() => _progress = val),
                      ),

                      const SizedBox(height: 16),

                      // Deadline Date Picker
                      const Text('Deadline', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _deadline,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.primaryStart,
                                    onPrimary: Colors.white,
                                    surface: AppColors.bgEnd,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => _deadline = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.glassBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM dd, yyyy').format(_deadline),
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                              ),
                              const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 18),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Project Assignees Checklist
                      const Text('Assign Team Members', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 8),
                      if (allEmployees.isEmpty)
                        const Text('No employees found. Onboard staff first.', style: TextStyle(color: Colors.redAccent, fontSize: 12))
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.glassBorder),
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.glassBg.withOpacity(0.02),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: allEmployees.length,
                            itemBuilder: (context, index) {
                              final emp = allEmployees[index];
                              final isChecked = _selectedEmployeeIds.contains(emp.id);

                              return CheckboxListTile(
                                value: isChecked,
                                title: Text(emp.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                subtitle: Text(emp.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                activeColor: AppColors.primaryStart,
                                checkColor: Colors.white,
                                controlAffinity: ListTileControlAffinity.trailing,
                                dense: true,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedEmployeeIds.add(emp.id);
                                    } else {
                                      _selectedEmployeeIds.remove(emp.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Dialog Footer Button Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                   ElevatedButton(
                    onPressed: () {
                      try {
                        if (_formKey.currentState!.validate()) {
                          final chosenAssignees = allEmployees.where((e) => _selectedEmployeeIds.contains(e.id)).toList();
                          
                          if (isEditing) {
                            final updated = Project(
                              id: widget.project!.id,
                              title: _titleController.text.trim(),
                              description: _descController.text.trim(),
                              progress: _progress,
                              status: _status,
                              assignees: chosenAssignees,
                              deadline: _deadline,
                              category: _category,
                            );
                            provider.updateProject(updated);
                            provider.addNotification('Project "${updated.title}" updated by Admin.');
                          } else {
                            final newProj = Project(
                              id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                              title: _titleController.text.trim(),
                              description: _descController.text.trim(),
                              progress: _progress,
                              status: _status,
                              assignees: chosenAssignees,
                              deadline: _deadline,
                              category: _category,
                            );
                            provider.addProject(newProj);
                            provider.addNotification('New Project "${newProj.title}" onboarded by Admin.');
                          }
                          
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Project updated successfully!' : 'New project added!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e, stack) {
                        debugPrint('Error saving project: $e');
                        debugPrint(stack.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving project changes: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryStart,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(isEditing ? 'Save Changes' : 'Create Project'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      fillColor: AppColors.glassBg,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryStart),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  BoxDecoration _buildDropdownDecoration() {
    return BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.glassBorder),
    );
  }
}

// ----------------------------------------------------
// Employee Form Dialog Implementation (Supports Add/Edit)
// ----------------------------------------------------
class _EmployeeFormDialog extends StatefulWidget {
  final Employee? employee;
  const _EmployeeFormDialog({this.employee});

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;
  late TextEditingController _yearsController;
  
  DateTime? _birthday;
  DateTime? _anniversary;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameController = TextEditingController(text: e?.name ?? '');
    _roleController = TextEditingController(text: e?.role ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _yearsController = TextEditingController(text: e?.yearsAtCompany != null ? '${e!.yearsAtCompany}' : '1');
    _birthday = e?.birthday;
    _anniversary = e?.anniversary;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final isEditing = widget.employee != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: AppColors.bgEnd,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Update Profile' : 'Onboard Employee',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      const Text('Full Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration('Enter full name...'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                      ),

                      const SizedBox(height: 16),

                      // Role
                      const Text('Designation / Role', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _roleController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration('e.g. Flutter Dev, Designer...'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Role is required' : null,
                      ),

                      const SizedBox(height: 16),

                      // Email
                      const Text('Work Email', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration('e.g. employee@adstacks.com'),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email is required';
                          if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email address';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Years at company
                      const Text('Tenure (Years at Company)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: _buildInputDecoration('e.g. 2'),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Tenure value required';
                          if (int.tryParse(val) == null) return 'Must be a valid integer';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Date of Birth pick
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date of Birth', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _birthday ?? DateTime(1995, 1, 1),
                                      firstDate: DateTime(1960),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) setState(() => _birthday = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _birthday == null ? 'Select Date' : DateFormat('MM/dd').format(_birthday!),
                                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                        ),
                                        const Icon(Icons.cake_rounded, color: AppColors.textMuted, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Join Anniversary', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _anniversary ?? DateTime.now(),
                                      firstDate: DateTime(2010),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) setState(() => _anniversary = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _anniversary == null ? 'Select Date' : DateFormat('MM/dd').format(_anniversary!),
                                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                        ),
                                        const Icon(Icons.celebration_rounded, color: AppColors.textMuted, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        if (_formKey.currentState!.validate()) {
                          final tenure = int.parse(_yearsController.text);
                          
                          if (isEditing) {
                            final updated = Employee(
                              id: widget.employee!.id,
                              name: _nameController.text.trim(),
                              role: _roleController.text.trim(),
                              email: _emailController.text.trim(),
                              avatarUrl: widget.employee!.avatarUrl, // preserve original avatar
                              birthday: _birthday,
                              anniversary: _anniversary,
                              yearsAtCompany: tenure,
                            );
                            provider.updateEmployee(updated);
                            provider.addNotification('Employee profile for "${updated.name}" updated by Admin.');
                          } else {
                            final newEmp = Employee(
                              id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
                              name: _nameController.text.trim(),
                              role: _roleController.text.trim(),
                              email: _emailController.text.trim(),
                              avatarUrl: '', // blank leads to initials fallback
                              birthday: _birthday,
                              anniversary: _anniversary,
                              yearsAtCompany: tenure,
                            );
                            provider.addEmployee(newEmp);
                            provider.addNotification('New Staff member "${newEmp.name}" onboarded.');
                          }
                          
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Profile updated successfully!' : 'Staff member onboarded!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e, stack) {
                        debugPrint('Error saving employee: $e');
                        debugPrint(stack.toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving staff changes: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryStart,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(isEditing ? 'Save Profile' : 'Onboard Employee'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      fillColor: AppColors.glassBg,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryStart),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// ----------------------------------------------------
// Announcement Broadcaster Dialog Implementation
// ----------------------------------------------------
class _AnnouncementDialog extends StatefulWidget {
  const _AnnouncementDialog();

  @override
  State<_AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<_AnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgEnd,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Broadcast Alert',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Announcement Message', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _controller,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type announcement content for staff members...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  fillColor: AppColors.glassBg,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryStart)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Alert message cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.campaign_rounded, size: 16),
                    label: const Text('Broadcast'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        provider.addNotification(_controller.text.trim());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Announcement broadcasted to all channels!'),
                            backgroundColor: AppColors.primaryStart,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryStart,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
