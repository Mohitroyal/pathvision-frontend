import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/team_provider.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final _notesController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  TaskSize _size = TaskSize.m;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  
  DateTime? _reminderDate;
  TimeOfDay? _reminderTime;
  
  String? _selectedProject;
  String? _selectedDept = 'AI / ML';
  String? _selectedMilestone;

  final List<String> _tags = ['edge-ai', 'jetson', 'firmware', 'testing'];
  final List<String> _selectedTags = [];
  final List<ChecklistItem> _checklist = [];
  final TextEditingController _checklistController = TextEditingController();

  List<String> _assignedMembers = [];

  void _createTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task Title is required.')),
      );
      return;
    }

    String? reminderStr;
    if (_reminderDate != null && _reminderTime != null) {
      reminderStr = DateTime(
        _reminderDate!.year, 
        _reminderDate!.month, 
        _reminderDate!.day, 
        _reminderTime!.hour, 
        _reminderTime!.minute
      ).toIso8601String();
    }

    final newTask = TaskModel(
      id: '',
      title: _titleController.text,
      description: _descController.text,
      project: _selectedProject,
      department: _selectedDept,
      tags: [..._selectedTags, if (_selectedDept != null) _selectedDept!],
      priority: _priority,
      size: _size,
      dueDate: _dueDate != null ? DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day, _dueTime?.hour ?? 0, _dueTime?.minute ?? 0) : null,
      checklist: List.from(_checklist),
      assignedMembers: List.from(_assignedMembers),
      reminder: reminderStr,
      privateNotes: _notesController.text,
      milestone: _selectedMilestone,
      status: TaskStatus.backlog,
    );

    context.read<TaskProvider>().addTask(newTask);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${_titleController.text}" added to Backlog.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
      appBar: JarvisTopbar(
        title: 'ADD NEW TASK',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('SAVE DRAFT', style: TextStyle(color: textDim)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _createTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('CREATE TASK'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isDesktop ? _buildTwoColumnLayout() : _buildStackedLayout(),
      ),
    );
  }

  Widget _buildTwoColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildLeftPanel()),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildRightPanel()),
      ],
    );
  }

  Widget _buildStackedLayout() {
    return Column(
      children: [
        _buildLeftPanel(),
        const SizedBox(height: 24),
        _buildRightPanel(),
      ],
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      children: [
        _buildCard(
          title: 'TASK DETAILS',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Task Title'),
              _buildTextField(_titleController, hint: 'Enter task title...'),
              const SizedBox(height: 20),
              _buildLabel('Description'),
              _buildTextField(_descController, hint: 'Describe the requirements...', maxLines: 3),
              const SizedBox(height: 24),
              _buildPrioritySelector(),
              const SizedBox(height: 24),
              _buildSizeSelector(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Due Date', _dueDate, (d) => setState(() => _dueDate = d))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildTimePicker('Time', _dueTime, (t) => setState(() => _dueTime = t))),
                ],
              ),
              const SizedBox(height: 24),
              _buildTagSection(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'CHECKLIST SECTION',
          child: Column(
            children: [
              ..._checklist.map((item) => _buildChecklistItem(item)).toList(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _checklistController,
                      style: const TextStyle(color: textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Add new item...',
                        hintStyle: TextStyle(color: textDim.withOpacity(0.5)),
                        filled: true,
                        fillColor: bgTertiary,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: gold),
                    onPressed: () {
                      if (_checklistController.text.isNotEmpty) {
                        setState(() {
                          _checklist.add(ChecklistItem(title: _checklistController.text));
                          _checklistController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        _buildCard(
          title: 'PROJECT & DEPARTMENT',
          child: Column(
            children: [
              Consumer<ProjectProvider>(
                builder: (context, projectProvider, _) {
                  final projects = projectProvider.projects.map((p) => p.name).toList();
                  if (projects.isNotEmpty && _selectedProject == null) {
                    _selectedProject = projects.first;
                  } else if (projects.isEmpty && _selectedProject == null) {
                    _selectedProject = 'JARVIS OS';
                  }
                  return _buildDropdown('Project', _selectedProject, projects.isEmpty ? ['JARVIS OS'] : projects, (v) => setState(() => _selectedProject = v));
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown('Department', _selectedDept, ['AI / ML', 'EMBEDDED SYSTEMS', 'FULLSTACK / APP'], (v) => setState(() => _selectedDept = v)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'ASSIGNED TO',
          child: Column(
            children: [
              ..._assignedMembers.map((m) => _buildMemberCard(m)).toList(),
              const SizedBox(height: 16),
              _buildAddMemberDropdown(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'ADDITIONAL INFO',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Reminder Notification'),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Date', _reminderDate, (d) => setState(() => _reminderDate = d))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker('Time', _reminderTime, (t) => setState(() => _reminderTime = t))),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Private Notes (Used for reminder body)'),
              _buildTextField(_notesController, hint: 'Internal details...', maxLines: 2),
              const SizedBox(height: 20),
              _buildDropdown('Linked to Milestone', _selectedMilestone, ['Phase 1', 'Phase 2', 'Launch'], (v) => setState(() => _selectedMilestone = v), hint: 'Select Milestone'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(String member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: gold.withOpacity(0.1), child: Text(member.isNotEmpty ? member[0] : '?', style: const TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Text(member, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold))),
          IconButton(icon: const Icon(Icons.close, size: 16, color: dangerColor), onPressed: () => setState(() => _assignedMembers.remove(member))),
        ],
      ),
    );
  }

  Widget _buildAddMemberDropdown() {
    final teamProvider = context.watch<TeamProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: goldLine), borderRadius: BorderRadius.circular(4)),
      child: DropdownButton<String>(
        hint: Text('Assign member', style: GoogleFonts.jetBrainsMono(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: bgTertiary,
        items: teamProvider.members.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name, style: const TextStyle(color: textPrimary, fontSize: 12)))).toList(),
        onChanged: (val) {
          if (val != null && !_assignedMembers.contains(val)) setState(() => _assignedMembers.add(val));
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgSecondary, borderRadius: BorderRadius.circular(6), border: Border.all(color: goldLine)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.orbitron(color: gold, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textDim.withOpacity(0.5), fontSize: 12),
        filled: true,
        fillColor: bgTertiary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Priority'),
        Row(
          children: TaskPriority.values.map((p) {
            final isSelected = _priority == p;
            Color color;
            switch (p) {
              case TaskPriority.critical: color = dangerColor; break;
              case TaskPriority.high: color = warnColor; break;
              case TaskPriority.medium: color = gold; break;
              case TaskPriority.low: color = textDim; break;
            }
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : bgTertiary,
                      border: Border.all(color: isSelected ? color : Colors.transparent),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(p.name.toUpperCase(), style: TextStyle(color: isSelected ? color : textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Task Size'),
        Row(
          children: TaskSize.values.map((s) {
            final isSelected = _size == s;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => setState(() => _size = s),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? goldDim : bgTertiary,
                    border: Border.all(color: isSelected ? gold : Colors.transparent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(s.name.toUpperCase(), style: TextStyle(color: isSelected ? gold : textDim, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, Function(DateTime) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value == null ? 'Select Date' : DateFormat('MMM dd').format(value), style: TextStyle(color: value == null ? textDim : textPrimary, fontSize: 13)),
                const Icon(Icons.calendar_today, size: 14, color: gold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? value, Function(TimeOfDay) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: value ?? TimeOfDay.now());
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value == null ? 'Select Time' : value.format(context), style: TextStyle(color: value == null ? textDim : textPrimary, fontSize: 13)),
                const Icon(Icons.access_time, size: 14, color: gold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Tags / Labels'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return InkWell(
                onTap: () => setState(() => isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? goldDim : bgTertiary,
                    border: Border.all(color: isSelected ? gold : Colors.transparent),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(tag, style: TextStyle(color: isSelected ? gold : textDim, fontSize: 11)),
                ),
              );
            }),
            _buildAddTagInput(),
          ],
        ),
      ],
    );
  }

  Widget _buildAddTagInput() {
    return Container(
      width: 100,
      height: 30,
      child: TextField(
        controller: _tagController,
        style: const TextStyle(fontSize: 11, color: textPrimary),
        decoration: InputDecoration(
          hintText: '+ Tag',
          hintStyle: const TextStyle(fontSize: 11, color: textDim),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: goldLine)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onSubmitted: (val) {
          if (val.isNotEmpty) {
            setState(() {
              _tags.add(val);
              _selectedTags.add(val);
              _tagController.clear();
            });
          }
        },
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: item.isDone,
            activeColor: gold,
            onChanged: (val) => setState(() => item.isDone = val!),
          ),
          Expanded(child: Text(item.title, style: TextStyle(color: item.isDone ? textDim : textPrimary, fontSize: 13, decoration: item.isDone ? TextDecoration.lineThrough : null))),
          IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: dangerColor), onPressed: () => setState(() => _checklist.remove(item))),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
          child: DropdownButton<String>(
            value: value,
            hint: hint != null ? Text(hint, style: TextStyle(color: textDim, fontSize: 13)) : null,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: bgTertiary,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: textPrimary, fontSize: 13)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
