import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_semantic_colors.dart';
import '../generated/l10n.dart';
import '../models/models.dart';

class LogConsole extends StatefulWidget {
  final List<LogEntry> logs;
  final bool autoScroll;
  final double maxHeight;
  final VoidCallback? onClear;
  final VoidCallback? onExport;

  const LogConsole({
    super.key,
    required this.logs,
    this.autoScroll = true,
    this.maxHeight = 280,
    this.onClear,
    this.onExport,
  });

  @override
  State<LogConsole> createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  LogLevel? _levelFilter;
  late bool _autoScrollEnabled;

  @override
  void initState() {
    super.initState();
    _autoScrollEnabled = widget.autoScroll;
  }

  List<LogEntry> get _filteredLogs {
    return widget.logs.where((log) {
      if (_levelFilter != null && log.level != _levelFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return log.message.toLowerCase().contains(q) ||
            (log.stage?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  @override
  void didUpdateWidget(LogConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoScrollEnabled && widget.logs.length != oldWidget.logs.length) {
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _copyLogs(BuildContext context, List<LogEntry> entries) async {
    final l10n = S.of(context);
    final text = entries.map((e) => e.toFormattedString()).join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logsCopied)),
      );
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    if (widget.onClear == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Logs?'),
        content: const Text(
          'This will clear the visible operation log entries for the current session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onClear?.call();
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

  Widget _buildLevelFilterChip(String label, LogLevel? level) {
    final selected = _levelFilter == level;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () => setState(() => _levelFilter = level),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[400],
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semantic;
    final visibleLogs = _filteredLogs;

    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: semantic.terminalBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: semantic.terminalHeader,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.logOutput,
                  style: TextStyle(
                    color: semantic.terminalForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${visibleLogs.length}/${widget.logs.length} ${l10n.logEntries}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _autoScrollEnabled
                        ? Icons.vertical_align_bottom
                        : Icons.pause_circle_outline,
                    size: 16,
                    color: _autoScrollEnabled
                        ? Colors.greenAccent.shade200
                        : Colors.grey[400],
                  ),
                  tooltip: _autoScrollEnabled
                      ? 'Auto-scroll On'
                      : 'Auto-scroll Off',
                  onPressed: () =>
                      setState(() => _autoScrollEnabled = !_autoScrollEnabled),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
                if (widget.logs.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.copy_all, size: 16, color: Colors.grey[400]),
                    tooltip: l10n.copyLogs,
                    onPressed: () => _copyLogs(context, visibleLogs),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  if (widget.onExport != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.download_outlined,
                          size: 16, color: Colors.grey[400]),
                      tooltip: 'Export Logs',
                      onPressed: widget.onExport,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                  if (widget.onClear != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 16, color: Colors.grey[400]),
                      tooltip: l10n.clearLogs,
                      onPressed: () => _confirmClear(context),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (widget.logs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: semantic.terminalHeader.withValues(alpha: 0.7),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 26,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: TextStyle(
                          color: semantic.terminalForeground,
                          fontSize: 11.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Filter logs...',
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 11),
                          prefixIcon: Icon(Icons.search,
                              size: 14, color: Colors.grey[500]),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close,
                                      size: 13, color: Colors.grey[400]),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.06),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildLevelFilterChip('All', null),
                  _buildLevelFilterChip('Info', LogLevel.info),
                  _buildLevelFilterChip('OK', LogLevel.success),
                  _buildLevelFilterChip('Warn', LogLevel.warning),
                  _buildLevelFilterChip('Err', LogLevel.error),
                ],
              ),
            ),
          Expanded(
            child: visibleLogs.isEmpty
                ? Center(
                    child: Text(
                      widget.logs.isEmpty
                          ? l10n.noLogs
                          : 'No logs match the current filter.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: visibleLogs.length,
                    itemBuilder: (context, index) {
                      final log = visibleLogs[index];
                      return RepaintBoundary(
                        child: Padding(
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