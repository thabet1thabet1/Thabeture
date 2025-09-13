# Screenshot Service for macOS Flutter App

This document explains how to set up and use the `ScreenshotService` in your macOS Flutter menu bar app.

## Features

The `ScreenshotService` provides three main screenshot capture methods:

- **Full Screen Capture**: Captures the entire screen
- **Active Window Capture**: User clicks on a window to capture it
- **Selected Area Capture**: User drags to select an area to capture

## macOS Permissions Setup

### Required: Screen Recording Permission

For macOS 10.15 (Catalina) and later, your app needs screen recording permission.

#### 1. Update Info.plist

Add the following to your `macos/Runner/Info.plist` file:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs screen recording permission to capture screenshots for OCR processing.</string>
```

#### 2. User Permission Grant

Users must manually grant permission in:
**System Preferences > Security & Privacy > Privacy > Screen Recording**

1. Click the lock icon and enter admin password
2. Check the box next to your app name
3. Restart your app

### Permission Checking

Use the built-in permission check:

```dart
final screenshotService = ScreenshotService.instance;
final hasPermission = await screenshotService.hasScreenRecordingPermission();

if (!hasPermission) {
  // Show user instructions to grant permission
  print('Please grant screen recording permission in System Preferences');
}
```

## Usage Examples

### Basic Screenshot Capture

```dart
import 'package:your_app/services/screenshot_service.dart';

final screenshotService = ScreenshotService.instance;

// Capture full screen
final fullScreenPath = await screenshotService.captureFullScreen();

// Capture selected area (user drags to select)
final areaPath = await screenshotService.captureSelectedArea();

// Capture active window (user clicks on window)
final windowPath = await screenshotService.captureActiveWindow();

// All methods return null if capture fails or user cancels
if (fullScreenPath != null) {
  print('Screenshot saved to: $fullScreenPath');
  // Process the screenshot file (OCR, display, etc.)
}
```

### File Management

```dart
// Get recent screenshots
final recentFiles = await screenshotService.getRecentScreenshots(limit: 10);

// Clean up old screenshots (keep only last 20)
await screenshotService.cleanupOldScreenshots(keepCount: 20);

// Delete specific screenshot
await screenshotService.deleteScreenshot('/path/to/screenshot.png');
```

## File Storage

Screenshots are automatically saved to:
- **Location**: System temporary directory (`/tmp/screenshots/`)
- **Naming**: `screenshot_[timestamp].png`
- **Format**: PNG files

Example path: `/tmp/screenshots/screenshot_1694123456789.png`

## Error Handling

All methods return `null` if they fail. Common failure reasons:

- **Permission denied**: User hasn't granted screen recording permission
- **User cancelled**: User pressed ESC during area/window selection
- **System error**: macOS screencapture command failed

```dart
final screenshotPath = await screenshotService.captureSelectedArea();

if (screenshotPath == null) {
  // Handle failure - could be permission, cancellation, or system error
  // Check logs for specific error details
}
```

## Integration with OCR

Typical workflow for OCR processing:

```dart
// 1. Capture screenshot
final screenshotPath = await screenshotService.captureSelectedArea();
if (screenshotPath == null) return;

// 2. Process with OCR service
final ocrService = OcrService();
final extractedText = await ocrService.extractTextFromImage(screenshotPath);

// 3. Copy to clipboard
final clipboardService = ClipboardService();
await clipboardService.copyToClipboard(extractedText);

// 4. Clean up (optional)
await screenshotService.deleteScreenshot(screenshotPath);
```

## Troubleshooting

### "Permission denied" errors
- Ensure screen recording permission is granted in System Preferences
- Restart the app after granting permission
- Check that your Info.plist includes the usage description

### Screenshots not working
- Test permission with `hasScreenRecordingPermission()`
- Check Console.app for error messages from your app
- Verify macOS version (10.15+ required for permission system)

### Empty or corrupted files
- Check available disk space in `/tmp`
- Ensure the screencapture command is available: `which screencapture`
- Test manually in Terminal: `screencapture -x test.png`

## Advanced Usage

### Custom Screenshot Directory

The service uses the system temp directory by default. To use a custom directory, you can modify the `_generateScreenshotPath()` method in the service.

### Native Plugin Alternative

For more advanced features (like real-time area selection overlay), consider using:

- `desktop_screenshot` package
- `screen_retriever` package  
- Custom native macOS implementation with method channels

Add to `pubspec.yaml`:
```yaml
dependencies:
  desktop_screenshot: ^0.1.0
  screen_retriever: ^0.1.9
```

## Implementation Notes

- Uses macOS `screencapture` command-line tool (most reliable method)
- No external dependencies required for basic functionality
- Singleton pattern for service instance
- Automatic cleanup of old files
- Comprehensive error logging

## Security Considerations

- Screenshots are stored in temp directory (cleared on system restart)
- No network transmission of screenshot data
- User has full control over what gets captured
- Permission system prevents unauthorized screen access