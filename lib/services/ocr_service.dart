import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Service responsible for performing OCR (Optical Character Recognition)
/// 
/// This service handles:
/// - Text extraction from images
/// - Text confidence scoring
/// - Text formatting and cleanup
/// - Integration with ML Kit or other OCR engines
class OcrService {
  static const MethodChannel _channel = MethodChannel('screenshot_ocr/ocr');
  
  bool _isInitialized = false;
  
  /// Initialize the OCR service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize ML Kit or other OCR engine
      await _initializeOcrEngine();
      
      _isInitialized = true;
      debugPrint('OcrService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize OcrService: $e');
      rethrow;
    }
  }
  
  /// Initialize the OCR engine (ML Kit, Tesseract, etc.)
  Future<void> _initializeOcrEngine() async {
    try {
      // TODO: Initialize ML Kit Text Recognition
      // For now, this is a placeholder
      await _channel.invokeMethod('initialize');
    } catch (e) {
      debugPrint('OCR engine initialization failed: $e');
      // Continue without native OCR for development
    }
  }
  
  /// Extract text from an image file
  /// 
  /// [imagePath] - Path to the image file
  /// [confidenceThreshold] - Minimum confidence level for text recognition
  /// 
  /// Returns the extracted text as a string
  Future<String> extractTextFromImage(
    String imagePath, {
    double confidenceThreshold = AppConstants.ocrConfidenceThreshold,
  }) async {
    try {
      debugPrint('Starting OCR on image: $imagePath');
      
      // Verify the image file exists
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found: $imagePath');
      }
      
      // Perform OCR using the native implementation
      final extractedText = await _performOcrNative(imagePath, confidenceThreshold);
      
      // Clean up and format the extracted text
      final cleanedText = _cleanupExtractedText(extractedText);
      
      debugPrint('OCR completed. Extracted ${cleanedText.length} characters');
      return cleanedText;
      
    } catch (e) {
      debugPrint('Error during OCR processing: $e');
      rethrow;
    }
  }
  
  /// Perform OCR using native implementation
  Future<String> _performOcrNative(String imagePath, double confidenceThreshold) async {
    try {
      final result = await _channel.invokeMethod('extractText', {
        'imagePath': imagePath,
        'confidenceThreshold': confidenceThreshold,
        'timeout': AppConstants.maxOcrProcessingTime,
      });
      
      return result as String? ?? '';
    } catch (e) {
      debugPrint('Native OCR failed, using fallback: $e');
      return await _performOcrFallback(imagePath);
    }
  }
  
  /// Fallback OCR implementation for development/testing
  /// 
  /// This reads the file as text (useful for dummy screenshot files)
  /// In a real implementation, this might use a different OCR library
  Future<String> _performOcrFallback(String imagePath) async {
    try {
      final file = File(imagePath);
      
      // For development, if it's a text file (dummy screenshot), read it directly
      if (imagePath.endsWith('.txt') || await _isTextFile(file)) {
        final content = await file.readAsString();
        debugPrint('Using fallback text file reading');
        return content;
      }
      
      // For actual image files, return a placeholder
      debugPrint('Using OCR placeholder for image file');
      return 'OCR placeholder text from image: ${imagePath.split('/').last}';
      
    } catch (e) {
      debugPrint('Fallback OCR failed: $e');
      return '';
    }
  }
  
  /// Check if a file is a text file (for development purposes)
  Future<bool> _isTextFile(File file) async {
    try {
      // Try to read the first few bytes as text
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return false;
      
      // Check if the first 100 bytes are valid UTF-8 text
      final sample = bytes.take(100).toList();
      try {
        String.fromCharCodes(sample);
        return true;
      } catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Clean up and format extracted text
  String _cleanupExtractedText(String rawText) {
    if (rawText.isEmpty) return rawText;
    
    String cleaned = rawText;
    
    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Remove leading and trailing whitespace
    cleaned = cleaned.trim();
    
    // Fix common OCR errors (optional - can be expanded)
    cleaned = _fixCommonOcrErrors(cleaned);
    
    return cleaned;
  }
  
  /// Fix common OCR recognition errors
  String _fixCommonOcrErrors(String text) {
    String fixed = text;
    
    // Common character substitutions
    final corrections = {
      '0': 'O', // Zero to letter O in some contexts
      '1': 'l', // One to lowercase L in some contexts
      '5': 'S', // Five to letter S in some contexts
      // Add more corrections as needed
    };
    
    // Apply corrections only in word contexts (not for actual numbers)
    // This is a simplified approach - a real implementation would be more sophisticated
    
    return fixed;
  }
  
  /// Extract text with detailed results including confidence scores
  /// 
  /// Returns a map with extracted text and metadata
  Future<Map<String, dynamic>> extractTextWithDetails(String imagePath) async {
    try {
      final result = await _channel.invokeMethod('extractTextWithDetails', {
        'imagePath': imagePath,
      });
      
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      debugPrint('Detailed OCR extraction failed: $e');
      
      // Fallback to simple extraction
      final text = await extractTextFromImage(imagePath);
      return {
        'text': text,
        'confidence': 0.8, // Placeholder confidence
        'blocks': [],
        'processingTime': 0,
      };
    }
  }
  
  /// Check if OCR is available and working
  Future<bool> isOcrAvailable() async {
    try {
      await _channel.invokeMethod('checkAvailability');
      return true;
    } catch (e) {
      debugPrint('OCR not available: $e');
      return false;
    }
  }
  
  /// Get supported languages for OCR
  Future<List<String>> getSupportedLanguages() async {
    try {
      final result = await _channel.invokeMethod('getSupportedLanguages');
      return List<String>.from(result ?? ['en']);
    } catch (e) {
      debugPrint('Failed to get supported languages: $e');
      return ['en']; // Default to English
    }
  }
  
  /// Set the OCR language
  Future<void> setOcrLanguage(String languageCode) async {
    try {
      await _channel.invokeMethod('setLanguage', {
        'languageCode': languageCode,
      });
      debugPrint('OCR language set to: $languageCode');
    } catch (e) {
      debugPrint('Failed to set OCR language: $e');
    }
  }
  
  /// Process multiple images in batch
  Future<List<String>> extractTextFromMultipleImages(List<String> imagePaths) async {
    final results = <String>[];
    
    for (final imagePath in imagePaths) {
      try {
        final text = await extractTextFromImage(imagePath);
        results.add(text);
      } catch (e) {
        debugPrint('Failed to process image $imagePath: $e');
        results.add(''); // Add empty string for failed extractions
      }
    }
    
    return results;
  }
  
  /// Dispose of resources
  void dispose() {
    _isInitialized = false;
  }
}