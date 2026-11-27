import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/l10n.dart';
import '../config/app_semantic_colors.dart';
import '../logging/log_entry.dart';

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
  final Set<int> _expandedEntryHashes = {};

  // Memoized filter cache to avoid re-scanning large log lists on UI toggles.
  List<LogEntry>? _cachedFiltered;
  int _cachedSourceLength = -1;
  LogEntry? _cachedLastEntry;
  String _cachedQuery = '';
  LogLevel? _cachedLevel;

  @override
  void initState() {
    super.initState();
    _autoScrollEnabled = widget.autoScroll;
  }

  List<LogEntry> get _filteredLogs {
    final len = widget.logs.length;
    final last = len > 0 ? widget.logs.last : null;
    if (_cachedFiltered != null &&
        _cachedSourceLength == len &&
        identical(_cachedLastEntry, last) &&
        _cachedQuery == _searchQuery &&
        _cachedLevel == _levelFilter) {
      return _cachedFiltered!;
    }

    final q = _searchQuery.trim().toLowerCase();
    final filtered = widget.logs.where((log) {
      if (_levelFilter != null && log.level != _levelFilter) return false;
      if (q.isNotEmpty) {
        return log.message.toLowerCase().contains(q) ||
            (log.stage?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList(growable: false);

    _cachedFiltered = filtered;
    _cachedSourceLength = len;
    _cachedLastEntry = last;
    _cachedQuery = _searchQuery;
    _cachedLevel = _levelFilter;
    return filtered;
  }

  @override
  void didUpdateWidget(LogConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.isEmpty) {
      _expandedEntryHashes.clear();
    }
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

  Color _getLogColor(LogLevel level, AppSemanticColors semantic) {
    switch (level) {
      case LogLevel.info:
        return semantic.terminalForeground.withValues(alpha: 0.85);
      case LogLevel.success:
        return semantic.success;
      case LogLevel.warning:
        return semantic.warning;
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

  Widget _buildLevelFilterChip(
    String label,
    LogLevel? level,
    AppSemanticColors semantic,
  ) {
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
                ? semantic.terminalForeground.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(
              color: selected
                  ? semantic.terminalForeground.withValues(alpha: 0.3)
                  : semantic.terminalForeground.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? semantic.terminalForeground
                  : semantic.terminalForeground.withValues(alpha: 0.6),
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
    final muted = semantic.terminalForeground.withValues(alpha: 0.62);

    return RepaintBoundary(
      child: Container(
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
                  Icon(Icons.terminal, color: muted, size: 16),
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
                      color:
                          semantic.terminalForeground.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${visibleLogs.length}/${widget.logs.length} ${l10n.logEntries}',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _autoScrollEnabled
                          ? Icons.vertical_align_bottom
                          : Icons.pause_circle_outline,
                      size: 16,
                      color: _autoScrollEnabled ? semantic.success : muted,
                    ),
                    tooltip: _autoScrollEnabled
                        ? 'Auto-scroll On'
                        : 'Auto-scroll Off',
                    onPressed: () => setState(
                        () => _autoScrollEnabled = !_autoScrollEnabled),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                  if (widget.logs.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.copy_all, size: 16, color: muted),
                      tooltip: l10n.copyLogs,
                      onPressed: () => _copyLogs(context, visibleLogs),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    if (widget.onExport != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.download_outlined,
                            size: 16, color: muted),
                        tooltip: 'Export Logs',
                        onPressed: widget.onExport,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                    if (widget.onClear != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon:
                            Icon(Icons.delete_outline, size: 16, color: muted),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: semantic.terminalHeader.withValues(alpha: 0.7),
                  border: Border(
                    bottom: BorderSide(
                      color:
                          semantic.terminalForeground.withValues(alpha: 0.08),
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
                            hintStyle: TextStyle(color: muted, fontSize: 11),
                            prefixIcon:
                                Icon(Icons.search, size: 14, color: muted),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close,
                                        size: 13, color: muted),
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
                            fillColor: semantic.terminalForeground
                                .withValues(alpha: 0.06),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xs),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildLevelFilterChip('All', null, semantic),
                    _buildLevelFilterChip('Info', LogLevel.info, semantic),
                    _buildLevelFilterChip('OK', LogLevel.success, semantic),
                    _buildLevelFilterChip('Warn', LogLevel.warning, semantic),
                    _buildLevelFilterChip('Err', LogLevel.error, semantic),
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
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: visibleLogs.length,
                      itemBuilder: (context, index) {
                        final log = visibleLogs[index];
                        final lineColor = _getLogColor(log.level, semantic);
                        final hasDetails = log.technicalDetails != null &&
                            log.technicalDetails!.trim().isNotEmpty;
                        final entryKey = identityHashCode(log);
                        final isExpanded =
                            hasDetails && _expandedEntryHashes.contains(entryKey);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(
                                      _getLogIcon(log.level),
                                      color: lineColor,
                                      size: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: SelectableText(
                                      log.toFormattedString(),
                                      style: TextStyle(
                                        color: lineColor,
                                        fontSize: 11.5,
                                        fontFamily: 'Consolas',
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  if (hasDetails)
                                    IconButton(
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 14,
                                        color: muted,
                                      ),
                                      tooltip: isExpanded
                                          ? 'Hide Technical Details'
                                          : 'Show Technical Details',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 22,
                                        minHeight: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (isExpanded) {
                                            _expandedEntryHashes
                                                .remove(entryKey);
                                          } else {
                                            _expandedEntryHashes.add(entryKey);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                              if (isExpanded)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                    left: 19,
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: semantic.terminalForeground
                                        .withValues(alpha: 0.06),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xs),
                                    border: Border.all(
                                      color: semantic.terminalForeground
                                          .withValues(alpha: 0.14),
                                    ),
                                  ),
                                  child: SelectableText(
                                    log.technicalDetails!,
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 11,
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
      ),
    );
  }
}
