import 'package:flutter/foundation.dart';
import 'screenshot_service.dart';

/// Example usage of the ScreenshotService
/// 
/// This file demonstrates how to use the screenshot service in your app.
/// You can delete this file once you understand how to integrate the service.
class ScreenshotServiceExample {
  
  /// Example: Capture full screen screenshot
  static Future<void> exampleFullScreenCapture() async {
    final screenshotService = ScreenshotService.instance;
    
    debugPrint('Starting full screen capture example...');
    
    final filePath = await screenshotService.captureFullScreen();
    
    if (filePath != null) {
      debugPrint('✅ Full screen screenshot saved to: $filePath');
      // You can now process this file (e.g., OCR, display, etc.)
    } else {
      debugPrint('❌ Full screen capture failed or was cancelled');
    }
  }
  
  /// Example: Capture selected area screenshot
  static Future<void> exampleAreaCapture() async {
    final screenshotService = ScreenshotService.instance;
    
    debugPrint('Starting area capture example...');
    debugPrint('User will see crosshair cursor - drag to select area or press ESC to cancel');
    
    final filePath = await screenshotService.captureSelectedArea();
    
    if (filePath != null) {
      debugPrint('✅ Area screenshot saved to: $filePath');
      // You can now process this file (e.g., OCR, display, etc.)
    } else {
      debugPrint('❌ Area capture failed or was cancelled by user');
    }
  }
  
  /// Example: Capture active window screenshot
  static Future<void> exampleWindowCapture() async {
    final screenshotService = ScreenshotService.instance;
    
    debugPrint('Starting window capture example...');
    debugPrint('User will see crosshair cursor - click on window to capture');
    
    final filePath = await screenshotService.captureActiveWindow();
    
    if (filePath != null) {
      debugPrint('✅ Window screenshot saved to: $filePath');
      // You can now process this file (e.g., OCR, display, etc.)
    } else {
      debugPrint('❌ Window capture failed or was cancelled by user');
    }
  }
  
  /// Example: Check screen recording permissions
  static Future<void> examplePermissionCheck() async {
    final screenshotService = ScreenshotService.instance;
    
    debugPrint('Checking screen recording permissions...');
    
    final hasPermission = await screenshotService.hasScreenRecordingPermission();
    
    if (hasPermission) {
      debugPrint('✅ Screen recording permission granted');
    } else {
      debugPrint('❌ Screen recording permission denied');
      debugPrint('Please grant permission in System Preferences > Security & Privacy > Privacy > Screen Recording');
    }
  }
  
  /// Example: Get recent screenshots
  static Future<void> exampleGetRecentScreenshots() async {
    final screenshotService = ScreenshotService.instance;
    
    debugPrint('Getting recent screenshots...');
    
    final recentFiles = await screenshotService.getRecentScreenshots(limit: 5);
    
    if (recentFiles.isNotEmpty) {
      debugPrint('✅ Found ${recentFiles.length} recent screenshots:');
      for (int i = 0; i < recentFiles.length; i++) {
        debugPrint('  ${i + 1}. ${recentFiles[i]}');
      }
    } else {
      debugPrint('ℹ️ No recent screenshots found');
    }
  }
  
  /// Example: Clean up old screenshots
  static Future<void> exampleCleanup() async {
    final screenshotService = ScreenshotService.instance;
    
    debugPrint('Cleaning up old screenshots (keeping last 10)...');
    
    await screenshotService.cleanupOldScreenshots(keepCount: 10);
    
    debugPrint('✅ Cleanup completed');
  }
  
  /// Complete workflow example: Capture, check, and cleanup
  static Future<void> exampleCompleteWorkflow() async {
    final screenshotService = ScreenshotService.instance;
    
    // 1. Check permissions first
    debugPrint('=== Complete Screenshot Workflow Example ===');
    
    final hasPermission = await screenshotService.hasScreenRecordingPermission();
    if (!hasPermission) {
      debugPrint('❌ No screen recording permission - workflow stopped');
      return;
    }
    
    // 2. Capture a screenshot (area selection)
    debugPrint('Step 1: Capturing area screenshot...');
    final filePath = await screenshotService.captureSelectedArea();
    
    if (filePath == null) {
      debugPrint('❌ Screenshot cancelled - workflow stopped');
      return;
    }
    
    debugPrint('✅ Screenshot captured: $filePath');
    
    // 3. Show recent screenshots
    debugPrint('Step 2: Checking recent screenshots...');
    final recentFiles = await screenshotService.getRecentScreenshots();
    debugPrint('Found ${recentFiles.length} recent screenshots');
    
    // 4. Clean up if we have too many
    if (recentFiles.length > 15) {
      debugPrint('Step 3: Cleaning up old screenshots...');
      await screenshotService.cleanupOldScreenshots(keepCount: 10);
    }
    
    debugPrint('=== Workflow completed successfully ===');
  }
}