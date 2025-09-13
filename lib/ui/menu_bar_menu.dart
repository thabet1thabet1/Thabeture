import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget for displaying the menu bar context menu
/// 
/// This widget creates the dropdown menu that appears when the user
/// clicks on the menu bar icon
class MenuBarMenu extends StatelessWidget {
  final Function(MenuAction) onMenuAction;
  
  const MenuBarMenu({
    super.key,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.menuWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuHeader(context),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.screenshot_monitor,
            title: 'Take Screenshot',
            subtitle: 'Capture area with OCR',
            action: MenuAction.takeScreenshot,
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'View History',
            subtitle: 'Recent screenshots',
            action: MenuAction.viewHistory,
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            action: MenuAction.settings,
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            action: MenuAction.about,
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.exit_to_app,
            title: 'Quit',
            action: MenuAction.quit,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
  
  /// Build the menu header with app name and version
  Widget _buildMenuHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.menuPadding),
      child: Row(
        children: [
          const Icon(
            Icons.screenshot_monitor,
            size: 24,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'v${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build a menu item
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required MenuAction action,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () => onMenuAction(action),
      child: Container(
        height: subtitle != null ? 60 : AppConstants.menuItemHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.menuPadding,
          vertical: 4,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive 
                  ? Colors.red 
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying menu bar status and notifications
class MenuBarStatusWidget extends StatelessWidget {
  final String message;
  final MenuBarStatusType type;
  final VoidCallback? onDismiss;
  
  const MenuBarStatusWidget({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.menuWidth,
      padding: const EdgeInsets.all(AppConstants.menuPadding),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            size: 20,
            color: _getIconColor(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getTextColor(context),
              ),
            ),
          ),
          if (onDismiss != null)
            InkWell(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 16,
                color: _getIconColor(context),
              ),
            ),
        ],
      ),
    );
  }
  
  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case MenuBarStatusType.success:
        return Colors.green.withOpacity(0.1);
      case MenuBarStatusType.error:
        return Colors.red.withOpacity(0.1);
      case MenuBarStatusType.warning:
        return Colors.orange.withOpacity(0.1);
      case MenuBarStatusType.info:
        return Colors.blue.withOpacity(0.1);
    }
  }
  
  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case MenuBarStatusType.success:
        return Colors.green.withOpacity(0.3);
      case MenuBarStatusType.error:
        return Colors.red.withOpacity(0.3);
      case MenuBarStatusType.warning:
        return Colors.orange.withOpacity(0.3);
      case MenuBarStatusType.info:
        return Colors.blue.withOpacity(0.3);
    }
  }
  
  Color _getTextColor(BuildContext context) {
    switch (type) {
      case MenuBarStatusType.success:
        return Colors.green.shade700;
      case MenuBarStatusType.error:
        return Colors.red.shade700;
      case MenuBarStatusType.warning:
        return Colors.orange.shade700;
      case MenuBarStatusType.info:
        return Colors.blue.shade700;
    }
  }
  
  Color _getIconColor(BuildContext context) {
    return _getTextColor(context);
  }
  
  IconData _getIcon() {
    switch (type) {
      case MenuBarStatusType.success:
        return Icons.check_circle_outline;
      case MenuBarStatusType.error:
        return Icons.error_outline;
      case MenuBarStatusType.warning:
        return Icons.warning_outlined;
      case MenuBarStatusType.info:
        return Icons.info_outline;
    }
  }
}

/// Widget for showing OCR processing progress
class OcrProgressWidget extends StatelessWidget {
  final String status;
  final double? progress;
  final VoidCallback? onCancel;
  
  const OcrProgressWidget({
    super.key,
    required this.status,
    this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.menuWidth,
      padding: const EdgeInsets.all(AppConstants.menuPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (onCancel != null)
                InkWell(
                  onTap: onCancel,
                  child: const Icon(Icons.close, size: 16),
                ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.3),
            ),
          ],
        ],
      ),
    );
  }
}

/// Types of status messages for the menu bar
enum MenuBarStatusType {
  success,
  error,
  warning,
  info,
}