/// Application constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'Screenshot OCR';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Quick screenshot capture with OCR text extraction';
  
  // Menu Bar Configuration
  static const String menuBarIconPath = 'assets/icons/menu_icon.png';
  static const String menuBarTooltip = 'Screenshot OCR';
  
  // Screenshot Configuration
  static const String screenshotDirectory = 'Screenshots';
  static const String screenshotFilePrefix = 'screenshot_';
  static const String screenshotFileExtension = '.png';
  
  // OCR Configuration
  static const double ocrConfidenceThreshold = 0.7;
  static const int maxOcrProcessingTime = 30; // seconds
  
  // UI Configuration
  static const double menuWidth = 200.0;
  static const double menuItemHeight = 40.0;
  static const double menuPadding = 8.0;
  
  // Error Messages
  static const String errorScreenshotFailed = 'Failed to capture screenshot';
  static const String errorOcrFailed = 'Failed to extract text from image';
  static const String errorClipboardFailed = 'Failed to copy text to clipboard';
  static const String errorPermissionDenied = 'Permission denied for screen capture';
  
  // Success Messages
  static const String successTextCopied = 'Text copied to clipboard';
  static const String successScreenshotSaved = 'Screenshot saved';
}

/// Menu item identifiers for the menu bar
enum MenuAction {
  takeScreenshot,
  viewHistory,
  settings,
  about,
  quit,
}

/// Screenshot capture modes
enum ScreenshotMode {
  fullScreen,
  selectedArea,
  activeWindow,
}

/// OCR processing status
enum OcrStatus {
  idle,
  processing,
  completed,
  failed,
}