/// Centralized layout breakpoints, content constraints, and touch target tokens.
abstract class LayoutTokens {
  // Breakpoints
  static const double breakpointCompact = 600.0;
  static const double breakpointMedium = 840.0;

  // Max readable content width on large screens
  static const double maxContentWidth = 680.0;
  static const double maxDialogWidth = 480.0;

  // Touch Target Policy (WCAG 2.1 AA)
  static const double minTouchTargetSize = 48.0;

  // Toolbar & App Bar
  static const double toolbarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
}
