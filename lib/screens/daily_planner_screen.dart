import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../providers/planner_provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({Key? key}) : super(key: key);

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  final List<int> _timeSlots = [8, 9, 10, 11, 12, 14, 15, 16, 17];
  DateTime _currentDate = DateTime.now();

  void _showAddBlockModal() {
    int startHour = 8;
    int duration = 1;
    BlockType type = BlockType.task;
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: bgSecondary,
          shape: RoundedRectangleBorder(side: const BorderSide(color: goldLine), borderRadius: BorderRadius.circular(12)),
          title: Text('BLOCK TIME', style: GoogleFonts.orbitron(color: gold, fontSize: 16, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'TITLE',
                  labelStyle: TextStyle(color: textDim, fontSize: 10),
                  filled: true,
                  fillColor: bgTertiary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              _buildModalDropdown('START TIME', _timeSlots.map((h) => '${h.toString().padLeft(2, '0')}:00').toList(), '${startHour.toString().padLeft(2, '0')}:00', (v) {
                setModalState(() => startHour = int.parse(v!.split(':')[0]));
              }),
              const SizedBox(height: 16),
              _buildModalDropdown('TYPE', BlockType.values.map((e) => e.name.toUpperCase()).toList(), type.name.toUpperCase(), (v) {
                setModalState(() => type = BlockType.values.firstWhere((e) => e.name.toUpperCase() == v));
              }),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: TextStyle(color: textDim))),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  context.read<PlannerProvider>().addBlock(PlannerBlock(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleCtrl.text,
                    startHour: startHour,
                    duration: duration,
                    type: type,
                  ));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: bgPrimary),
              child: const Text('BLOCK TIME'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: textDim, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: bgTertiary,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13, color: textPrimary)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      appBar: JarvisTopbar(
        title: 'DAILY PLANNER — ${DateFormat('EEEE, MMM dd').format(_currentDate).toUpperCase()}',
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: gold),
            onPressed: () => setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1))),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: gold),
            onPressed: () => setState(() => _currentDate = _currentDate.add(const Duration(days: 1))),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showAddBlockModal,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('BLOCK TIME'),
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: bgPrimary),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildAiSuggestionCard(),
                Expanded(child: _buildTimeTable()),
              ],
            ),
          ),
          if (isDesktop) _buildRightPanel(),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionCard() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: goldDim.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: gold, size: isMobile ? 24 : 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('JARVIS DAILY PLAN SUGGESTION', style: GoogleFonts.orbitron(color: gold, fontSize: isMobile ? 8 : 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text('“Block 9–11 AM as deep focus for IMAS review.”', style: TextStyle(color: textPrimary, fontSize: isMobile ? 12 : 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildTableHeader(),
          ..._timeSlots.map((hour) => _buildTimeRow(hour)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: goldLine))),
      child: Row(
        children: [
          SizedBox(width: 70, child: _buildHeaderText('TIME')),
          Expanded(flex: 4, child: _buildHeaderText('FOCUS / WORK')),
          if (!isMobile) ...[
            Expanded(flex: 2, child: _buildHeaderText('MEETINGS')),
            Expanded(flex: 2, child: _buildHeaderText('NOTES')),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(text, style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold));
  }

  Widget _buildTimeRow(int hour) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      height: 60,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: goldLine.withOpacity(0.1)))),
      child: Row(
        children: [
          // Time column
          SizedBox(
            width: 70,
            child: Text('${hour.toString().padLeft(2, '0')}:00', style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 11)),
          ),
          // Content columns
          Expanded(flex: 4, child: _buildDropZone(hour, [BlockType.focus, BlockType.task, BlockType.overdue, BlockType.meeting])),
          if (!isMobile) ...[
            Expanded(flex: 2, child: _buildDropZone(hour, [BlockType.meeting])),
            Expanded(flex: 2, child: _buildNotesZone(hour)),
          ],
        ],
      ),
    );
  }

  Widget _buildDropZone(int hour, List<BlockType> allowedTypes) {
    return Consumer<PlannerProvider>(
      builder: (context, provider, child) {
        final blocksInSlot = provider.blocks.where((b) => b.startHour == hour && allowedTypes.contains(b.type)).toList();

        return DragTarget<PlannerBlock>(
          onWillAccept: (data) => true,
          onAccept: (data) => provider.updateBlock(data!.id, startHour: hour),
          builder: (context, candidateData, rejectedData) => Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty ? gold.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: blocksInSlot.map((b) => _buildBlockItem(b)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlockItem(PlannerBlock block) {
    Color color;
    switch (block.type) {
      case BlockType.focus: color = gold; break;
      case BlockType.meeting: color = blueColor; break;
      case BlockType.overdue: color = dangerColor; break;
      default: color = textDim;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: LongPressDraggable<PlannerBlock>(
        data: block,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
            child: Text(block.title, style: const TextStyle(color: bgPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border(left: BorderSide(color: color, width: 4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(block.title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
              if (block.isOverdue)
                Text('OVERDUE', style: TextStyle(color: dangerColor, fontSize: 8, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesZone(int hour) {
    return Consumer<PlannerProvider>(
      builder: (context, provider, child) {
        final block = provider.blocks.where((b) => b.startHour == hour).firstOrNull;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            onChanged: (val) {
              if (block != null) provider.updateBlock(block.id, notes: val);
            },
            controller: TextEditingController(text: block?.notes ?? ''),
            style: TextStyle(color: textDim, fontSize: 11, fontStyle: FontStyle.italic),
            decoration: const InputDecoration(border: InputBorder.none, hintText: '...', hintStyle: TextStyle(color: bgQuaternary)),
          ),
        );
      },
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: 300,
      decoration: const BoxDecoration(border: Border(left: BorderSide(color: goldLine))),
      // We wrap the entire content in a SingleChildScrollView to prevent overflow
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TIME LEGEND', style: GoogleFonts.orbitron(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildLegendItem('Focus Block', gold),
            _buildLegendItem('Meeting', blueColor),
            _buildLegendItem('Task', textDim),
            _buildLegendItem('Overdue', dangerColor),
            const SizedBox(height: 32),
            Text('TASK POOL', style: GoogleFonts.orbitron(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Replacing Expanded with a fixed height or flexible list
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final tasks = taskProvider.tasks.where((t) => t.status != TaskStatus.done).toList();
                return Column(
                  children: tasks.map((t) {
                    return Draggable<PlannerBlock>(
                      data: PlannerBlock(id: t.id, title: t.title, startHour: 0, type: BlockType.task),
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: textDim.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                          child: Text(t.title, style: const TextStyle(color: bgPrimary, fontSize: 12)),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4), border: Border.all(color: bgQuint)),
                        child: Text(t.title, style: TextStyle(color: textDim, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: textDim, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<PlannerProvider>(
      builder: (context, provider, child) {
        final totalHours = provider.blocks.fold<int>(0, (prev, b) => prev + b.duration);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: bgSecondary, borderRadius: BorderRadius.circular(8), border: Border.all(color: goldLine)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DAILY SUMMARY', style: GoogleFonts.orbitron(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Planned', style: TextStyle(color: textPrimary, fontSize: 12)),
                  Text('$totalHours hrs', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Suggestion:', style: TextStyle(color: textDim, fontSize: 10)),
              const SizedBox(height: 4),
              Text('Your afternoon is clear. Use 14:00-16:00 for deep work.', style: TextStyle(color: textPrimary, fontSize: 11, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
    );
  }
}
