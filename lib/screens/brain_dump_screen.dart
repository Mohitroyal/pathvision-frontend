// lib/screens/brain_dump_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/brain_dump_model.dart';
import '../models/task_model.dart';
import '../providers/brain_dump_provider.dart';
import '../providers/task_provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

class BrainDumpScreen extends StatefulWidget {
  const BrainDumpScreen({Key? key}) : super(key: key);

  @override
  State<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends State<BrainDumpScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  BrainDumpTag _selectedTag = BrainDumpTag.idea;
  BrainDumpTag? _filterTag;
  String _query = '';

  @override
  void dispose() {
    _inputController.dispose();
    _searchController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      _focusCapture(message: 'Type something to capture.');
      return;
    }
    context.read<BrainDumpProvider>().addEntry(text, tag: _selectedTag);
    _inputController.clear();
    _inputFocus.requestFocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Captured.'),
          duration: Duration(milliseconds: 1200),
        ),
      );
  }

  void _focusCapture({String? message}) {
    _inputFocus.requestFocus();
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(milliseconds: 1500),
          ),
        );
    }
  }

  List<BrainDumpEntry> _filtered(List<BrainDumpEntry> all) {
    return all.where((e) {
      if (_filterTag != null && e.tag != _filterTag) return false;
      if (_query.isEmpty) return true;
      return e.content.toLowerCase().contains(_query.toLowerCase());
    }).toList();
  }

  Future<void> _convertToTask(BrainDumpEntry entry) async {
    final taskProvider = context.read<TaskProvider>();
    final dumpProvider = context.read<BrainDumpProvider>();

    final result = await showDialog<_TaskFormResult>(
      context: context,
      builder: (_) => _ConvertToTaskDialog(initialTitle: entry.content),
    );
    if (result == null) return;

    final id = 'bd_task_${DateTime.now().millisecondsSinceEpoch}';
    taskProvider.addTask(
      TaskModel(
        id: id,
        title: result.title,
        description: result.description,
        priority: result.priority,
        tags: const ['brain-dump'],
        status: TaskStatus.backlog,
      ),
    );
    dumpProvider.markProcessed(entry.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sent to BACKLOG.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _editEntry(BrainDumpEntry entry) async {
    final dumpProvider = context.read<BrainDumpProvider>();
    final controller = TextEditingController(text: entry.content);
    BrainDumpTag tag = entry.tag;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            backgroundColor: bgTertiary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BorderValues.md),
              side: const BorderSide(color: goldLine),
            ),
            title: Text(
              'EDIT ENTRY',
              style: GoogleFonts.orbitron(
                color: gold,
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    minLines: 3,
                    maxLines: 6,
                    style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Entry content'),
                  ),
                  const SizedBox(height: Spacing.md),
                  _TagSelector(
                    selected: tag,
                    onChanged: (t) => setLocal(() => tag = t),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('CANCEL', style: TextStyle(color: textDim)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('SAVE', style: TextStyle(color: gold)),
              ),
            ],
          ),
        );
      },
    );

    if (saved == true) {
      dumpProvider.updateEntry(entry.id, content: controller.text, tag: tag);
    }
    controller.dispose();
  }

  void _confirmDelete(BrainDumpEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderValues.md),
          side: const BorderSide(color: goldLine),
        ),
        title: Text(
          'DELETE ENTRY?',
          style: GoogleFonts.orbitron(
            color: dangerColor,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          entry.content,
          style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: textDim)),
          ),
          TextButton(
            onPressed: () {
              context.read<BrainDumpProvider>().deleteEntry(entry.id);
              Navigator.pop(ctx);
            },
            child: const Text('DELETE', style: TextStyle(color: dangerColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final entries = context.watch<BrainDumpProvider>().entries;
    final visible = _filtered(entries);

    return Scaffold(
      appBar: JarvisTopbar(
        title: 'BRAIN DUMP',
        actions: [
          TopbarIconButton(
            icon: Icons.add,
            onTap: () => _focusCapture(message: 'Capture a thought...'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? Spacing.xl : Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(count: entries.length, processed: entries.where((e) => e.processed).length),
            const SizedBox(height: Spacing.lg),
            _CaptureCard(
              controller: _inputController,
              focusNode: _inputFocus,
              selectedTag: _selectedTag,
              onTagChanged: (t) => setState(() => _selectedTag = t),
              onSubmit: _submit,
            ),
            const SizedBox(height: Spacing.xl),
            _SearchAndFilter(
              controller: _searchController,
              activeTag: _filterTag,
              onQueryChanged: (q) => setState(() => _query = q),
              onTagChanged: (t) => setState(() => _filterTag = t),
            ),
            const SizedBox(height: Spacing.lg),
            if (visible.isEmpty)
              _EmptyState(hasEntries: entries.isNotEmpty)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                itemBuilder: (_, i) => _EntryCard(
                  entry: visible[i],
                  onConvert: () => _convertToTask(visible[i]),
                  onEdit: () => _editEntry(visible[i]),
                  onDelete: () => _confirmDelete(visible[i]),
                ),
              ),
            const SizedBox(height: Spacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final int processed;
  const _Header({required this.count, required this.processed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUICK CAPTURE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: textDim,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Brain Dump',
              style: GoogleFonts.orbitron(
                fontSize: 22,
                color: goldLight,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        _MetricChip(label: 'TOTAL', value: '$count'),
        const SizedBox(width: Spacing.sm),
        _MetricChip(label: 'PROCESSED', value: '$processed'),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: bgQuaternary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: textDim,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              color: gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final BrainDumpTag selectedTag;
  final ValueChanged<BrainDumpTag> onTagChanged;
  final VoidCallback onSubmit;

  const _CaptureCard({
    required this.controller,
    required this.focusNode,
    required this.selectedTag,
    required this.onTagChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
        boxShadow: [
          BoxShadow(
            color: goldGlow.withOpacity(0.15),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: gold, size: 16),
              const SizedBox(width: Spacing.xs),
              Text(
                'QUICK CAPTURE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: gold,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'CTRL + ENTER',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  color: textDim,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter):
                  const _SubmitIntent(),
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
                  const _SubmitIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _SubmitIntent: CallbackAction<_SubmitIntent>(
                  onInvoke: (_) {
                    onSubmit();
                    return null;
                  },
                ),
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 3,
                maxLines: 6,
                style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Dump thoughts, ideas, or quick tasks...',
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              _TagSelector(selected: selectedTag, onChanged: onTagChanged),
              const Spacer(),
              _PrimaryButton(label: '+ ADD NOTE', onTap: onSubmit),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmitIntent extends Intent {
  const _SubmitIntent();
}

class _SearchAndFilter extends StatelessWidget {
  final TextEditingController controller;
  final BrainDumpTag? activeTag;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<BrainDumpTag?> onTagChanged;

  const _SearchAndFilter({
    required this.controller,
    required this.activeTag,
    required this.onQueryChanged,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 540;
        final search = SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            onChanged: onQueryChanged,
            style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Search entries...',
              prefixIcon: Icon(Icons.search, color: textDim, size: 16),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        );
        final filter = Wrap(
          spacing: Spacing.xs,
          children: [
            _FilterPill(
              label: 'ALL',
              active: activeTag == null,
              onTap: () => onTagChanged(null),
            ),
            for (final t in BrainDumpTag.values)
              _FilterPill(
                label: t.label.toUpperCase(),
                active: activeTag == t,
                onTap: () => onTagChanged(t),
              ),
          ],
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [search, const SizedBox(height: Spacing.sm), filter],
          );
        }
        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: Spacing.lg),
            filter,
          ],
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? gold.withOpacity(0.12) : Colors.transparent,
            border: Border.all(color: active ? gold : goldLine),
            borderRadius: BorderRadius.circular(BorderValues.sm),
          ),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: active ? goldLight : textDim,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TagSelector extends StatelessWidget {
  final BrainDumpTag selected;
  final ValueChanged<BrainDumpTag> onChanged;
  const _TagSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.xs,
      children: [
        for (final t in BrainDumpTag.values)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected == t ? _tagColor(t).withOpacity(0.18) : bgQuaternary,
                  border: Border.all(
                    color: selected == t ? _tagColor(t) : goldLine,
                  ),
                  borderRadius: BorderRadius.circular(BorderValues.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_tagIcon(t), color: _tagColor(t), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      t.label.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: selected == t ? _tagColor(t) : textDim,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Color _tagColor(BrainDumpTag t) {
  switch (t) {
    case BrainDumpTag.idea:
      return goldLight;
    case BrainDumpTag.task:
      return blueColor;
    case BrainDumpTag.reminder:
      return warnColor;
  }
}

IconData _tagIcon(BrainDumpTag t) {
  switch (t) {
    case BrainDumpTag.idea:
      return Icons.lightbulb_outline;
    case BrainDumpTag.task:
      return Icons.check_box_outlined;
    case BrainDumpTag.reminder:
      return Icons.alarm;
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hover
                  ? const [Color(0xFF2A2008), Color(0xFF3A2D0C)]
                  : const [Color(0xFF1A1405), Color(0xFF2A2008)],
            ),
            border: Border.all(color: gold),
            borderRadius: BorderRadius.circular(BorderValues.sm),
            boxShadow: [
              BoxShadow(
                color: goldGlow.withOpacity(_hover ? 0.6 : 0.4),
                blurRadius: _hover ? 12 : 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: goldLight,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final BrainDumpEntry entry;
  final VoidCallback onConvert;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.onConvert,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 540;
    final color = _tagColor(entry.tag);

    final actions = Wrap(
      spacing: Spacing.xs,
      children: [
        _IconAction(
          icon: Icons.check_circle_outline,
          tooltip: entry.processed ? 'Already processed' : 'Convert to task',
          color: entry.processed ? textDim : okColor,
          onTap: entry.processed ? null : onConvert,
        ),
        _IconAction(icon: Icons.edit_outlined, tooltip: 'Edit', onTap: onEdit),
        _IconAction(
          icon: Icons.close,
          tooltip: 'Delete',
          color: dangerColor,
          onTap: onDelete,
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 36,
                margin: const EdgeInsets.only(right: Spacing.md, top: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  entry.content,
                  style: GoogleFonts.rajdhani(
                    color: entry.processed ? textDim : textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: entry.processed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (!isMobile) actions,
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  border: Border.all(color: color.withOpacity(0.6)),
                  borderRadius: BorderRadius.circular(BorderValues.xs),
                ),
                child: Text(
                  entry.tag.label.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: color,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                _formatTime(entry.createdAt),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: textDim,
                  letterSpacing: 0.8,
                ),
              ),
              if (entry.processed) ...[
                const SizedBox(width: Spacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: okColor.withOpacity(0.12),
                    border: Border.all(color: okColor.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(BorderValues.xs),
                  ),
                  child: Text(
                    'PROCESSED',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      color: okColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (isMobile) ...[
                const Spacer(),
                actions,
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final mm = t.month.toString().padLeft(2, '0');
    final dd = t.day.toString().padLeft(2, '0');
    return '${t.year}-$mm-$dd';
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color? color;
  final VoidCallback? onTap;
  const _IconAction({required this.icon, required this.tooltip, this.color, this.onTap});

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final c = widget.color ?? gold;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (enabled) setState(() => _hover = true);
        },
        onExit: (_) {
          if (enabled) setState(() => _hover = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(
                color: !enabled ? goldLine : c.withOpacity(_hover ? 1.0 : 0.6),
              ),
              borderRadius: BorderRadius.circular(BorderValues.sm),
              color: !enabled
                  ? Colors.transparent
                  : c.withOpacity(_hover ? 0.18 : 0.08),
              boxShadow: enabled && _hover
                  ? [BoxShadow(color: c.withOpacity(0.35), blurRadius: 6)]
                  : null,
            ),
            child: Icon(widget.icon, size: 14, color: !enabled ? textDim : c),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasEntries;
  const _EmptyState({required this.hasEntries});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxxl),
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      child: Column(
        children: [
          const Icon(Icons.bolt_outlined, color: goldDim, size: 36),
          const SizedBox(height: Spacing.sm),
          Text(
            hasEntries ? 'No matches for this filter.' : 'Your brain dump is empty.',
            style: GoogleFonts.rajdhani(color: textMid, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            hasEntries ? 'Try clearing the search or filter.' : 'Start by capturing a thought above.',
            style: GoogleFonts.rajdhani(color: textDim, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TaskFormResult {
  final String title;
  final String? description;
  final TaskPriority priority;
  _TaskFormResult({required this.title, this.description, required this.priority});
}

class _ConvertToTaskDialog extends StatefulWidget {
  final String initialTitle;
  const _ConvertToTaskDialog({required this.initialTitle});

  @override
  State<_ConvertToTaskDialog> createState() => _ConvertToTaskDialogState();
}

class _ConvertToTaskDialogState extends State<_ConvertToTaskDialog> {
  late final TextEditingController _title = TextEditingController(text: widget.initialTitle);
  final TextEditingController _desc = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgTertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BorderValues.md),
        side: const BorderSide(color: goldLine),
      ),
      title: Row(
        children: [
          const Icon(Icons.send_outlined, color: gold, size: 16),
          const SizedBox(width: Spacing.xs),
          Text(
            'CONVERT TO TASK',
            style: GoogleFonts.orbitron(
              color: gold,
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TITLE', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: textDim, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            TextField(
              controller: _title,
              style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 14),
              decoration: const InputDecoration(hintText: 'Task title'),
            ),
            const SizedBox(height: Spacing.md),
            Text('DESCRIPTION (OPTIONAL)', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: textDim, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            TextField(
              controller: _desc,
              minLines: 2,
              maxLines: 4,
              style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
              decoration: const InputDecoration(hintText: 'Add context...'),
            ),
            const SizedBox(height: Spacing.md),
            Text('PRIORITY', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: textDim, letterSpacing: 1.5)),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              children: [
                for (final p in TaskPriority.values)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _priority == p ? gold.withOpacity(0.15) : bgQuaternary,
                          border: Border.all(color: _priority == p ? gold : goldLine),
                          borderRadius: BorderRadius.circular(BorderValues.sm),
                        ),
                        child: Text(
                          p.name.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: _priority == p ? goldLight : textDim,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(
                border: Border.all(color: goldLine),
                borderRadius: BorderRadius.circular(BorderValues.sm),
                color: bgQuaternary,
              ),
              child: Row(
                children: [
                  const Icon(Icons.inbox_outlined, color: gold, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'TARGET COLUMN: BACKLOG',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: gold,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: textDim)),
        ),
        TextButton(
          onPressed: () {
            final title = _title.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(
              context,
              _TaskFormResult(
                title: title,
                description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
                priority: _priority,
              ),
            );
          },
          child: const Text('SEND TO BACKLOG', style: TextStyle(color: gold)),
        ),
      ],
    );
  }
}
