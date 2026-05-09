import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';
import '../providers/team_provider.dart';
import '../models/team_model.dart';
import 'add_member_screen.dart';

enum TeamFilter { dept, project, cohorts }

class TeamScreen extends StatefulWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  TeamFilter _currentFilter = TeamFilter.dept;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _showAddMemberScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMemberScreen()),
    );
  }

  List<MemberModel> _filteredMembers(List<MemberModel> allMembers) {
    return allMembers.where((m) {
      final query = _searchQuery.toLowerCase();
      final nameMatch = m.name.toLowerCase().contains(query);
      final skillMatch = m.skills.any((s) => s.toLowerCase().contains(query));
      final deptMatch = m.dept.toLowerCase().contains(query);
      return nameMatch || skillMatch || deptMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: JarvisTopbar(
        title: 'TEAM & DEPARTMENTS',
        actions: [
          if (MediaQuery.of(context).size.width > 700) ...[
            _buildFilterButton('BY DEPT', TeamFilter.dept),
            const SizedBox(width: 8),
            _buildFilterButton('BY PROJECT', TeamFilter.project),
            const SizedBox(width: 8),
            _buildFilterButton('COHORTS', TeamFilter.cohorts),
          ],
          const SizedBox(width: 8),
          TopbarIconButton(
            onTap: _showAddMemberScreen,
            icon: Icons.add,
          ),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, teamProvider, child) {
          final members = _filteredMembers(teamProvider.members);
          return Column(
            children: [
              _buildSearchAndStats(teamProvider.members.length),
              Expanded(
                child: members.isEmpty 
                  ? const Center(child: Text('No team members found', style: TextStyle(color: textDim)))
                  : _buildDashboardGrid(members),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(String label, TeamFilter filter) {
    final isSelected = _currentFilter == filter;
    return InkWell(
      onTap: () => setState(() => _currentFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? goldDim : Colors.transparent,
          border: Border.all(color: isSelected ? gold : goldLine),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isSelected ? gold : textDim,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndStats(int totalMembers) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgTertiary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: goldLine),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'SEARCH TEAM...',
                      hintStyle: TextStyle(color: Color(0xFF6A6058), fontSize: 11),
                      prefixIcon: Icon(Icons.search, size: 16, color: Color(0xFF6A6058)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (!isMobile) ...[
                _buildStat('3', 'PROJECTS'),
                const SizedBox(width: 16),
              ],
              _buildStat(totalMembers.toString(), 'TEAM'),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                _buildStat('12', 'TASKS'),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (isMobile) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('BY DEPT', TeamFilter.dept),
                  const SizedBox(width: 8),
                  _buildFilterButton('BY PROJECT', TeamFilter.project),
                  const SizedBox(width: 8),
                  _buildFilterButton('COHORTS', TeamFilter.cohorts),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'ENGINEERING — PRODUCT DEPARTMENTS',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: textDim,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Expanded(child: Divider(indent: 10, color: goldLine)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(val, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w900, color: gold)),
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: textDim, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDashboardGrid(List<MemberModel> members) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200 ? 2 : 1;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 280,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) {
        return _DeptCard(member: members[index]);
      },
    );
  }
}

class _DeptCard extends StatefulWidget {
  final MemberModel member;
  const _DeptCard({Key? key, required this.member}) : super(key: key);

  @override
  State<_DeptCard> createState() => _DeptCardState();
}

class _DeptCardState extends State<_DeptCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // FORCE HARDCODED COLORS TO ELIMINATE NULL SUBTYPE ERRORS
    const Color accent = gold;
    const Color statusColor = okColor;
    const Color deptStatusColor = gold;
    
    final String dept = widget.member.dept ?? 'ENGINEERING';
    final String name = widget.member.name ?? 'CONTRIBUTOR';
    final String role = widget.member.role ?? 'MEMBER';
    final List<String> skills = widget.member.skills.isEmpty ? ['CORE'] : widget.member.skills;
    final String note = widget.member.privateNotes ?? 'NO NOTES';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? accent.withOpacity(0.5) : goldLine,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: accent.withOpacity(0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept.toUpperCase(),
                        style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w900, color: textPrimary, letterSpacing: 1),
                      ),
                      Text(
                        'PRODUCT DIVISION',
                        style: GoogleFonts.jetBrainsMono(fontSize: 9, color: textDim, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  _buildStatusBadge('OPERATIONAL', deptStatusColor),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, color: gold, size: 16),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMemberScreen(member: widget.member),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: accent.withOpacity(0.1),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(color: accent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                role,
                                style: const TextStyle(color: textDim, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusTag('ACTIVE', statusColor),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SKILLS',
                      style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w800, color: textDim, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) => _buildSkillChip(skill, accent)).toList(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: bgTertiary, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 12, color: gold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note,
                              style: const TextStyle(color: textDim, fontSize: 10, fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSkillChip(String skill, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Text(
        skill,
        style: TextStyle(color: accent.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }
}
