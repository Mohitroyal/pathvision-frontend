// lib/providers/project_provider.dart

import '../services/supabase_service.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final String status;
  final bool isPinned;

  Project({
    required this.id, 
    required this.name, 
    this.description, 
    this.status = 'active',
    this.isPinned = false,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'].toString(),
      name: map['name'] ?? 'Untitled',
      description: map['description'],
      status: map['status'] ?? 'active',
      isPinned: map['is_pinned'] ?? false,
    );
  }
}

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  ProjectProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();

    SupabaseService.stream('projects').listen((data) {
      _projects = data.map((item) => Project.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addProject({
    required String name, 
    required String description,
    required String status,
    required String type,
    required DateTime startDate,
    required DateTime deadline,
    required List<String> techStack,
    required List<String> milestones,
  }) async {
    try {
      await SupabaseService.post('projects', {
        'name': name,
        'description': description,
        'status': status,
        'start_date': startDate.toIso8601String(),
        'end_date': deadline.toIso8601String(),
        'metadata': {
          'type': type,
          'tech_stack': techStack,
        },
      });
      // Milestones are handled by a separate stream, but we could add logic here if needed
    } catch (e) {
      debugPrint("Error adding project: $e");
    }
  }

  Future<void> updateProject(String id, String name, String? description, String status, List<String> milestones) async {
    try {
      await SupabaseService.update('projects', id, {
        'name': name,
        'description': description,
        'status': status,
      });
    } catch (e) {
      debugPrint("Error updating project: $e");
    }
  }

  Future<void> togglePin(String id) async {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index != -1) {
      try {
        final newPinnedStatus = !_projects[index].isPinned;
        await SupabaseService.update('projects', id, {"is_pinned": newPinnedStatus});
      } catch (e) {
        debugPrint("Error toggling project pin: $e");
      }
    }
  }
}
