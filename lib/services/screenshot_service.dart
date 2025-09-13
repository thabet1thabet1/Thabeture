import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service responsible for capturing screenshots on macOS
/// 
/// IMPORTANT: macOS Screen Recording Permissions Required
/// Add the following to your macos/Runner/Info.plist:
/// 
/// <key>NSCameraUsageDescription</key>
/// <string>This app needs screen recording permission to capture screenshots for OCR processing.</string>
/// 
/// For macOS 10.15+ (Catalina and later), users must grant screen recording 
/// permission in System Preferences > Security & Privacy > Privacy > Screen Recording
class ScreenshotService {
  static ScreenshotService? _instance;
  static ScreenshotService get instance => _instance ??= ScreenshotService._();
  
  ScreenshotService._();
  
  /// Capture the entire screen and return the local PNG file path
  /// 
  /// Uses the native macOS screencapture command to capture the full screen.
  /// Returns null if capture fails or user cancels.
  Future<String?> captureFullScreen() async {
    try {
      debugPrint('ScreenshotService: Starting full screen capture...');
      
      final filePath = await _generateScreenshotPath();
      
      final result = await Process.run('screencapture', [
        '-x', // Don't play camera sound
        '-t', 'png', // PNG format
        filePath, // Output file path
      ]);
      
      if (result.exitCode == 0) {
        if (await _validateScreenshotFile(filePath)) {
          debugPrint('ScreenshotService: Full screen captured successfully: $filePath');
          return filePath;
        }
      }
      
      debugPrint('ScreenshotService: Full screen capture failed - exit code: ${result.exitCode}');
      if (result.stderr.toString().isNotEmpty) {
        debugPrint('ScreenshotService: stderr: ${result.stderr}');
      }
      return null;
      
    } catch (e) {
      debugPrint('ScreenshotService: Error capturing full screen: $e');
      return null;
    }
  }
  
  /// Capture the currently active window and return the local PNG file path
  /// 
  /// Uses screencapture -w flag. User clicks on the window they want to capture.
  /// Returns null if capture fails or user cancels.
  Future<String?> captureActiveWindow() async {
    try {
      debugPrint('ScreenshotService: Starting active window capture...');
      
      final filePath = await _generateScreenshotPath();
      
      final result = await Process.run('screencapture', [
        '-x', // Don't play camera sound
        '-w', // Capture window (user selects by clicking)
        '-t', 'png', // PNG format
        filePath, // Output file path
      ]);
      
      if (result.exitCode == 0) {
        if (await _validateScreenshotFile(filePath)) {
          debugPrint('ScreenshotService: Active window captured successfully: $filePath');
          return filePath;
        }
      }
      
      if (result.exitCode == 1) {
        debugPrint('ScreenshotService: Window capture cancelled by user');
        return null;
      }
      
      debugPrint('ScreenshotService: Active window capture failed - exit code: ${result.exitCode}');
      if (result.stderr.toString().isNotEmpty) {
        debugPrint('ScreenshotService: stderr: ${result.stderr}');
      }
      return null;
      
    } catch (e) {
      debugPrint('ScreenshotService: Error capturing active window: $e');
      return null;
    }
  }
  
  /// Allow user to select an area and capture it
  /// 
  /// Uses screencapture -i flag for interactive area selection.
  /// User can drag to select area, press space to capture window, or ESC to cancel.
  /// Returns null if capture fails or user cancels.
  Future<String?> captureSelectedArea() async {
    try {
      debugPrint('ScreenshotService: Starting selected area capture...');
      
      final filePath = await _generateScreenshotPath();
      
      final result = await Process.run('screencapture', [
        '-x', // Don't play camera sound
        '-i', // Interactive selection mode
        '-t', 'png', // PNG format
        filePath, // Output file path
      ]);
      
      if (result.exitCode == 0) {
        if (await _validateScreenshotFile(filePath)) {
          debugPrint('ScreenshotService: Selected area captured successfully: $filePath');
          return filePath;
        }
      }
      
      if (result.exitCode == 1) {
        debugPrint('ScreenshotService: Area selection cancelled by user');
        return null;
      }
      
      debugPrint('ScreenshotService: Selected area capture failed - exit code: ${result.exitCode}');
      if (result.stderr.toString().isNotEmpty) {
        debugPrint('ScreenshotService: stderr: ${result.stderr}');
      }
      return null;
      
    } catch (e) {
      debugPrint('ScreenshotService: Error capturing selected area: $e');
      return null;
    }
  }
  
  /// Generate a unique file path for saving screenshots
  /// 
  /// Screenshots are saved to the system temporary directory with timestamp-based filenames
  /// Format: screenshot_[timestamp].png
  Future<String> _generateScreenshotPath() async {
    try {
      final tempDir = await getTemporaryDirectory();
      
      final screenshotsDir = Directory('${tempDir.path}/screenshots');
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'screenshot_$timestamp.png';
      
      return '${screenshotsDir.path}/$filename';
      
    } catch (e) {
      debugPrint('ScreenshotService: Error generating screenshot path: $e');
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '${tempDir.path}/screenshot_$timestamp.png';
    }
  }
  
  /// Validate that a screenshot file exists and is not empty
  /// 
  /// Returns true if file exists and has content, false otherwise
  Future<bool> _validateScreenshotFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 0) {
          return true;
        } else {
          debugPrint('ScreenshotService: Screenshot file is empty: $filePath');
        }
      } else {
        debugPrint('ScreenshotService: Screenshot file does not exist: $filePath');
      }
      return false;
    } catch (e) {
      debugPrint('ScreenshotService: Error validating screenshot file $filePath: $e');
      return false;
    }
  }
  
  /// Check if screen recording permission is granted (macOS 10.15+)
  /// 
  /// TODO: Implement native permission check using method channels for more accurate results.
  /// This is a basic implementation that attempts a small screenshot to test permissions.
  Future<bool> hasScreenRecordingPermission() async {
    try {
      final tempPath = '${(await getTemporaryDirectory()).path}/permission_test.png';
      
      final result = await Process.run('screencapture', [
        '-x',
        '-R', '0,0,1,1', // Capture 1x1 pixel at origin
        '-t', 'png',
        tempPath,
      ]);
      
      // Clean up test file
      try {
        final testFile = File(tempPath);
        if (await testFile.exists()) {
          await testFile.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
      
      return result.exitCode == 0;
      
    } catch (e) {
      debugPrint('ScreenshotService: Error checking screen recording permission: $e');
      return false;
    }
  }
  
  /// Get list of recent screenshot files from temp directory
  /// 
  /// Returns paths to screenshot files, sorted by creation time (newest first).
  /// Limited to the specified number of files.
  Future<List<String>> getRecentScreenshots({int limit = 10}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final screenshotsDir = Directory('${tempDir.path}/screenshots');
      
      if (!await screenshotsDir.exists()) {
        return [];
      }
      
      final files = await screenshotsDir
          .list()
          .where((entity) => 
              entity is File && 
              entity.path.endsWith('.png') &&
              entity.path.contains('screenshot_'))
          .cast<File>()
          .toList();
      
      // Sort by modification time (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return files.take(limit).map((f) => f.path).toList();
      
    } catch (e) {
      debugPrint('ScreenshotService: Error getting recent screenshots: $e');
      return [];
    }
  }
  
  /// Delete a screenshot file
  /// 
  /// Returns true if file was successfully deleted, false otherwise
  Future<bool> deleteScreenshot(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('ScreenshotService: Deleted screenshot: $filePath');
        return true;
      } else {
        debugPrint('ScreenshotService: Screenshot file not found for deletion: $filePath');
        return false;
      }
    } catch (e) {
      debugPrint('ScreenshotService: Error deleting screenshot $filePath: $e');
      return false;
    }
  }
  
  /// Clean up old screenshot files from temp directory
  /// 
  /// Keeps only the most recent [keepCount] files and deletes the rest.
  /// This helps manage disk space by removing old screenshots.
  Future<void> cleanupOldScreenshots({int keepCount = 20}) async {
    try {
      final allFiles = await getRecentScreenshots(limit: 1000); // Get all files
      
      if (allFiles.length <= keepCount) {
        debugPrint('ScreenshotService: No cleanup needed - ${allFiles.length} files (limit: $keepCount)');
        return;
      }
      
      final filesToDelete = allFiles.skip(keepCount);
      int deletedCount = 0;
      
      for (final filePath in filesToDelete) {
        if (await deleteScreenshot(filePath)) {
          deletedCount++;
        }
      }
      
      debugPrint('ScreenshotService: Cleaned up $deletedCount old screenshot files (kept $keepCount)');
      
    } catch (e) {
      debugPrint('ScreenshotService: Error during cleanup: $e');
    }
  }
}