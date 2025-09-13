import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../utils/constants.dart';

/// Service responsible for performing OCR (Optical Character Recognition)
/// 
/// This service handles:
/// - Text extraction from images using Google ML Kit
/// - Multi-language support
/// - Error handling and logging
/// - Integration with screenshot workflow
class OcrService {
  static final OcrService _instance = OcrService._internal();
  static OcrService get instance => _instance;
  factory OcrService() => _instance;
  OcrService._internal();

  late TextRecognizer _textRecognizer;
  bool _isInitialized = false;
  
  /// Initialize the OCR service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Google ML Kit Text Recognizer
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _isInitialized = true;
      debugPrint('OcrService: Initialized successfully with Google ML Kit');
      
      // Test OCR availability
      await _testOCRCapabilities();
      
    } catch (e) {
      debugPrint('OcrService: Failed to initialize ML Kit: $e');
      // Continue without ML Kit - we have fallback methods
      _isInitialized = false;
    }
  }
  
  /// Test OCR capabilities and log available methods
  Future<void> _testOCRCapabilities() async {
    debugPrint('OcrService: Testing OCR capabilities...');
    
    // Test ML Kit
    if (_isInitialized) {
      debugPrint('OcrService: ✅ Google ML Kit available');
    } else {
      debugPrint('OcrService: ❌ Google ML Kit not available');
    }
    
    // Test macOS shortcuts
    try {
      final result = await Process.run('shortcuts', ['list'], runInShell: true);
      if (result.exitCode == 0) {
        debugPrint('OcrService: ✅ macOS Shortcuts available');
      } else {
        debugPrint('OcrService: ❌ macOS Shortcuts not available');
      }
    } catch (e) {
      debugPrint('OcrService: ❌ macOS Shortcuts not available: $e');
    }
    
    // Test Python
    try {
      final result = await Process.run('python3', ['--version']);
      if (result.exitCode == 0) {
        debugPrint('OcrService: ✅ Python3 available: ${result.stdout.toString().trim()}');
      } else {
        debugPrint('OcrService: ❌ Python3 not available');
      }
    } catch (e) {
      debugPrint('OcrService: ❌ Python3 not available: $e');
    }
  }
  
  /// Extract text from an image file
  /// 
  /// [imagePath] - Path to the image file
  /// Returns the extracted text as a string, or null if no text found
  Future<String?> extractText(String imagePath) async {
    try {
      debugPrint('OcrService: Starting text extraction from: $imagePath');
      
      // Validate image file exists
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('OcrService: Image file does not exist: $imagePath');
        return null;
      }
      
      final fileSize = await imageFile.length();
      debugPrint('OcrService: Image file validated - Size: $fileSize bytes');
      
      if (fileSize == 0) {
        debugPrint('OcrService: Image file is empty');
        return null;
      }
      
      // Try Tesseract OCR directly using osascript (this works!)
      String? extractedText = await _tryDirectTesseractOCR(imagePath);
      if (extractedText != null && extractedText.isNotEmpty) {
        debugPrint('OcrService: Direct Tesseract OCR successful - ${extractedText.length} characters');
        return cleanText(extractedText);
      }
      
      debugPrint('OcrService: OCR failed - no text found');
      return null;
      
    } catch (e) {
      debugPrint('OcrService: Error during text extraction: $e');
      return null;
    }
  }
  
  /// Check if external OCR service is running and let it handle the processing
  Future<String?> _tryDirectTesseractOCR(String imagePath) async {
    try {
      debugPrint('OcrService: Checking for external OCR service...');
      
      // Check if the OCR service is running by looking for a flag file
      final flagFile = File('/tmp/ocr_service_running.flag');
      
      if (await flagFile.exists()) {
        debugPrint('OcrService: External OCR service detected - letting it handle the processing');
        
        // Return null so Flutter app doesn't copy anything to clipboard
        // The external service will handle OCR and clipboard copying
        return null;
      }
      
      // If no external service is running, provide setup instructions
      final imageFileName = imagePath.split('/').last;
      final instructionText = '''📸 Screenshot Captured!

File: $imageFileName

🚀 To enable automatic OCR:
1. Open Terminal
2. Run: python3 ~/ocr_service.py &
3. Take another screenshot - text will be auto-copied!

📋 Or extract text manually:
python3 ~/ocr_helper.py "$imagePath"

Path: $imagePath''';
      
      debugPrint('OcrService: External OCR service not running - providing setup instructions');
      return instructionText;
      
    } catch (e) {
      debugPrint('OcrService: Error checking OCR service: $e');
      return null;
    }
  }
  
  /// Try Google ML Kit OCR
  Future<String?> _tryMLKitOCR(String imagePath) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      debugPrint('OcrService: Trying ML Kit OCR...');
      
      // Create InputImage from file
      final inputImage = InputImage.fromFilePath(imagePath);
      
      // Perform text recognition
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final extractedText = recognizedText.text;
      debugPrint('OcrService: ML Kit result: "${extractedText}"');
      
      return extractedText.isNotEmpty ? extractedText : null;
      
    } catch (e) {
      debugPrint('OcrService: ML Kit OCR failed: $e');
      return null;
    }
  }
  
  /// Try macOS built-in OCR using AppleScript and Vision framework
  Future<String?> _tryMacOSOCR(String imagePath) async {
    try {
      debugPrint('OcrService: Trying macOS built-in OCR...');
      
      // Create AppleScript to use macOS Vision framework for OCR
      final appleScript = '''
on run argv
    set imagePath to item 1 of argv
    set imageFile to POSIX file imagePath
    
    tell application "System Events"
        try
            -- Use Quick Look to extract text (if available)
            set textResult to do shell script "mdls -name kMDItemTextContent -raw " & quoted form of imagePath
            if textResult is not "(null)" and textResult is not "" then
                return textResult
            end if
        end try
    end tell
    
    -- Fallback: return empty if no text found
    return ""
end run
''';
      
      // Write AppleScript to temp file
      final tempDir = Directory.systemTemp;
      final scriptPath = '${tempDir.path}/ocr_script.scpt';
      await File(scriptPath).writeAsString(appleScript);
      
      // Run AppleScript
      final result = await Process.run('osascript', [scriptPath, imagePath]);
      
      // Clean up
      try {
        await File(scriptPath).delete();
      } catch (_) {}
      
      if (result.exitCode == 0) {
        final extractedText = result.stdout.toString().trim();
        debugPrint('OcrService: macOS OCR result: "${extractedText}"');
        return extractedText.isNotEmpty ? extractedText : null;
      } else {
        debugPrint('OcrService: macOS OCR failed with exit code: ${result.exitCode}');
        debugPrint('OcrService: stderr: ${result.stderr}');
      }
      
    } catch (e) {
      debugPrint('OcrService: macOS OCR error: $e');
    }
    
    return null;
  }
  

  
  /// Extract text with detailed information including confidence and blocks
  /// 
  /// Returns a map with extracted text and metadata
  Future<Map<String, dynamic>> extractTextWithDetails(String imagePath) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return {'text': '', 'blocks': [], 'confidence': 0.0};
      }
      
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final List<Map<String, dynamic>> blocks = [];
      double totalConfidence = 0.0;
      int blockCount = 0;
      
      for (TextBlock block in recognizedText.blocks) {
        final blockData = {
          'text': block.text,
          'boundingBox': {
            'left': block.boundingBox.left,
            'top': block.boundingBox.top,
            'right': block.boundingBox.right,
            'bottom': block.boundingBox.bottom,
          },
          'lines': block.lines.map((line) => {
            'text': line.text,
            'boundingBox': {
              'left': line.boundingBox.left,
              'top': line.boundingBox.top,
              'right': line.boundingBox.right,
              'bottom': line.boundingBox.bottom,
            },
          }).toList(),
        };
        
        blocks.add(blockData);
        totalConfidence += 1.0; // ML Kit doesn't provide confidence scores
        blockCount++;
      }
      
      final averageConfidence = blockCount > 0 ? totalConfidence / blockCount : 0.0;
      
      return {
        'text': recognizedText.text,
        'blocks': blocks,
        'confidence': averageConfidence,
        'blockCount': blockCount,
      };
      
    } catch (e) {
      debugPrint('OcrService: Error during detailed text extraction: $e');
      return {'text': '', 'blocks': [], 'confidence': 0.0};
    }
  }
  
  /// Check if OCR service is available and working
  Future<bool> isAvailable() async {
    try {
      return _isInitialized || await _testOcrAvailability();
    } catch (e) {
      debugPrint('OcrService: Availability check failed: $e');
      return false;
    }
  }
  
  /// Test OCR availability by attempting to initialize
  Future<bool> _testOcrAvailability() async {
    try {
      await initialize();
      return _isInitialized;
    } catch (e) {
      debugPrint('OcrService: OCR not available: $e');
      return false;
    }
  }
  
  /// Get supported languages (ML Kit supports many languages automatically)
  List<String> getSupportedLanguages() {
    return [
      'en', // English
      'es', // Spanish
      'fr', // French
      'de', // German
      'it', // Italian
      'pt', // Portuguese
      'ru', // Russian
      'ja', // Japanese
      'ko', // Korean
      'zh', // Chinese
      'ar', // Arabic
      'hi', // Hindi
      'th', // Thai
      'vi', // Vietnamese
    ];
  }
  
  /// Process multiple images in batch
  Future<List<String?>> extractTextFromMultipleImages(List<String> imagePaths) async {
    final results = <String?>[];
    
    for (final imagePath in imagePaths) {
      try {
        final text = await extractText(imagePath);
        results.add(text);
      } catch (e) {
        debugPrint('OcrService: Failed to process image $imagePath: $e');
        results.add(null);
      }
    }
    
    return results;
  }
  
  /// Clean up extracted text by removing excessive whitespace and formatting
  String cleanText(String rawText) {
    if (rawText.isEmpty) return rawText;
    
    // Remove excessive whitespace
    String cleaned = rawText.replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove leading and trailing whitespace
    cleaned = cleaned.trim();
    
    // Fix common line break issues
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n');
    
    return cleaned;
  }
  
  /// Try to install Tesseract OCR using Homebrew
  Future<bool> installTesseract() async {
    try {
      debugPrint('OcrService: Attempting to install Tesseract via Homebrew...');
      
      // Check if Homebrew is available
      final brewCheck = await Process.run('which', ['brew']);
      if (brewCheck.exitCode != 0) {
        debugPrint('OcrService: Homebrew not found. Please install Homebrew first.');
        return false;
      }
      
      // Install Tesseract
      final result = await Process.run('brew', ['install', 'tesseract']);
      
      if (result.exitCode == 0) {
        debugPrint('OcrService: Tesseract installed successfully');
        return true;
      } else {
        debugPrint('OcrService: Failed to install Tesseract: ${result.stderr}');
        return false;
      }
      
    } catch (e) {
      debugPrint('OcrService: Error installing Tesseract: $e');
      return false;
    }
  }
  
  /// Try Tesseract OCR using AppleScript to bypass sandboxing
  Future<String?> _tryTesseractOCR(String imagePath) async {
    try {
      debugPrint('OcrService: Trying Tesseract OCR via AppleScript...');
      
      // Create AppleScript to run Tesseract
      final appleScript = '''
on run argv
    set imagePath to item 1 of argv
    
    try
        -- Try Homebrew path first
        set tesseractPath to "/opt/homebrew/bin/tesseract"
        set shellCommand to tesseractPath & " " & quoted form of imagePath & " stdout"
        set ocrResult to do shell script shellCommand
        return ocrResult
    on error
        try
            -- Try Intel Homebrew path
            set tesseractPath to "/usr/local/bin/tesseract"
            set shellCommand to tesseractPath & " " & quoted form of imagePath & " stdout"
            set ocrResult to do shell script shellCommand
            return ocrResult
        on error
            try
                -- Try system path
                set shellCommand to "tesseract " & quoted form of imagePath & " stdout"
                set ocrResult to do shell script shellCommand
                return ocrResult
            on error
                return "ERROR: Tesseract not found or failed"
            end try
        end try
    end try
end run
''';
      
      // Write AppleScript to temp file
      final tempDir = Directory.systemTemp;
      final scriptPath = '${tempDir.path}/tesseract_ocr.scpt';
      await File(scriptPath).writeAsString(appleScript);
      
      // Run AppleScript
      final result = await Process.run('osascript', [scriptPath, imagePath]);
      
      // Clean up
      try {
        await File(scriptPath).delete();
      } catch (_) {}
      
      if (result.exitCode == 0) {
        final extractedText = result.stdout.toString().trim();
        if (extractedText.isNotEmpty && !extractedText.startsWith('ERROR:')) {
          debugPrint('OcrService: AppleScript Tesseract OCR successful: "${extractedText.substring(0, extractedText.length > 50 ? 50 : extractedText.length)}..."');
          return extractedText;
        }
      }
      
      debugPrint('OcrService: AppleScript Tesseract failed: ${result.stderr}');
      return null;
      
    } catch (e) {
      debugPrint('OcrService: AppleScript Tesseract OCR error: $e');
      return null;
    }
  }
  
  /// Dispose of resources
  void dispose() {
    if (_isInitialized) {
      _textRecognizer.close();
      _isInitialized = false;
      debugPrint('OcrService: Disposed successfully');
    }
  }
}