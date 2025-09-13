# Screenshot OCR - macOS Menu Bar App

A Flutter-based macOS desktop application that lives in the menu bar and provides quick screenshot capture with OCR (Optical Character Recognition) functionality.

## Features

- **Menu Bar Integration**: Runs as a menu bar app (like Dropbox or Raycast)
- **Screenshot Capture**: Interactive area selection for screenshots
- **OCR Processing**: Extracts text from captured images
- **Clipboard Integration**: Automatically copies recognized text to clipboard
- **Clean Architecture**: Modular design with separation of concerns

## Project Structure

```
lib/
├── main.dart                 # App entry point and menu bar setup
├── services/                 # Business logic services
│   ├── menu_bar_service.dart # Menu bar integration and coordination
│   ├── screenshot_service.dart # Screenshot capture functionality
│   ├── ocr_service.dart      # OCR text extraction
│   └── clipboard_service.dart # Clipboard operations
├── ui/                       # User interface components
│   └── menu_bar_menu.dart    # Menu bar UI widgets
└── utils/                    # Utilities and constants
    ├── constants.dart        # App constants and enums
    └── helpers.dart          # Helper functions
```

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter for macOS development
2. **Xcode**: Required for macOS app development
3. **macOS**: This app is designed specifically for macOS

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd screenshot-ocr-app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Enable macOS desktop support:
   ```bash
   flutter config --enable-macos-desktop
   ```

### Native Implementation Required

This Flutter project provides the structure and placeholder implementations. To make it fully functional, you'll need to implement native macOS functionality:

#### 1. Menu Bar Integration
- Create native macOS code to add an icon to the menu bar
- Implement menu item handling
- Add platform channels in `macos/Runner/`

#### 2. Screenshot Capture
- Implement native screenshot APIs using Core Graphics
- Add screen recording permissions to `macos/Runner/Info.plist`
- Create interactive area selection overlay

#### 3. OCR Integration
- Set up ML Kit for text recognition
- Or integrate with native macOS Vision framework
- Handle OCR processing and confidence scoring

### Required Permissions

Add these permissions to `macos/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs screen recording permission to capture screenshots.</string>
<key>NSScreenCaptureDescription</key>
<string>This app captures screenshots for OCR text extraction.</string>
```

## Development

### Running the App

```bash
flutter run -d macos
```

### Building for Release

```bash
flutter build macos --release
```

## Architecture Overview

### Services Layer
- **MenuBarService**: Coordinates all functionality and manages the menu bar
- **ScreenshotService**: Handles screenshot capture with multiple modes
- **OcrService**: Processes images and extracts text
- **ClipboardService**: Manages clipboard operations and history

### Key Features to Implement

1. **Native Menu Bar**:
   - System tray icon
   - Context menu with actions
   - Keyboard shortcuts

2. **Screenshot Modes**:
   - Selected area (interactive)
   - Full screen
   - Active window

3. **OCR Processing**:
   - Text extraction
   - Confidence scoring
   - Language detection

4. **User Experience**:
   - Progress indicators
   - Error handling
   - Success notifications

## Extending the App

The modular architecture makes it easy to add new features:

- **History View**: Track previous screenshots and OCR results
- **Settings Panel**: Configure OCR languages, shortcuts, etc.
- **Export Options**: Save results in different formats
- **Cloud Integration**: Sync across devices

## Platform Channels

The app uses these platform channels for native integration:

- `screenshot_ocr/menu_bar`: Menu bar operations
- `screenshot_ocr/screenshot`: Screenshot capture
- `screenshot_ocr/ocr`: OCR processing
- `screenshot_ocr/clipboard`: Advanced clipboard operations

## Dependencies

- `system_tray`: Menu bar integration
- `google_mlkit_text_recognition`: OCR functionality
- `path_provider`: File system access
- Built-in Flutter services for clipboard operations

## Contributing

1. Follow the existing code structure
2. Add comprehensive comments for new functionality
3. Test on macOS before submitting changes
4. Update documentation for new features

## License

[Add your license information here]
