import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_tray/system_tray.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/constants.dart';
import 'screenshot_service.dart';
import 'ocr_service.dart';
import 'clipboard_service.dart';
import '../ui/menu_bar_menu.dart';

/// Service responsible for managing the macOS menu bar integration
/// 
/// This service handles:
/// - Creating and managing the menu bar icon
/// - Showing the context menu when clicked
/// - Coordinating between screenshot, OCR, and clipboard services
class MenuBarService {
  static final MenuBarService _instance = MenuBarService._internal();
  factory MenuBarService() => _instance;
  MenuBarService._internal();

  // Service dependencies
  late final ClipboardService _clipboardService;
  
  // System tray instance
  final SystemTray _systemTray = SystemTray();
  
  bool _isInitialized = false;
  
  /// Initialize the menu bar service and all dependencies
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize service dependencies using singletons
      _clipboardService = ClipboardService();
      await _clipboardService.initialize();
      
      // Start OCR service automatically
      await _startOcrService();
      
      // Initialize system tray
      await _initializeSystemTray();
      
      _isInitialized = true;
      debugPrint('MenuBarService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize MenuBarService: $e');
      rethrow;
    }
  }
  
  /// Check if OCR service is running, if not show helpful message
  Future<void> _startOcrService() async {
    try {
      debugPrint('MenuBarService: Checking OCR service status...');
      
      // Check if OCR service is already running
      final flagFile = File('/tmp/ocr_service_running.flag');
      if (await flagFile.exists()) {
        debugPrint('MenuBarService: ✅ OCR service already running');
        return;
      }
      
      debugPrint('MenuBarService: ⚠️ OCR service not running');
      debugPrint('MenuBarService: To enable automatic OCR, run: python3 ~/ocr_service.py &');
      
    } catch (e) {
      debugPrint('MenuBarService: Error checking OCR service: $e');
    }
  }
  
  /// Initialize the system tray with menu items
  Future<void> _initializeSystemTray() async {
    try {
      // Initialize system tray with a camera icon
      await _systemTray.initSystemTray(
        title: "📷",
        iconPath: "",
        toolTip: AppConstants.menuBarTooltip,
      );

      // Create menu items
      final Menu menu = Menu();
      
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Take Area Screenshot',
          onClicked: (menuItem) {
            debugPrint('Menu: Take Area Screenshot clicked');
            _handleMenuAction('takeAreaScreenshot');
          },
        ),
        MenuItemLabel(
          label: 'Take Fullscreen Screenshot', 
          onClicked: (menuItem) {
            debugPrint('Menu: Take Fullscreen Screenshot clicked');
            _handleMenuAction('takeFullscreenScreenshot');
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'View History',
          onClicked: (menuItem) {
            debugPrint('Menu: View History clicked');
            _handleMenuAction('viewHistory');
          },
        ),
        MenuItemLabel(
          label: 'Settings',
          onClicked: (menuItem) {
            debugPrint('Menu: Settings clicked');
            _handleMenuAction('settings');
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Quit',
          onClicked: (menuItem) {
            debugPrint('Menu: Quit clicked');
            _handleMenuAction('quit');
          },
        ),
      ]);

      // Set the menu
      await _systemTray.setContextMenu(menu);

      // Register click handler
      _systemTray.registerSystemTrayEventHandler((eventName) {
        debugPrint("System tray event: $eventName");
        if (eventName == kSystemTrayEventClick) {
          debugPrint("System tray left clicked - showing menu");
          // Show context menu on left click
          _systemTray.popUpContextMenu();
        } else if (eventName == kSystemTrayEventRightClick) {
          debugPrint("System tray right clicked - showing menu");
          // Context menu will show automatically on right click
        }
      });

      debugPrint('System tray initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize system tray: $e');
      rethrow;
    }
  }
  
  /// Update system tray tooltip with status
  Future<void> _updateTrayTooltip(String status) async {
    try {
      await _systemTray.setToolTip('Screenshot OCR - $status');
    } catch (e) {
      debugPrint('Failed to update tray tooltip: $e');
    }
  }
  
  /// Handle menu action selection
  Future<void> _handleMenuAction(String action) async {
    try {
      debugPrint('Menu action selected: $action');
      
      switch (action) {
        case 'takeAreaScreenshot':
          await _updateTrayTooltip('Taking area screenshot...');
          await _takeAreaScreenshotWithOCR();
          break;
        case 'takeFullscreenScreenshot':
          await _updateTrayTooltip('Taking fullscreen screenshot...');
          await _takeFullscreenScreenshotWithOCR();
          break;
        case 'viewHistory':
          await _showHistory();
          break;
        case 'settings':
          await _showSettings();
          break;
        case 'about':
          await _showAbout();
          break;
        case 'quit':
          await _quit();
          break;
        default:
          debugPrint('Unknown menu action: $action');
      }
    } catch (e) {
      debugPrint('Error handling menu action $action: $e');
      await _showErrorNotification('Action failed: $e');
      await _updateTrayTooltip('Ready');
    }
  }
  
  /// Take area screenshot and perform OCR
  Future<void> _takeAreaScreenshotWithOCR() async {
    try {
      debugPrint('Starting area screenshot capture...');
      
      // Capture screenshot of selected area
      final screenshotPath = await ScreenshotService.instance.captureSelectedArea();
      
      if (screenshotPath == null) {
        await _showErrorNotification(AppConstants.errorScreenshotFailed);
        await _updateTrayTooltip('Ready');
        return;
      }
      
      await _processScreenshotWithOCR(screenshotPath, 'Area');
    } catch (e) {
      debugPrint('Error in area screenshot OCR process: $e');
      await _showErrorNotification('Area screenshot failed: $e');
      await _updateTrayTooltip('Ready');
    }
  }
  
  /// Take fullscreen screenshot and perform OCR
  Future<void> _takeFullscreenScreenshotWithOCR() async {
    try {
      debugPrint('Starting fullscreen screenshot capture...');
      
      // Capture fullscreen screenshot
      final screenshotPath = await ScreenshotService.instance.captureFullScreen();
      
      if (screenshotPath == null) {
        await _showErrorNotification(AppConstants.errorScreenshotFailed);
        await _updateTrayTooltip('Ready');
        return;
      }
      
      await _processScreenshotWithOCR(screenshotPath, 'Fullscreen');
    } catch (e) {
      debugPrint('Error in fullscreen screenshot OCR process: $e');
      await _showErrorNotification('Fullscreen screenshot failed: $e');
      await _updateTrayTooltip('Ready');
    }
  }
  
  /// Process screenshot with OCR and copy to clipboard
  Future<void> _processScreenshotWithOCR(String screenshotPath, String type) async {
    try {
      await _updateTrayTooltip('Processing OCR...');
      debugPrint('$type screenshot captured: $screenshotPath');
      
      // Perform OCR on the captured image
      final extractedText = await OcrService.instance.extractText(screenshotPath);
      
      if (extractedText == null) {
        // External OCR service is handling this - don't copy anything
        await _showSuccessNotification('$type screenshot captured - OCR service processing...');
        await _updateTrayTooltip('Ready - OCR processing externally');
        return;
      }
      
      if (extractedText.isEmpty) {
        await _showErrorNotification('No text found in $type screenshot');
        await _updateTrayTooltip('Ready');
        return;
      }
      
      debugPrint('Text extracted: ${extractedText.length} characters');
      
      // Copy text to clipboard
      await _clipboardService.copyToClipboard(extractedText);
      
      // Show success notification
      await _showSuccessNotification(
        '$type screenshot: ${extractedText.length} characters copied to clipboard'
      );
      
      await _updateTrayTooltip('Ready - Last: ${extractedText.length} chars');
      
    } catch (e) {
      debugPrint('Error in $type screenshot OCR process: $e');
      await _showErrorNotification('$type screenshot OCR failed: $e');
      await _updateTrayTooltip('Ready');
    }
  }
  
  /// Show screenshot history (placeholder)
  Future<void> _showHistory() async {
    debugPrint('Showing screenshot history...');
    // TODO: Implement history view
    await _showInfoNotification('History feature coming soon');
  }
  
  /// Show settings (placeholder)
  Future<void> _showSettings() async {
    debugPrint('Showing settings...');
    // TODO: Implement settings view
    await _showInfoNotification('Settings feature coming soon');
  }
  
  /// Show about dialog (placeholder)
  Future<void> _showAbout() async {
    debugPrint('Showing about dialog...');
    await _showInfoNotification(
      '${AppConstants.appName} v${AppConstants.appVersion}\n${AppConstants.appDescription}'
    );
  }
  
  /// Quit the application
  Future<void> _quit() async {
    debugPrint('Quitting application...');
    
    // Stop OCR service
    await _stopOcrService();
    
    await _systemTray.destroy();
    SystemNavigator.pop();
  }
  
  /// Stop the OCR service
  Future<void> _stopOcrService() async {
    try {
      debugPrint('MenuBarService: Stopping OCR service...');
      
      // Kill the OCR service process
      await Process.run('pkill', ['-f', 'ocr_service.py']);
      
      // Remove flag file
      final flagFile = File('/tmp/ocr_service_running.flag');
      if (await flagFile.exists()) {
        await flagFile.delete();
      }
      
      debugPrint('MenuBarService: OCR service stopped');
    } catch (e) {
      debugPrint('MenuBarService: Error stopping OCR service: $e');
    }
  }
  
  /// Test the screenshot flow (for development)
  Future<void> testScreenshotFlow() async {
    debugPrint('Testing screenshot flow...');
    await _takeAreaScreenshotWithOCR();
  }
  
  /// Show error notification to user
  Future<void> _showErrorNotification(String message) async {
    debugPrint('❌ Error: $message');
    try {
      await _systemTray.popUpContextMenu();
    } catch (e) {
      debugPrint('Failed to show context menu: $e');
    }
  }
  
  /// Show success notification to user
  Future<void> _showSuccessNotification(String message) async {
    debugPrint('✅ Success: $message');
    // Update tray title temporarily to show success
    await _systemTray.setTitle("✅");
    Future.delayed(const Duration(seconds: 2), () {
      _systemTray.setTitle("📷");
    });
  }
  
  /// Show info notification to user
  Future<void> _showInfoNotification(String message) async {
    debugPrint('ℹ️ Info: $message');
  }
  
  /// Dispose of resources
  void dispose() {
    _systemTray.destroy();
    _clipboardService.dispose();
    _isInitialized = false;
  }
}