import 'package:flutter/material.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';
import '../widgets/index.dart';

class CompanyIntelScreen extends StatelessWidget {
  const CompanyIntelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildOrgStructure(context),
              ),
              const SizedBox(width: Spacing.xl),
              Expanded(
                flex: 1,
                child: _buildCompanyHealth(context),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),
          _buildKnowledgeBaseGrid(context),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrgStructure(context),
          const SizedBox(height: Spacing.lg),
          _buildKnowledgeBaseGrid(context, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildOrgStructure(BuildContext context) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'ORG STRUCTURE'),
          const SizedBox(height: Spacing.md),
          _buildOrgItem(context, 'PathVision Innovations Pvt. Ltd.', true),
          _buildOrgSubItem(context, 'IMAS division', badgeText: 'AT RISK', badgeType: ChipType.warn),
          _buildOrgChildItem(context, 'Core System Team - Ravi K., Arjun M.'),
          _buildOrgChildItem(context, 'Edge AI Research - Priya S.'),
          _buildOrgChildItem(context, 'Fleet Integration - TBD'),
          _buildOrgSubItem(context, 'AgriPulse division', badgeText: 'ON TRACK', badgeType: ChipType.ok),
          _buildOrgChildItem(context, 'Product Team - Priya S.'),
          _buildOrgChildItem(context, 'Data Science - Nikhil K.'),
          _buildOrgSubItem(context, 'Decarbonization Lab', badgeText: 'PLANNING', badgeType: ChipType.blue),
          _buildOrgChildItem(context, 'Analytics Module - Nikhil K.'),
        ],
      ),
    );
  }

  Widget _buildOrgItem(BuildContext context, String title, bool isRoot) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.business, color: gold, size: 16),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: goldLight, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOrgSubItem(BuildContext context, String title, {String? badgeText, ChipType? badgeType}) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          const Icon(Icons.circle, color: textDim, size: 6),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          if (badgeText != null && badgeType != null) ...[
            const SizedBox(width: 8),
            JarvisChip(label: badgeText, type: badgeType),
          ]
        ],
      ),
    );
  }

  Widget _buildOrgChildItem(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 48.0, top: 4.0, bottom: 4.0),
      child: Row(
        children: [
          const Icon(Icons.remove, color: textDim, size: 12),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(color: textDim, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildCompanyHealth(BuildContext context) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'COMPANY HEALTH'),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildHealthKpi(context, '3', 'ACTIVE PROJECTS')),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildHealthKpi(context, '42', 'TOTAL TASKS')),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _buildHealthKpi(context, '8', 'TEAM MEMBERS')),
              const SizedBox(width: Spacing.md),
              Expanded(child: _buildHealthKpi(context, '61%', 'OVERALL PROGRESS', color: gold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthKpi(BuildContext context, String value, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: bgTertiary,
        borderRadius: BorderRadius.circular(BorderValues.sm),
        border: Border.all(color: goldLine, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color ?? textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeBaseGrid(BuildContext context, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionTitle(title: 'KNOWLEDGE BASE'),
            ElevatedButton.icon(
              onPressed: () {
                _showAddEntryDialog(context);
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('ADD ENTRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: bgPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        if (isMobile)
          Column(
            children: [
              _buildKnowledgeCard(context, 'PERICLES Algorithm', 'Percentage eye closure metric threshold. Micro-sleep closure for >3 seconds = fatigue alert.', ['IMAS', 'AI/ML']),
              const SizedBox(height: Spacing.md),
              _buildKnowledgeCard(context, 'AIS-140 Compliance', 'Mandatory GPS tracking standard for Indian commercial vehicles per MORTH.', ['COMPLIANCE', 'IMAS']),
            ],
          )
        else
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: Spacing.md,
            mainAxisSpacing: Spacing.md,
            shrinkWrap: true,
            childAspectRatio: 1.8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildKnowledgeCard(context, 'PERICLES Algorithm', 'Percentage eye closure metric threshold. Micro-sleep closure for >3 seconds = fatigue alert.', ['IMAS', 'AI/ML']),
              _buildKnowledgeCard(context, 'AIS-140 Standard', 'Mandatory GPS tracking for Indian commercial vehicles per MORTH. IMAS must comply.', ['COMPLIANCE', 'IMAS']),
              _buildKnowledgeCard(context, 'TensorRT INT8', 'Quantization for edge inference. Target models on Jetson Orin Nano with >25 FPS.', ['EDGE AI', 'PERF']),
            ],
          ),
      ],
    );
  }

  Widget _buildKnowledgeCard(BuildContext context, String title, String description, List<String> tags) {
    return JarvisCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: goldLight, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: Spacing.xs),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: textDim, fontSize: 11),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: tags.map((tag) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: goldLine),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(tag, style: const TextStyle(color: textDim, fontSize: 8)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgTertiary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: goldLine)),
        title: const Text('ADD INTEL ENTRY', style: TextStyle(fontFamily: 'Orbitron', fontSize: 14, color: gold, letterSpacing: 2)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter technical detail or company insight...',
            hintStyle: TextStyle(color: textDim, fontSize: 12),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: goldLine)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: gold)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: textDim))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to Knowledge Base: ${controller.text}'), backgroundColor: gold));
              Navigator.pop(ctx);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
