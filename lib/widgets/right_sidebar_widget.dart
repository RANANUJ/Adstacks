import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';

class RightSidebarWidget extends StatefulWidget {
  final bool isSidebar;

  const RightSidebarWidget({super.key, this.isSidebar = true});

  @override
  State<RightSidebarWidget> createState() => _RightSidebarWidgetState();
}

class _RightSidebarWidgetState extends State<RightSidebarWidget> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar Section Title
        const Text(
          'Office Calendar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Custom Calendar Card
        _buildCalendar(context, provider),

        const SizedBox(height: 16),

        // Selected Date Events list
        _buildSelectedEventsList(context, provider),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // Employee Birthdays / Anniversaries Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Occasions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Upcoming',
                style: TextStyle(
                  color: AppColors.primaryStart,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Birthday/Anniversary Occasions list
        _buildOccasionsList(context, provider),
      ],
    );

    if (widget.isSidebar) {
      return Container(
        width: 320,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.sidebarBg,
          border: Border(
            left: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: content,
        ),
      );
    } else {
      // Inlined in a scroll view (Mobile)
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: content,
      );
    }
  }

  Widget _buildCalendar(BuildContext context, DashboardProvider provider) {
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    // Calendar Grid Generation
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final prefixDaysCount = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final startGridDate = firstDayOfMonth.subtract(Duration(days: prefixDaysCount));
    
    final gridDates = List.generate(35, (index) => startGridDate.add(Duration(days: index)));

    final monthYearLabel = DateFormat('MMMM yyyy').format(_focusedMonth);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Month Scroll Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
              ),
              Text(
                monthYearLabel,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Days of the Week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((day) {
              return SizedBox(
                width: 24,
                child: Text(
                  day,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Date Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridDates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final cellDate = gridDates[index];
              final isCurrentMonth = cellDate.month == _focusedMonth.month;
              
              final isToday = cellDate.year == DateTime.now().year &&
                  cellDate.month == DateTime.now().month &&
                  cellDate.day == DateTime.now().day;
                  
              final isSelected = cellDate.year == provider.selectedDate.year &&
                  cellDate.month == provider.selectedDate.month &&
                  cellDate.day == provider.selectedDate.day;

              // Check if anyone has birthdays or work anniversaries on this day
              bool hasEvents = false;
              for (var emp in provider.employees) {
                if ((emp.birthday != null && emp.birthday!.month == cellDate.month && emp.birthday!.day == cellDate.day) ||
                    (emp.anniversary != null && emp.anniversary!.month == cellDate.month && emp.anniversary!.day == cellDate.day)) {
                  hasEvents = true;
                  break;
                }
              }

              return InkWell(
                onTap: () => provider.selectDate(cellDate),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryStart 
                        : (isToday ? AppColors.primaryStart.withOpacity(0.15) : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primaryStart.withOpacity(0.4))
                        : (isSelected ? Border.all(color: AppColors.primaryEnd) : null),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${cellDate.day}',
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : (isCurrentMonth ? AppColors.textPrimary : AppColors.textMuted),
                          fontSize: 12,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      // Dot indicator for events
                      if (hasEvents)
                        Positioned(
                          bottom: 3,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.secondaryStart,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedEventsList(BuildContext context, DashboardProvider provider) {
    final events = provider.getEventsForSelectedDate();
    final formattedDate = DateFormat('MMMM d').format(provider.selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.glassBg.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule for $formattedDate',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            const Text(
              'No company events or team occasions today.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            )
          else
            ...events.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildOccasionsList(BuildContext context, DashboardProvider provider) {
    final now = DateTime.now();
    // We look for any employee with birthdays or anniversaries in the current month
    final activeOccasions = <Map<String, dynamic>>[];

    for (var emp in provider.employees) {
      if (emp.birthday != null && emp.birthday!.month == now.month) {
        // Calculate relative offset of day
        final dayDiff = emp.birthday!.day - now.day;
        if (dayDiff >= -1 && dayDiff <= 7) { // within past day or next week
          activeOccasions.add({
            'employee': emp,
            'type': 'birthday',
            'diff': dayDiff,
            'date': emp.birthday!,
          });
        }
      }
      if (emp.anniversary != null && emp.anniversary!.month == now.month) {
        final dayDiff = emp.anniversary!.day - now.day;
        if (dayDiff >= -1 && dayDiff <= 7) {
          activeOccasions.add({
            'employee': emp,
            'type': 'anniversary',
            'diff': dayDiff,
            'date': emp.anniversary!,
          });
        }
      }
    }

    // Sort by day offset
    activeOccasions.sort((a, b) => (a['diff'] as int).compareTo(b['diff'] as int));

    if (activeOccasions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        alignment: Alignment.center,
        child: const Text(
          'No special occasions this week.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeOccasions.length,
      itemBuilder: (context, index) {
        final item = activeOccasions[index];
        final Employee emp = item['employee'];
        final String type = item['type'];
        final int diff = item['diff'];
        
        String timeLabel;
        if (diff == 0) {
          timeLabel = 'TODAY';
        } else if (diff == 1) {
          timeLabel = 'TOMORROW';
        } else if (diff == -1) {
          timeLabel = 'YESTERDAY';
        } else {
          timeLabel = 'IN $diff DAYS';
        }

        final bool isBirthday = type == 'birthday';
        final message = isBirthday 
            ? 'Birthday celebration!' 
            : 'Work Anniversary (${emp.yearsAtCompany} Years)';

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              // Event specific graphic / initial
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isBirthday ? AppColors.warningStart : AppColors.successStart,
                    width: 1.5,
                  ),
                  image: emp.avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(emp.avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: emp.avatarUrl.isEmpty
                    ? Center(
                        child: Text(
                          emp.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: isBirthday ? AppColors.warningStart : AppColors.successStart,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            emp.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: diff == 0 
                                ? (isBirthday ? AppColors.warningStart.withOpacity(0.2) : AppColors.successStart.withOpacity(0.2))
                                : AppColors.glassBorder,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            timeLabel,
                            style: TextStyle(
                              color: diff == 0 
                                  ? (isBirthday ? AppColors.warningStart : AppColors.successStart)
                                  : AppColors.textSecondary,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      emp.role,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: isBirthday ? AppColors.warningStart.withOpacity(0.9) : AppColors.successStart.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Wish interaction action button
              IconButton(
                icon: Icon(
                  isBirthday ? Icons.cake_rounded : Icons.celebration_rounded,
                  color: isBirthday ? AppColors.warningStart : AppColors.successStart,
                  size: 20,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.bgEnd,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.successStart),
                          const SizedBox(width: 8),
                          Text(
                            'Wishes sent to ${emp.name}! 🎉',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
