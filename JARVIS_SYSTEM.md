# JARVIS SYSTEM — AI Command Controller

## 🤖 What is JARVIS?

JARVIS is an **intelligent command execution system** that converts natural language input into structured, multi-module actions. It understands project management intent and automatically:

- Creates tasks across all modules
- Schedules time blocks
- Assigns team members
- Updates milestones
- Detects and escalates risks
- Optimizes workload distribution

---

## 🎯 Core Capabilities

### 1. **Natural Language Parsing**
Input: `"Create task to review IMAS, assign Ravi backend, deadline Friday"`

Automatically generates:
- ✅ Task creation
- ✅ Team assignment
- ✅ Deadline tracking
- ✅ Risk detection (tight deadline)

### 2. **Multi-Action Execution**
Single command → Multiple coordinated actions across:
- Tasks (Kanban)
- Planner (Time blocking)
- Milestones (Gantt)
- Risks (Risk Radar)
- Team assignments

### 3. **Intelligent Planning**
Auto-breaks work into:
- Subtasks with estimated duration
- Schedule blocks (morning/afternoon/evening)
- Risk factors (deadline, overload, dependencies)
- Workload distribution

### 4. **Project Manager Thinking**
Understands:
- Urgency levels (urgent/critical/asap)
- Deadline proximity (today/Friday/next week)
- Team capacity and roles
- Dependency chains

---

## 🚀 Usage

### Option 1: Use the Command Interface Widget

```dart
// Add to any screen
JarvisCommandInterface(
  fullScreen: false,  // Embedded panel
)

// Or as full screen
JarvisCommandInterface(
  fullScreen: true,  // Standalone screen
)
```

### Option 2: Programmatic Execution

```dart
import 'services/jarvis_system.dart';
import 'providers/jarvis_provider.dart';

// Parse user input
final result = JarvisSystem.parseInput(
  'Create task "Review IMAS", assign Ravi, deadline Friday'
);

// Execute actions
final jarvis = context.read<JarvisProvider>();
await jarvis.executeActions(result);
```

### Option 3: Add to AI Screen

Integrate into the JARVIS AI assistant screen:

```dart
// In ai_screen.dart
_buildCommandCenter() {
  return const JarvisCommandInterface(fullScreen: false);
}
```

---

## 📝 Command Examples

### Task Creation
```
- "Create task to review API documentation"
- "Add urgent task: fix authentication bug"
- "New task for Q2 goals planning, high priority"
```

### Assignments
```
- "Assign Ravi backend development"
- "Task for Priya: design review, tomorrow"
- "Give Arjun the TensorRT optimization work"
```

### Scheduling
```
- "Schedule meeting review tomorrow afternoon"
- "Block 2 hours today for testing"
- "Plan standup for Friday morning"
```

### Milestones
```
- "Mark MVP Launch as completed"
- "Phase 1 is in progress"
- "Beta Testing milestone → planned"
```

### Risks
```
- "Alert: tight deadline on IMAS"
- "Monitor: Ravi's workload is high"
- "Flag: dependency delay risk"
```

### Multi-Action (Recommended)
```
- "Finish IMAS MVP by Friday, assign Ravi backend, schedule review tomorrow, flag delay risk"
- "Create 3 subtasks for Phase 2, assign to team, deadline end of month, high priority"
```

---

## 🧠 System Architecture

### Files Created

```
lib/
├── models/
│   └── jarvis_action_model.dart          # Action & planning data models
├── providers/
│   └── jarvis_provider.dart              # State management & execution
├── services/
│   └── jarvis_system.dart                # NLP parsing & command logic
└── widgets/
    └── jarvis_command_interface.dart    # UI component
```

### Data Flow

```
User Input
    ↓
JarvisSystem.parseInput()  (NLP parsing)
    ↓
JarvisExecutionResult     (structured actions)
    ↓
JarvisProvider.executeActions()  (execution engine)
    ↓
Task/Milestone/Risk/Planner modules
    ↓
App state updates
```

---

## 🔧 Action Types

```dart
enum JarvisActionType {
  createTask,           // Create task in Kanban
  assignMember,         // Assign team member
  scheduleBlock,        // Add time block
  createReminder,       // Set reminder
  updateMilestone,      // Update milestone status
  createRisk,           // Escalate risk
  optimizeSchedule,     // Rebalance time blocks
  convertNoteToTask,    // Brain dump → task
  reassignTask,         // Reassign task
  addDependency,        // Link task dependency
}
```

---

## 📊 Output Format

JARVIS returns structured JSON:

```json
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
  },
  "success": true,
  "executedAt": "2026-05-04T14:32:00Z"
}
```

---

## 🎯 Key Features

### 1. Intent Detection
Automatically identifies:
- Task creation intent
- Milestone updates
- Risk escalation
- Schedule optimization
- Multi-action workflows

### 2. Smart Parsing
Extracts:
- Priority (high/medium/low)
- Deadline (today/Friday/next week)
- Team member names
- Roles (backend/frontend/devops/qa)
- Time slots (morning/afternoon/evening)

### 3. Risk Detection
Automatically creates risks for:
- Tight deadlines (< 3 days)
- Workload overload (> 20 hrs/week)
- Dependency delays
- Critical milestones

### 4. Execution Engine
Safely executes actions:
- Validates data before execution
- Updates all related modules
- Maintains state consistency
- Logs execution history

### 5. History Tracking
Keeps record of:
- All executed commands
- Action results
- Timestamps
- Success/failure status

---

## 💡 Advanced Usage

### Local Heuristic Parsing (Current)
Uses keyword matching and pattern extraction:
- Fast (no API calls)
- Works offline
- Good for common patterns
- Limited to trained phrases

### Production: LLM Integration
Upgrade with Groq/OpenAI:

```dart
// In jarvis_system.dart
static Future<JarvisExecutionResult> parseWithLLM(String input) async {
  final response = await axios.post(
    'https://api.groq.com/openai/v1/chat/completions',
    {
      'model': 'mixtral-8x7b-32768',
      'messages': [
        {'role': 'system', 'content': JarvisSystem.systemPrompt},
        {'role': 'user', 'content': input}
      ],
      'temperature': 0.2
    },
    headers: {'Authorization': 'Bearer YOUR_API_KEY'}
  );
  
  return JarvisExecutionResult.fromJson(jsonDecode(response.data));
}
```

---

## 🔌 Integration Checklist

- ✅ JARVIS models created
- ✅ JARVIS provider registered in main.dart
- ✅ Command interface widget built
- ✅ Action execution engine implemented
- ✅ History tracking enabled
- ✅ UI component ready to use

### To Use JARVIS:

1. Add to UI:
   ```dart
   const JarvisCommandInterface()
   ```

2. Or call programmatically:
   ```dart
   final result = JarvisSystem.parseInput(input);
   await jarvis.executeActions(result);
   ```

3. Watch execution results in history

---

## 🚨 Common Commands

| Input | Actions Generated |
|-------|-------------------|
| "Create task review API" | Task created, medium priority |
| "Assign Ravi backend, Friday" | Task assigned to Ravi, deadline set |
| "Schedule meeting tomorrow" | Time block added to planner |
| "Mark MVP done" | Milestone status → done |
| "Tight deadline risk" | Risk created with high severity |
| "Complete work, assign team, risk" | Multi-action: task + assignment + risk |

---

## 📈 Roadmap

**Phase 1 (Current):**
- ✅ Local heuristic parsing
- ✅ Multi-action execution
- ✅ UI command interface
- ✅ History tracking

**Phase 2 (Next):**
- LLM integration (Groq/OpenAI)
- Voice input support
- Slack/Teams integration
- Webhook execution

**Phase 3 (Future):**
- Predictive scheduling
- Auto-risk detection
- Team capacity modeling
- API integrations

---

## 🎓 Learning Resources

- Read `lib/models/jarvis_action_model.dart` for data structures
- Check `lib/services/jarvis_system.dart` for parsing logic
- Review `lib/providers/jarvis_provider.dart` for execution
- Use `lib/widgets/jarvis_command_interface.dart` in your UI

---

## ✨ Ready to Use

JARVIS is **fully integrated and ready**. Simply:

1. Import the widget:
   ```dart
   import 'widgets/jarvis_command_interface.dart';
   ```

2. Add to your screen:
   ```dart
   const JarvisCommandInterface(fullScreen: false)
   ```

3. Start using natural language commands!

**Example:** "Create task review IMAS, assign Arjun, deadline Friday, high priority"

→ Automatically creates task, assigns member, sets deadline, escalates as high priority + risk alert ✅

---

**JARVIS ready for deployment.** 🚀
