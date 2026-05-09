import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../models/team_model.dart';
import '../providers/team_provider.dart';
import '../providers/project_provider.dart';
import 'package:intl/intl.dart';

class AddMemberScreen extends StatefulWidget {
  final MemberModel? member;
  const AddMemberScreen({Key? key, this.member}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  bool get isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final m = widget.member!;
      _nameCtrl.text = m.name;
      _codeCtrl.text = m.displayCode;
      _phoneCtrl.text = m.phone ?? '';
      _emailCtrl.text = m.email ?? '';
      _collegeCtrl.text = m.college ?? '';
      _roleCtrl.text = m.role;
      _notesCtrl.text = m.privateNotes ?? '';
      _memberType = m.type;
      _startDate = m.startDate;
      _endDate = m.endDate;
      _dept = m.dept;
      _cohort = m.cohort;
      _project = m.project;
      _skillLevel = m.skillLevel;
      _commPref = m.commPreference;
      _avatarColor = m.avatarColor;
      _selectedSkills.addAll(m.skills);
      _selectedDomain.addAll(m.domainKnowledge);
    }
  }
  // Form Controllers
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _customSkillCtrl = TextEditingController();

  MemberType _memberType = MemberType.intern;
  DateTime? _startDate;
  DateTime? _endDate;
  String _dept = 'AI / ML';
  String? _cohort = 'Cohort 1';
  String? _project = 'IMAS Core';
  SkillLevel _skillLevel = SkillLevel.beginner;
  CommPreference _commPref = CommPreference.email;
  Color _avatarColor = purpleColor;

  final List<String> _skills = ['Python', 'Flutter', 'C/C++', 'FastAPI', 'TensorRT', 'React', 'PostgreSQL', 'Docker', 'Git'];
  final List<String> _selectedSkills = [];
  final List<String> _domainKnowledge = ['Computer Vision', 'Edge AI', 'Embedded', 'ML Ops'];
  final List<String> _selectedDomain = [];

  final List<Color> _colorOptions = [purpleColor, blueColor, okColor, gold, warnColor, dangerColor];

  void _saveMember() {
    if (_nameCtrl.text.isEmpty || _dept.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill Name and Department.')));
      return;
    }

    final memberData = MemberModel(
      id: isEditing ? widget.member!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text,
      displayCode: _codeCtrl.text.isNotEmpty ? _codeCtrl.text : _nameCtrl.text.substring(0, 2).toUpperCase(),
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      college: _collegeCtrl.text,
      startDate: _startDate,
      endDate: _endDate,
      dept: _dept,
      cohort: _cohort,
      project: _project,
      type: _memberType,
      role: _roleCtrl.text.isNotEmpty ? _roleCtrl.text : (_memberType == MemberType.intern ? 'Intern' : 'Employee'),
      skills: _selectedSkills,
      domainKnowledge: _selectedDomain,
      skillLevel: _skillLevel,
      privateNotes: _notesCtrl.text,
      commPreference: _commPref,
      avatarColor: _avatarColor,
    );

    if (isEditing) {
      context.read<TeamProvider>().updateMember(memberData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member "${memberData.name}" updated successfully.')));
    } else {
      context.read<TeamProvider>().addMember(memberData);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member "${memberData.name}" added successfully.')));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
      appBar: JarvisTopbar(
        title: isEditing ? 'UPDATE TEAM MEMBER' : 'ADD TEAM MEMBER',
        actions: [
          ElevatedButton(
            onPressed: _saveMember,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(isEditing ? 'UPDATE MEMBER' : 'ADD MEMBER'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildMemberTypeSelector(),
            const SizedBox(height: 24),
            isDesktop ? _buildTwoColumnLayout() : _buildStackedLayout(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTypeSelector() {
    return Row(
      children: MemberType.values.map((type) {
        final isSelected = _memberType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () => setState(() => _memberType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? goldDim : bgSecondary,
                  border: Border.all(color: isSelected ? gold : goldLine),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    Icon(
                      type == MemberType.intern ? Icons.school : (type == MemberType.employee ? Icons.badge : Icons.stars),
                      color: isSelected ? gold : textDim,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.name.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? gold : textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
    final projects = context.watch<ProjectProvider>().projects;
    final projectNames = projects.map((p) => p.name).toList();

    return Column(
      children: [
        _buildCard(
          title: 'BASIC DETAILS',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField('Full Name', _nameCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Code', _codeCtrl, hint: 'RK')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Phone', _phoneCtrl)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Email', _emailCtrl)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('College / Institution', _collegeCtrl),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Start Date', _startDate, (d) => setState(() => _startDate = d))),
                  if (_memberType == MemberType.intern) ...[
                    const SizedBox(width: 16),
                    Expanded(child: _buildDatePicker('End Date', _endDate, (d) => setState(() => _endDate = d))),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown('Department', _dept, ['AI / ML', 'EMBEDDED SYSTEMS', 'FULLSTACK / APP', 'OPERATIONS'], (v) => setState(() => _dept = v!)),
                  ),
                  if (_memberType == MemberType.intern) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown('Cohort', _cohort, ['Cohort 1', 'Cohort 2', 'Cohort 3'], (v) => setState(() => _cohort = v)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown('Assigned Project', _project, projectNames.isEmpty ? ['No Projects'] : projectNames, (v) => setState(() => _project = v), hint: 'Select Project'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'WORK INFO',
          child: _buildTextField('Role / Designation', _roleCtrl, hint: _memberType == MemberType.coreTeam ? 'Fixed: Operations Manager' : 'E.g., Senior Developer'),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        _buildCard(
          title: 'SKILLS KNOWN',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Programming / Technical'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._skills.map((s) => _buildChip(s, _selectedSkills.contains(s), () {
                    setState(() {
                      if (_selectedSkills.contains(s)) _selectedSkills.remove(s);
                      else _selectedSkills.add(s);
                    });
                  })),
                  _buildCustomSkillInput(),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Domain Knowledge'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _domainKnowledge.map((s) => _buildChip(s, _selectedDomain.contains(s), () {
                  setState(() {
                    if (_selectedDomain.contains(s)) _selectedDomain.remove(s);
                    else _selectedDomain.add(s);
                  });
                })).toList(),
              ),
              const SizedBox(height: 20),
              _buildLabel('Skill Level'),
              Row(
                children: SkillLevel.values.map((lvl) {
                  final isSelected = _skillLevel == lvl;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _skillLevel = lvl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? goldDim : bgTertiary,
                            border: Border.all(color: isSelected ? gold : Colors.transparent),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(lvl.name.toUpperCase(), style: TextStyle(color: isSelected ? gold : textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'SETTINGS & PREFERENCES',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Private Notes'),
              _buildTextField('', _notesCtrl, maxLines: 2, hint: 'Internal assessment...'),
              const SizedBox(height: 20),
              _buildLabel('Communication Preference'),
              _buildDropdown('', _commPref.name, CommPreference.values.map((v) => v.name).toList(), (v) => setState(() => _commPref = CommPreference.values.firstWhere((e) => e.name == v)), hint: 'Select Preference'),
              const SizedBox(height: 20),
              _buildLabel('Avatar Color'),
              Row(
                children: _colorOptions.map((c) {
                  final isSelected = _avatarColor == c;
                  return InkWell(
                    onTap: () => setState(() => _avatarColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                        boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bgSecondary, borderRadius: BorderRadius.circular(6), border: Border.all(color: goldLine)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.orbitron(color: gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    if (text.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: textDim, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
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
        ),
      ],
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

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
            if (picked != null) onSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(date), style: TextStyle(color: date == null ? textDim : textPrimary, fontSize: 12)),
                const Icon(Icons.calendar_today, size: 14, color: gold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? goldDim : bgTertiary,
          border: Border.all(color: isSelected ? gold : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? gold : textDim, fontSize: 10, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildCustomSkillInput() {
    return Container(
      width: 100,
      height: 30,
      child: TextField(
        controller: _customSkillCtrl,
        style: const TextStyle(fontSize: 10, color: textPrimary),
        decoration: InputDecoration(
          hintText: '+ Skill',
          hintStyle: const TextStyle(fontSize: 10, color: textDim),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: goldLine)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onSubmitted: (val) {
          if (val.isNotEmpty) {
            setState(() {
              _skills.add(val);
              _selectedSkills.add(val);
              _customSkillCtrl.clear();
            });
          }
        },
      ),
    );
  }
}
