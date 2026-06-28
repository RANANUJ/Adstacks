import 'package:flutter/material.dart';

class AppColors {
  // Deep Backgrounds
  static const Color bgStart = Color(0xFF0D1117);
  static const Color bgEnd = Color(0xFF161B22);
  
  // Glassmorphic Panel Colors
  static const Color glassBg = Color(0x0AFFFFFF); // Frosted overlay (4%)
  static const Color glassBorder = Color(0x1AFFFFFF); // Translucent borders (10%)
  static const Color glassShadow = Color(0x33000000); // Shadow for cards (20%)
  
  static const Color sidebarBg = Color(0x22161B22); // Sidebar backdrop
  static const Color topBarBg = Color(0x110D1117); // Topbar backdrop

  // Neon Gradient Accents
  // Purple (Primary Actions)
  static const Color primaryStart = Color(0xFF8B5CF6);
  static const Color primaryEnd = Color(0xFFD946EF);
  
  // Cyan (Projects, Tech info)
  static const Color secondaryStart = Color(0xFF06B6D4);
  static const Color secondaryEnd = Color(0xFF3B82F6);
  
  // Emerald Green (Success, Completed)
  static const Color successStart = Color(0xFF10B981);
  static const Color successEnd = Color(0xFF059669);
  
  // Amber Orange (Delayed, Important Warnings)
  static const Color warningStart = Color(0xFFF59E0B);
  static const Color warningEnd = Color(0xFFD97706);

  // Crimson Red (Danger, Urgent alerts)
  static const Color errorStart = Color(0xFFEF4444);
  static const Color errorEnd = Color(0xFFDC2626);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondary = Color(0xFF94A3B8); // Muted slate-blue
  static const Color textMuted = Color(0xFF64748B); // Slate gray

  // Card Overlays
  static const Color cardHighlight = Color(0x1FFFFFFF); // 12% white for hover/selection
}
