import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Service responsible for clipboard operations
/// 
/// This service handles:
/// - Copying text to clipboard
/// - Reading text from clipboard
/// - Clipboard history management
/// - Format detection and conversion
class ClipboardService {
  static const MethodChannel _channel = MethodChannel('screenshot_ocr/clipboard');
  
  bool _isInitialized = false;
  final List<ClipboardEntry> _history = [];
  static const int _maxHistorySize = 100;
  
  /// Initialize the clipboard service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize clipboard monitoring if needed
      await _initializeClipboardMonitoring();
      
      _isInitialized = true;
      debugPrint('ClipboardService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize ClipboardService: $e');
      rethrow;
    }
  }
  
  /// Initialize clipboard monitoring (optional feature)
  Future<void> _initializeClipboardMonitoring() async {
    try {
      // TODO: Set up clipboard change monitoring if needed
      // This could be used to track clipboard history
      await _channel.invokeMethod('initialize');
    } catch (e) {
      debugPrint('Clipboard monitoring initialization failed: $e');
      // Continue without monitoring
    }
  }
  
  /// Copy text to the system clipboard
  /// 
  /// [text] - The text to copy
  /// [addToHistory] - Whether to add this to clipboard history
  /// 
  /// Returns true if successful, false otherwise
  Future<bool> copyToClipboard(String text, {bool addToHistory = true}) async {
    try {
      if (text.isEmpty) {
        debugPrint('Cannot copy empty text to clipboard');
        return false;
      }
      
      // Copy to system clipboard using Flutter's built-in method
      await Clipboard.setData(ClipboardData(text: text));
      
      // Add to history if requested
      if (addToHistory) {
        _addToHistory(text, ClipboardEntryType.text);
      }
      
      debugPrint('Text copied to clipboard: ${text.length} characters');
      return true;
      
    } catch (e) {
      debugPrint('Failed to copy text to clipboard: $e');
      return false;
    }
  }
  
  /// Read text from the system clipboard
  /// 
  /// Returns the clipboard text, or null if clipboard is empty or contains non-text data
  Future<String?> readFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text;
      
      if (text != null && text.isNotEmpty) {
        debugPrint('Read text from clipboard: ${text.length} characters');
        return text;
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to read from clipboard: $e');
      return null;
    }
  }
  
  /// Check if clipboard contains text data
  Future<bool> hasText() async {
    try {
      final text = await readFromClipboard();
      return text != null && text.isNotEmpty;
    } catch (e) {
      debugPrint('Failed to check clipboard text: $e');
      return false;
    }
  }
  
  /// Copy formatted text with metadata
  /// 
  /// This method can handle rich text formats in the future
  Future<bool> copyFormattedText(
    String text, {
    String? htmlFormat,
    String? rtfFormat,
    bool addToHistory = true,
  }) async {
    try {
      // For now, just copy as plain text
      // TODO: Implement rich text clipboard support using native methods
      final success = await copyToClipboard(text, addToHistory: addToHistory);
      
      if (success && (htmlFormat != null || rtfFormat != null)) {
        // TODO: Use native clipboard methods to set multiple formats
        await _copyFormattedTextNative(text, htmlFormat, rtfFormat);
      }
      
      return success;
    } catch (e) {
      debugPrint('Failed to copy formatted text: $e');
      return false;
    }
  }
  
  /// Native implementation for formatted text copying
  Future<void> _copyFormattedTextNative(
    String plainText,
    String? htmlFormat,
    String? rtfFormat,
  ) async {
    try {
      await _channel.invokeMethod('copyFormattedText', {
        'plainText': plainText,
        'htmlFormat': htmlFormat,
        'rtfFormat': rtfFormat,
      });
    } catch (e) {
      debugPrint('Native formatted text copy failed: $e');
      // Fallback to plain text is already handled
    }
  }
  
  /// Add entry to clipboard history
  void _addToHistory(String content, ClipboardEntryType type) {
    final entry = ClipboardEntry(
      content: content,
      type: type,
      timestamp: DateTime.now(),
    );
    
    // Remove duplicate entries
    _history.removeWhere((existing) => existing.content == content);
    
    // Add to beginning of list
    _history.insert(0, entry);
    
    // Limit history size
    if (_history.length > _maxHistorySize) {
      _history.removeRange(_maxHistorySize, _history.length);
    }
    
    debugPrint('Added entry to clipboard history. Total entries: ${_history.length}');
  }
  
  /// Get clipboard history
  List<ClipboardEntry> getHistory() {
    return List.unmodifiable(_history);
  }
  
  /// Clear clipboard history
  void clearHistory() {
    _history.clear();
    debugPrint('Clipboard history cleared');
  }
  
  /// Remove specific entry from history
  bool removeFromHistory(ClipboardEntry entry) {
    final removed = _history.remove(entry);
    if (removed) {
      debugPrint('Removed entry from clipboard history');
    }
    return removed;
  }
  
  /// Copy entry from history back to clipboard
  Future<bool> copyFromHistory(ClipboardEntry entry) async {
    return await copyToClipboard(entry.content, addToHistory: false);
  }
  
  /// Search clipboard history
  List<ClipboardEntry> searchHistory(String query) {
    if (query.isEmpty) return getHistory();
    
    final lowercaseQuery = query.toLowerCase();
    return _history.where((entry) {
      return entry.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  /// Get clipboard statistics
  Map<String, dynamic> getStatistics() {
    final totalEntries = _history.length;
    final totalCharacters = _history.fold<int>(
      0,
      (sum, entry) => sum + entry.content.length,
    );
    
    final typeCount = <ClipboardEntryType, int>{};
    for (final entry in _history) {
      typeCount[entry.type] = (typeCount[entry.type] ?? 0) + 1;
    }
    
    return {
      'totalEntries': totalEntries,
      'totalCharacters': totalCharacters,
      'typeCount': typeCount,
      'oldestEntry': _history.isNotEmpty ? _history.last.timestamp : null,
      'newestEntry': _history.isNotEmpty ? _history.first.timestamp : null,
    };
  }
  
  /// Export clipboard history to text
  String exportHistoryAsText() {
    final buffer = StringBuffer();
    buffer.writeln('Clipboard History Export');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total entries: ${_history.length}');
    buffer.writeln('${'=' * 50}');
    
    for (int i = 0; i < _history.length; i++) {
      final entry = _history[i];
      buffer.writeln();
      buffer.writeln('Entry ${i + 1}:');
      buffer.writeln('Timestamp: ${entry.timestamp}');
      buffer.writeln('Type: ${entry.type}');
      buffer.writeln('Content:');
      buffer.writeln(entry.content);
      buffer.writeln('-' * 30);
    }
    
    return buffer.toString();
  }
  
  /// Dispose of resources
  void dispose() {
    _history.clear();
    _isInitialized = false;
  }
}

/// Represents an entry in the clipboard history
class ClipboardEntry {
  final String content;
  final ClipboardEntryType type;
  final DateTime timestamp;
  
  ClipboardEntry({
    required this.content,
    required this.type,
    required this.timestamp,
  });
  
  /// Get a preview of the content (first 100 characters)
  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 97)}...';
  }
  
  /// Get the size of the content in characters
  int get size => content.length;
  
  /// Check if this entry contains the given text
  bool contains(String text) {
    return content.toLowerCase().contains(text.toLowerCase());
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClipboardEntry &&
        other.content == content &&
        other.type == type &&
        other.timestamp == timestamp;
  }
  
  @override
  int get hashCode => Object.hash(content, type, timestamp);
  
  @override
  String toString() {
    return 'ClipboardEntry(type: $type, timestamp: $timestamp, size: $size)';
  }
}

/// Types of clipboard entries
enum ClipboardEntryType {
  text,
  richText,
  image,
  file,
  other,
}