// lib/providers/brain_dump_provider.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/brain_dump_model.dart';
import '../realtime/realtime_service.dart';

class BrainDumpProvider with ChangeNotifier {
  final RealtimeService _realtime = RealtimeService();
  final SupabaseClient _client = Supabase.instance.client;
  
  List<BrainDumpEntry> _entries = [];
  bool _isLoading = false;

  List<BrainDumpEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  BrainDumpProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();
    
    _realtime.brainDumpStream.listen((data) {
      _entries = data.map((item) => BrainDumpEntry.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Neural Brain Dump Sync Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addEntry(String content, {BrainDumpTag tag = BrainDumpTag.idea}) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    
    final newEntry = BrainDumpEntry(
      id: '', 
      content: trimmed,
      createdAt: DateTime.now(),
      tag: tag,
    );

    try {
      await _client.from('brain_dump').insert(newEntry.toMap());
    } catch (e) {
      debugPrint("Error adding brain dump: $e");
    }
  }

  Future<void> updateEntry(String id, {String? content, BrainDumpTag? tag}) async {
    try {
      final Map<String, dynamic> updates = {};
      if (content != null) updates['content'] = content;
      if (tag != null) updates['category'] = tag.name;
      
      await _client.from('brain_dump').update(updates).eq('id', id);
    } catch (e) {
      debugPrint("Error updating brain dump: $e");
    }
  }

  Future<void> markProcessed(String id) async {
    try {
      await _client.from('brain_dump').update({'is_processed': true}).eq('id', id);
    } catch (e) {
      debugPrint("Error marking brain dump processed: $e");
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _client.from('brain_dump').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error deleting brain dump: $e");
    }
  }
}
