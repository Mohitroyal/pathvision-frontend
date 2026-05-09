// lib/services/jarvis_system.dart

import '../models/jarvis_action_model.dart';

/// JARVIS System Controller
/// Parses natural language inputs and generates structured actions
class JarvisSystem {
  static const String systemPrompt = '''
You are JARVIS — an autonomous AI system controller for a full-stack productivity platform.

Your job is to:
- Understand user input dynamically
- Convert it into structured executable actions
- Plan tasks, schedules, risks, and assignments
- Control all modules of the system intelligently

SYSTEM MODULES YOU CONTROL:
- tasks (kanban system)
- planner (daily scheduler / time blocking)
- projects
- milestones (gantt timeline)
- risks (risk radar)
- reminders
- team & departments
- brain dump (notes → tasks)

CORE INTELLIGENCE RULES:
- DO NOT use fixed schemas
- DO NOT limit to single intent
- ALWAYS break complex input into multiple actions
- INFER missing fields (deadline, priority, duration)
- THINK like a project manager
- PRIORITIZE urgency, deadlines, and workload balance

OUTPUT FORMAT (STRICT — JSON ONLY):
Return ONLY valid JSON, no other text:

{
  "intent": "...",
  "actions": [
    {
      "type": "...",
      "module": "...",
      "data": { }
    }
  ],
  "planning": {
    "subtasks": [],
    "schedule": [],
    "risks": []
  }
}

ACTION TYPES (EXTENSIBLE — NOT LIMITED):
- create_task
- assign_member
- schedule_block
- create_reminder
- update_milestone
- create_risk
- optimize_schedule
- convert_note_to_task
- reassign_task
- add_dependency

PLANNING LOGIC:
If input involves work:
- Break into subtasks
- Estimate durations
- Suggest time blocks
- Detect dependencies
- Assign priority automatically

RISK DETECTION RULES:
If ANY condition exists:
- tight deadline
- overloaded person
- dependency delays
→ ADD create_risk action with severity: "high"

SCHEDULING RULES:
If time/date exists:
- Create schedule blocks
- Avoid overlaps
- Distribute workload intelligently

TEAM LOGIC:
If person mentioned:
- Assign tasks
- Estimate workload impact

OUTPUT RULES:
- NO explanations
- NO markdown
- ONLY JSON
- MUST be parseable

Example:
Input: "Finish IMAS MVP by Friday, assign Ravi backend, schedule review tomorrow, monitor delay risk"

Output:
{
  "intent": "multi_action_execution",
  "actions": [
    {
      "type": "create_task",
      "module": "tasks",
      "data": {
        "title": "Complete IMAS MVP",
        "deadline": "Friday",
        "priority": "high"
      }
    },
    {
      "type": "assign_member",
      "module": "tasks",
      "data": {
        "member": "Ravi",
        "role": "backend"
      }
    },
    {
      "type": "schedule_block",
      "module": "planner",
      "data": {
        "title": "Review Meeting",
        "time": "tomorrow"
      }
    },
    {
      "type": "create_risk",
      "module": "risks",
      "data": {
        "reason": "tight deadline",
        "severity": "high"
      }
    }
  ],
  "planning": {
    "subtasks": [
      {"title": "Backend work", "duration": "3h"},
      {"title": "Testing", "duration": "2h"}
    ],
    "schedule": [
      {"time": "9-12", "task": "Backend"},
      {"time": "2-4", "task": "Testing"}
    ],
    "risks": [
      {"type": "deadline_risk", "level": "high"}
    ]
  }
}
''';

  /// Parse natural language input into JARVIS actions
  /// This is a local parser - for production, integrate with LLM API
  static JarvisExecutionResult parseInput(String input) {
    try {
      // Local heuristic parsing
      final result = _parseLocalHeuristic(input);
      return result;
    } catch (e) {
      return JarvisExecutionResult.error('Failed to parse input: $e');
    }
  }

  static JarvisExecutionResult _parseLocalHeuristic(String input) {
    final lowerInput = input.toLowerCase();
    final actions = <JarvisAction>[];
    final subtasks = <JarvisSubtask>[];
    final scheduleBlocks = <JarvisScheduleBlock>[];
    final risks = <JarvisRisk>[];

    String intent = 'simple_action';

    // TASK CREATION
    if (_matches(lowerInput, ['create', 'add', 'new', 'task', 'todo'])) {
      intent = 'task_creation';
      final title = _extractPhrase(input, ['task', 'todo', 'create'], 40);
      actions.add(JarvisAction(
        type: JarvisActionType.createTask,
        module: 'tasks',
        data: {
          'title': title,
          'priority': _extractPriority(input),
          'deadline': _extractDeadline(input),
        },
      ));

      // Detect subtasks
      final subLines = input.split(RegExp(r'[,;]'));
      for (final line in subLines.skip(1).take(2)) {
        if (line.trim().isNotEmpty) {
          subtasks.add(JarvisSubtask(title: line.trim(), duration: '1h'));
        }
      }
    }

    // MILESTONE UPDATE
    if (_matches(lowerInput, ['milestone', 'phase', 'done', 'complete', 'finished'])) {
      intent = 'milestone_update';
      final status = _extractStatus(input);
      actions.add(JarvisAction(
        type: JarvisActionType.updateMilestone,
        module: 'milestones',
        data: {
          'status': status,
          'title': _extractPhrase(input, ['milestone', 'phase'], 50),
        },
      ));
    }

    // ASSIGNMENT
    if (_matches(lowerInput, ['assign', 'to', 'for'])) {
      final member = _extractMemberName(input);
      if (member.isNotEmpty) {
        actions.add(JarvisAction(
          type: JarvisActionType.assignMember,
          module: 'tasks',
          data: {'member': member, 'role': _extractRole(input)},
        ));
      }
    }

    // SCHEDULING
    if (_matches(lowerInput, ['schedule', 'block', 'tomorrow', 'today', 'meeting', 'review'])) {
      intent = 'schedule_planning';
      final time = _extractTime(input);
      scheduleBlocks.add(JarvisScheduleBlock(
        time: time,
        task: _extractPhrase(input, ['schedule', 'meeting'], 40),
      ));
      actions.add(JarvisAction(
        type: JarvisActionType.scheduleBlock,
        module: 'planner',
        data: {'time': time, 'title': _extractPhrase(input, ['schedule', 'meeting'], 40)},
      ));
    }

    // RISK DETECTION
    if (_matches(lowerInput, ['risk', 'delay', 'overload', 'tight', 'urgent', 'critical'])) {
      risks.add(JarvisRisk(
        type: 'workload_risk',
        reason: _extractPhrase(input, ['risk', 'delay'], 60),
        level: _detectRiskLevel(input),
      ));
      actions.add(JarvisAction(
        type: JarvisActionType.createRisk,
        module: 'risks',
        data: {
          'reason': _extractPhrase(input, ['risk', 'delay'], 60),
          'severity': _detectRiskLevel(input),
        },
      ));
    }

    // MULTI-ACTION DETECTION
    if (actions.length > 1) {
      intent = 'multi_action_execution';
    }

    return JarvisExecutionResult(
      intent: intent,
      actions: actions,
      planning: JarvisPlanning(
        subtasks: subtasks,
        schedule: scheduleBlocks,
        risks: risks,
      ),
    );
  }

  static bool _matches(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }

  static String _extractPhrase(String text, List<String> after, int maxLen) {
    for (final keyword in after) {
      final idx = text.toLowerCase().indexOf(keyword);
      if (idx != -1) {
        var start = idx + keyword.length;
        while (start < text.length && text[start] == ' ') start++;
        var end = (start + maxLen).clamp(0, text.length);
        return text.substring(start, end).trim();
      }
    }
    return text.trim();
  }

  static String _extractMemberName(String text) {
    final members = ['ravi', 'arjun', 'priya', 'sanjay', 'deepak', 'amit'];
    for (final m in members) {
      if (text.toLowerCase().contains(m)) return m.capitalize();
    }
    return '';
  }

  static String _extractRole(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('backend')) return 'backend';
    if (lowerText.contains('frontend')) return 'frontend';
    if (lowerText.contains('devops')) return 'devops';
    if (lowerText.contains('qa')) return 'qa';
    if (lowerText.contains('design')) return 'design';
    return 'engineer';
  }

  static String _extractTime(String text) {
    if (text.toLowerCase().contains('tomorrow')) return 'tomorrow';
    if (text.toLowerCase().contains('today')) return 'today';
    if (text.toLowerCase().contains('morning')) return 'morning';
    if (text.toLowerCase().contains('afternoon')) return 'afternoon';
    if (text.toLowerCase().contains('evening')) return 'evening';
    return 'morning';
  }

  static String _extractPriority(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('urgent') || lowerText.contains('critical') || lowerText.contains('asap'))
      return 'high';
    if (lowerText.contains('low') || lowerText.contains('backlog'))
      return 'low';
    return 'medium';
  }

  static String _extractDeadline(String text) {
    if (text.toLowerCase().contains('friday')) return 'Friday';
    if (text.toLowerCase().contains('today')) return 'Today';
    if (text.toLowerCase().contains('tomorrow')) return 'Tomorrow';
    if (text.toLowerCase().contains('this week')) return 'Friday';
    if (text.toLowerCase().contains('next week')) return 'Next Friday';
    return '';
  }

  static String _extractStatus(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('done') || lowerText.contains('complete') || lowerText.contains('finished'))
      return 'done';
    if (lowerText.contains('progress') || lowerText.contains('ongoing'))
      return 'inProgress';
    if (lowerText.contains('planned') || lowerText.contains('upcoming'))
      return 'planned';
    return 'planned';
  }

  static String _detectRiskLevel(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('critical') || lowerText.contains('urgent'))
      return 'high';
    if (lowerText.contains('warning') || lowerText.contains('concern'))
      return 'medium';
    return 'low';
  }
}

extension _StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
