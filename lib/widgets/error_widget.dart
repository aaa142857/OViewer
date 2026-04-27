import 'package:flutter/material.dart';
import '../core/l10n/s.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onConfigureProxy;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.onConfigureProxy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final isNetworkError = message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (isNetworkError) ...[
              const SizedBox(height: 8),
              Text(
                s.proxyHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(s.retry),
                  ),
                if (onRetry != null && isNetworkError)
                  const SizedBox(width: 12),
                if (isNetworkError)
                  OutlinedButton.icon(
                    onPressed: onConfigureProxy ??
                        () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.vpn_key),
                    label: Text(s.proxy),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
