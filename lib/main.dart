import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/menu_bar_service.dart';
import 'utils/constants.dart';

/// Entry point for the macOS menu bar screenshot OCR app
/// 
/// This app runs in the background and provides a menu bar icon
/// for quick screenshot capture and OCR functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize menu bar service immediately
  final menuBarService = MenuBarService();
  await menuBarService.initialize();
  
  runApp(const ScreenshotOCRApp());
}

/// Main application widget
/// 
/// This is a minimal app since the main functionality happens
/// through the menu bar interface. The main window is hidden.
class ScreenshotOCRApp extends StatelessWidget {
  const ScreenshotOCRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HiddenMainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Hidden main screen widget
/// 
/// This screen is not visible to users as the app runs only in the menu bar
/// The window is minimized and hidden on startup
class HiddenMainScreen extends StatefulWidget {
  const HiddenMainScreen({super.key});

  @override
  State<HiddenMainScreen> createState() => _HiddenMainScreenState();
}

class _HiddenMainScreenState extends State<HiddenMainScreen> {
  @override
  void initState() {
    super.initState();
    // Hide the window after it's built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideWindow();
    });
  }

  void _hideWindow() {
    // Hide the main window so only the menu bar icon is visible
    // This is a placeholder - in a real implementation you'd use native macOS APIs
    debugPrint('Main window hidden - app running in menu bar only');
  }

  @override
  Widget build(BuildContext context) {
    // Return a minimal invisible widget
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}