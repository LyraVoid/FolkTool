import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../generated/l10n.dart';

class LogConsole extends StatefulWidget {
  final List<LogEntry> logs;
  final bool autoScroll;
  final double maxHeight;
  final VoidCallback? onClear;

  const LogConsole({
    super.key,
    required this.logs,
    this.autoScroll = true,
    this.maxHeight = 240,
    this.onClear,
  });

  @override
  State<LogConsole> createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(LogConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoScroll && widget.logs.length != oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyLogs(BuildContext context) async {
    final l10n = S.of(context);
    final text = widget.logs.map((e) => e.toFormattedString()).join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logsCopied)),
      );
    }
  }

  Color _getLogColor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Colors.grey.shade300;
      case LogLevel.success:
        return Colors.greenAccent.shade200;
      case LogLevel.warning:
        return Colors.orangeAccent.shade200;
      case LogLevel.error:
        return Colors.redAccent.shade200;
    }
  }

  IconData _getLogIcon(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.success:
        return Icons.check_circle_outline;
      case LogLevel.warning:
        return Icons.warning_amber_outlined;
      case LogLevel.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: const Color(0xFF14171C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1E222A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.logOutput,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.logs.length} ${l10n.logEntries}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                ),
                const Spacer(),
                if (widget.logs.isNotEmpty) ...[
                  IconButton(
                    icon: Icon(Icons.copy_all, size: 16, color: Colors.grey[400]),
                    tooltip: l10n.copyLogs,
                    onPressed: () => _copyLogs(context),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  if (widget.onClear != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 16, color: Colors.grey[400]),
                      tooltip: l10n.clearLogs,
                      onPressed: widget.onClear,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ],
            ),
          ),
          Expanded(
            child: widget.logs.isEmpty
                ? Center(
                    child: Text(
                      l10n.noLogs,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.logs.length,
                    itemBuilder: (context, index) {
                      final log = widget.logs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                _getLogIcon(log.level),
                                color: _getLogColor(log.level),
                                size: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: SelectableText(
                                log.toFormattedString(),
                                style: TextStyle(
                                  color: _getLogColor(log.level),
                                  fontSize: 11.5,
                                  fontFamily: 'Consolas',
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
