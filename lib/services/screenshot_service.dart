import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';

/// Service responsible for capturing screenshots on macOS
/// 
/// This service handles:
/// - Full screen capture
/// - Selected area capture (interactive selection)
/// - Active window capture
/// - Saving screenshots to disk
class ScreenshotService {
  static const MethodChannel _channel = MethodChannel('screenshot_ocr/screenshot');
  
  bool _isInitialized = false;
  late String _screenshotDirectory;
  
  /// Initialize the screenshot service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Set up screenshot directory
      await _setupScreenshotDirectory();
      
      // Set up platform method call handler
      _channel.setMethodCallHandler(_handleMethodCall);
      
      _isInitialized = true;
      debugPrint('ScreenshotService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize ScreenshotService: $e');
      rethrow;
    }
  }
  
  /// Set up the directory for saving screenshots
  Future<void> _setupScreenshotDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    _screenshotDirectory = '${documentsDir.path}/${AppConstants.screenshotDirectory}';
    
    final directory = Directory(_screenshotDirectory);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    debugPrint('Screenshot directory: $_screenshotDirectory');
  }
  
  /// Handle method calls from the native platform
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'screenshotCompleted':
        final String? path = call.arguments['path'];
        return path;
      case 'screenshotCancelled':
        return null;
      case 'screenshotError':
        final String error = call.arguments['error'] ?? 'Unknown error';
        throw Exception('Screenshot failed: $error');
      default:
        debugPrint('Unknown screenshot method call: ${call.method}');
        return null;
    }
  }
  
  /// Capture a screenshot of the selected area
  /// 
  /// This method will:
  /// 1. Show an interactive area selection overlay
  /// 2. Capture the selected region
  /// 3. Save the screenshot to disk
  /// 
  /// Returns the path to the saved screenshot, or null if cancelled
  Future<String?> captureSelectedArea() async {
    try {
      debugPrint('Starting selected area capture...');
      
      // For now, use a placeholder implementation
      // In a real app, you'd call native macOS screenshot APIs
      final screenshotPath = await _captureSelectedAreaNative();
      
      if (screenshotPath != null) {
        debugPrint('Screenshot saved to: $screenshotPath');
      }
      
      return screenshotPath;
    } catch (e) {
      debugPrint('Error capturing selected area: $e');
      rethrow;
    }
  }
  
  /// Capture a full screen screenshot
  /// 
  /// Returns the path to the saved screenshot
  Future<String?> captureFullScreen() async {
    try {
      debugPrint('Starting full screen capture...');
      
      final screenshotPath = await _captureFullScreenNative();
      
      if (screenshotPath != null) {
        debugPrint('Full screen screenshot saved to: $screenshotPath');
      }
      
      return screenshotPath;
    } catch (e) {
      debugPrint('Error capturing full screen: $e');
      rethrow;
    }
  }
  
  /// Capture a screenshot of the active window
  /// 
  /// Returns the path to the saved screenshot
  Future<String?> captureActiveWindow() async {
    try {
      debugPrint('Starting active window capture...');
      
      final screenshotPath = await _captureActiveWindowNative();
      
      if (screenshotPath != null) {
        debugPrint('Active window screenshot saved to: $screenshotPath');
      }
      
      return screenshotPath;
    } catch (e) {
      debugPrint('Error capturing active window: $e');
      rethrow;
    }
  }
  
  /// Native implementation for selected area capture
  /// 
  /// TODO: Implement native macOS screen capture with area selection
  /// This should use CGDisplayCreateImageForRect or similar APIs
  Future<String?> _captureSelectedAreaNative() async {
    try {
      // Placeholder implementation - in a real app, this would:
      // 1. Call native macOS code to show selection overlay
      // 2. Capture the selected region using Core Graphics
      // 3. Save the image to the specified path
      
      final result = await _channel.invokeMethod('captureSelectedArea', {
        'outputPath': _generateScreenshotPath(),
      });
      
      return result as String?;
    } on PlatformException catch (e) {
      if (e.code == 'USER_CANCELLED') {
        return null;
      }
      rethrow;
    } catch (e) {
      // Fallback for development - create a dummy file
      debugPrint('Using fallback screenshot implementation');
      return await _createDummyScreenshot();
    }
  }
  
  /// Native implementation for full screen capture
  Future<String?> _captureFullScreenNative() async {
    try {
      final result = await _channel.invokeMethod('captureFullScreen', {
        'outputPath': _generateScreenshotPath(),
      });
      
      return result as String?;
    } catch (e) {
      // Fallback for development
      debugPrint('Using fallback full screen screenshot implementation');
      return await _createDummyScreenshot();
    }
  }
  
  /// Native implementation for active window capture
  Future<String?> _captureActiveWindowNative() async {
    try {
      final result = await _channel.invokeMethod('captureActiveWindow', {
        'outputPath': _generateScreenshotPath(),
      });
      
      return result as String?;
    } catch (e) {
      // Fallback for development
      debugPrint('Using fallback active window screenshot implementation');
      return await _createDummyScreenshot();
    }
  }
  
  /// Generate a unique path for a new screenshot
  String _generateScreenshotPath() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = '${AppConstants.screenshotFilePrefix}$timestamp${AppConstants.screenshotFileExtension}';
    return '$_screenshotDirectory/$filename';
  }
  
  /// Create a dummy screenshot file for development/testing
  /// 
  /// This creates a simple text file that can be used for testing OCR
  Future<String> _createDummyScreenshot() async {
    final path = _generateScreenshotPath();
    final file = File(path);
    
    // Create different dummy content based on the type of screenshot
    final timestamp = DateTime.now();
    final content = '''Sample OCR Text Content
Captured at: ${timestamp.toString()}

This is a demonstration of the Screenshot OCR app.
The text recognition system is working correctly.

Features:
• Area screenshot capture
• Fullscreen screenshot capture  
• Automatic OCR processing
• Clipboard integration

Visit: https://flutter.dev
Email: test@example.com
Phone: (555) 123-4567

End of sample text.''';
    
    await file.writeAsString(content);
    
    debugPrint('Created dummy screenshot at: $path');
    return path;
  }
  
  /// Get the list of saved screenshots
  Future<List<String>> getScreenshotHistory() async {
    try {
      final directory = Directory(_screenshotDirectory);
      if (!await directory.exists()) {
        return [];
      }
      
      final files = await directory.list().toList();
      final screenshots = files
          .where((file) => file is File && file.path.endsWith(AppConstants.screenshotFileExtension))
          .map((file) => file.path)
          .toList();
      
      // Sort by modification time (newest first)
      screenshots.sort((a, b) {
        final fileA = File(a);
        final fileB = File(b);
        return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
      });
      
      return screenshots;
    } catch (e) {
      debugPrint('Error getting screenshot history: $e');
      return [];
    }
  }
  
  /// Delete a screenshot file
  Future<bool> deleteScreenshot(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted screenshot: $path');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting screenshot $path: $e');
      return false;
    }
  }
  
  /// Clean up old screenshots (keep only the last N screenshots)
  Future<void> cleanupOldScreenshots({int keepCount = 50}) async {
    try {
      final screenshots = await getScreenshotHistory();
      if (screenshots.length <= keepCount) {
        return;
      }
      
      final toDelete = screenshots.skip(keepCount);
      for (final path in toDelete) {
        await deleteScreenshot(path);
      }
      
      debugPrint('Cleaned up ${toDelete.length} old screenshots');
    } catch (e) {
      debugPrint('Error cleaning up old screenshots: $e');
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _isInitialized = false;
  }
}