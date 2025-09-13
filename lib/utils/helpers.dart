import 'dart:io';
import 'package:flutter/material.dart';

/// Utility helper functions for the Screenshot OCR app
class AppHelpers {
  
  /// Format file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Format duration in human readable format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Format timestamp as relative time
  static String formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return formatDuration(difference);
  }
  
  /// Validate if a string contains valid text for OCR
  static bool isValidOcrText(String text) {
    if (text.trim().isEmpty) return false;
    
    // Check if text contains at least some alphanumeric characters
    final alphanumericRegex = RegExp(r'[a-zA-Z0-9]');
    return alphanumericRegex.hasMatch(text);
  }
  
  /// Clean filename for saving screenshots
  static String sanitizeFilename(String filename) {
    // Remove or replace invalid characters
    return filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
  
  /// Generate a unique filename with timestamp
  static String generateUniqueFilename(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp$extension';
  }
  
  /// Check if a file exists and is readable
  static Future<bool> isFileAccessible(String path) async {
    try {
      final file = File(path);
      return await file.exists() && await file.length() > 0;
    } catch (e) {
      return false;
    }
  }
  
  /// Get file extension from path
  static String getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot);
  }
  
  /// Check if file is an image based on extension
  static bool isImageFile(String path) {
    final extension = getFileExtension(path).toLowerCase();
    return ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff', '.webp']
        .contains(extension);
  }
  
  /// Truncate text to specified length with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }
  
  /// Count words in text
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
  
  /// Count lines in text
  static int countLines(String text) {
    if (text.isEmpty) return 0;
    return text.split('\n').length;
  }
  
  /// Extract preview text (first few lines)
  static String getTextPreview(String text, {int maxLines = 3, int maxChars = 100}) {
    if (text.isEmpty) return '';
    
    final lines = text.split('\n');
    final previewLines = lines.take(maxLines).toList();
    final preview = previewLines.join('\n');
    
    return truncateText(preview, maxChars);
  }
  
  /// Check if text contains mostly uppercase letters (might indicate OCR issues)
  static bool isMostlyUppercase(String text) {
    if (text.isEmpty) return false;
    
    final letters = text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (letters.isEmpty) return false;
    
    final uppercaseCount = letters.replaceAll(RegExp(r'[^A-Z]'), '').length;
    return uppercaseCount / letters.length > 0.7;
  }
  
  /// Detect if text might be a URL
  static bool looksLikeUrl(String text) {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    return urlRegex.hasMatch(text.trim());
  }
  
  /// Detect if text might be an email address
  static bool looksLikeEmail(String text) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(text.trim());
  }
  
  /// Detect if text might be a phone number
  static bool looksLikePhoneNumber(String text) {
    final phoneRegex = RegExp(
      r'^[\+]?[1-9][\d]{0,15}$'
    );
    final cleanText = text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return phoneRegex.hasMatch(cleanText);
  }
  
  /// Get text content type for better handling
  static TextContentType detectContentType(String text) {
    final trimmedText = text.trim();
    
    if (trimmedText.isEmpty) return TextContentType.empty;
    if (looksLikeUrl(trimmedText)) return TextContentType.url;
    if (looksLikeEmail(trimmedText)) return TextContentType.email;
    if (looksLikePhoneNumber(trimmedText)) return TextContentType.phoneNumber;
    
    // Check for code-like patterns
    if (trimmedText.contains(RegExp(r'[{}();]')) && 
        trimmedText.split('\n').length > 1) {
      return TextContentType.code;
    }
    
    // Check for structured data
    if (trimmedText.contains('\t') || 
        trimmedText.split('\n').every((line) => line.contains(RegExp(r'\s{2,}')))) {
      return TextContentType.structured;
    }
    
    return TextContentType.plainText;
  }
  
  /// Show a native macOS notification (placeholder)
  static Future<void> showNotification(String title, String message) async {
    // TODO: Implement native macOS notification
    debugPrint('Notification: $title - $message');
  }
  
  /// Copy text to clipboard with feedback
  static Future<bool> copyTextWithFeedback(String text) async {
    try {
      // This would use the ClipboardService in a real implementation
      debugPrint('Copying text to clipboard: ${text.length} characters');
      return true;
    } catch (e) {
      debugPrint('Failed to copy text: $e');
      return false;
    }
  }
  
  /// Validate screenshot file
  static Future<bool> validateScreenshotFile(String path) async {
    if (!await isFileAccessible(path)) return false;
    if (!isImageFile(path)) return false;
    
    try {
      final file = File(path);
      final size = await file.length();
      
      // Check if file is not empty and not too large (>50MB)
      return size > 0 && size < 50 * 1024 * 1024;
    } catch (e) {
      return false;
    }
  }
}

/// Types of text content detected by OCR
enum TextContentType {
  empty,
  plainText,
  url,
  email,
  phoneNumber,
  code,
  structured,
}