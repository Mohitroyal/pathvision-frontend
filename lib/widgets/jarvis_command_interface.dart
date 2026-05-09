// lib/widgets/jarvis_command_interface.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/jarvis_action_model.dart';
import '../providers/jarvis_provider.dart';
import '../services/jarvis_system.dart';
import '../theme/jarvis_colors.dart';
import '../theme/jarvis_theme.dart';

class JarvisCommandInterface extends StatefulWidget {
  final bool fullScreen;
  const JarvisCommandInterface({Key? key, this.fullScreen = false}) : super(key: key);

  @override
  State<JarvisCommandInterface> createState() => _JarvisCommandInterfaceState();
}

class _JarvisCommandInterfaceState extends State<JarvisCommandInterface> {
  late TextEditingController _commandInput;
  JarvisExecutionResult? _lastResult;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _commandInput = TextEditingController();
  }

  @override
  void dispose() {
    _commandInput.dispose();
    super.dispose();
  }

  void _executeCommand(String input) async {
    if (input.trim().isEmpty) return;

    final jarvisProvider = context.read<JarvisProvider>();
    final result = JarvisSystem.parseInput(input);

    setState(() => _lastResult = result);

    if (result.success && result.actions.isNotEmpty) {
      await jarvisProvider.executeActions(result);
      _showSuccessToast('${result.actions.length} action(s) executed.');
    }

    _commandInput.clear();
  }

  void _showSuccessToast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: incomeLight,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: bgPrimary,
          title: const Text('JARVIS COMMAND CENTER'),
          elevation: 0,
        ),
        body: _buildContent(isDesktop),
      );
    }

    return _buildContent(isDesktop);
  }

  Widget _buildContent(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCommandInput(),
          const SizedBox(height: Spacing.lg),
          if (_lastResult != null) ...[
            _buildResultPanel(_lastResult!),
            const SizedBox(height: Spacing.lg),
          ],
          _buildHistory(),
        ],
      ),
    );
  }

  Widget _buildCommandInput() {
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, 0),
            child: Text(
              'COMMAND INTERFACE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: textDim,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commandInput,
                  minLines: 2,
                  maxLines: 4,
                  style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Create task "Review IMAS", assign to Ravi, deadline Friday, high priority',
                    hintStyle: GoogleFonts.rajdhani(color: textDim, fontSize: 13),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: goldLine),
                      borderRadius: BorderRadius.circular(BorderValues.sm),
                    ),
                    contentPadding: const EdgeInsets.all(Spacing.md),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _executeCommand(_commandInput.text),
                        icon: const Icon(Icons.send),
                        label: const Text('EXECUTE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: bgPrimary,
                          padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    IconButton(
                      onPressed: () => _commandInput.clear(),
                      icon: const Icon(Icons.clear, color: gold),
                      tooltip: 'Clear',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPanel(JarvisExecutionResult result) {
    return Container(
      decoration: BoxDecoration(
        color: result.success ? incomeLight.withOpacity(0.08) : dangerColor.withOpacity(0.08),
        border: Border.all(color: result.success ? incomeLight : dangerColor),
        borderRadius: BorderRadius.circular(BorderValues.md),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? incomeLight : dangerColor,
                size: 16,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                result.success ? 'EXECUTION SUCCESSFUL' : 'EXECUTION FAILED',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  color: result.success ? incomeLight : dangerColor,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => _showDetails = !_showDetails),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    _showDetails ? 'HIDE' : 'DETAILS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: gold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Intent: ${result.intent}',
            style: GoogleFonts.rajdhani(fontSize: 12, color: textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${result.actions.length} action(s) queued',
            style: GoogleFonts.rajdhani(fontSize: 12, color: textMid),
          ),
          if (result.error != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              result.error!,
              style: GoogleFonts.rajdhani(fontSize: 11, color: dangerColor),
            ),
          ],
          if (_showDetails && result.actions.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            const Divider(color: goldLine, height: 1),
            const SizedBox(height: Spacing.md),
            Text(
              'ACTIONS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: textDim,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            for (int i = 0; i < result.actions.length; i++) ...[
              _buildActionTile(result.actions[i], i + 1),
              if (i != result.actions.length - 1) const SizedBox(height: Spacing.sm),
            ],
          ],
          if (_showDetails && result.planning.subtasks.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            const Divider(color: goldLine, height: 1),
            const SizedBox(height: Spacing.md),
            Text(
              'PLANNING',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: textDim,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            for (final st in result.planning.subtasks)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 4, color: gold),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        st.title,
                        style: GoogleFonts.rajdhani(fontSize: 11, color: textMid),
                      ),
                    ),
                    if (st.duration != null)
                      Text(
                        st.duration!,
                        style: GoogleFonts.jetBrainsMono(fontSize: 9, color: textDim),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile(JarvisAction action, int index) {
    final actionColor = _colorForActionType(action.type);
    return Container(
      decoration: BoxDecoration(
        color: bgQuaternary,
        border: Border.all(color: goldLine.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(BorderValues.sm),
      ),
      padding: const EdgeInsets.all(Spacing.sm),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.2),
              border: Border.all(color: actionColor),
              borderRadius: BorderRadius.circular(BorderValues.xs),
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  color: actionColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.type.value.replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: actionColor,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (action.data.containsKey('title'))
                  Text(
                    action.data['title'] as String,
                    style: GoogleFonts.rajdhani(fontSize: 10, color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            action.module.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              color: textDim,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    final jarvisProvider = context.watch<JarvisProvider>();
    final history = jarvisProvider.history.take(5).toList();

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Text(
            'No execution history',
            style: GoogleFonts.rajdhani(color: textDim, fontSize: 12),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT EXECUTIONS',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: textDim,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: Spacing.md),
        for (int i = 0; i < history.length; i++) ...[
          _buildHistoryItem(history[i], i),
          if (i != history.length - 1) const SizedBox(height: Spacing.sm),
        ],
      ],
    );
  }

  Widget _buildHistoryItem(JarvisExecutionResult result, int index) {
    return Container(
      decoration: BoxDecoration(
        color: bgTertiary,
        border: Border.all(color: goldLine.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(BorderValues.sm),
      ),
      padding: const EdgeInsets.all(Spacing.sm),
      child: Row(
        children: [
          Icon(
            result.success ? Icons.check : Icons.close,
            size: 12,
            color: result.success ? incomeLight : dangerColor,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.intent,
                  style: GoogleFonts.rajdhani(fontSize: 11, color: textPrimary, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${result.actions.length} actions • ${result.executedAt.hour}:${result.executedAt.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 8, color: textDim),
                ),
              ],
            ),
          ),
          Text(
            '${result.actions.length}',
            style: GoogleFonts.orbitron(fontSize: 11, color: gold, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Color _colorForActionType(JarvisActionType type) {
    switch (type) {
      case JarvisActionType.createTask:
        return blueColor;
      case JarvisActionType.updateMilestone:
        return purpleColor;
      case JarvisActionType.createRisk:
        return dangerColor;
      case JarvisActionType.scheduleBlock:
        return warnColor;
      case JarvisActionType.assignMember:
        return incomeLight;
      default:
        return gold;
    }
  }
}
