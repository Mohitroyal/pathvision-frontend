import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void init(String baseUrl, Map<String, dynamic> providers) {
    if (ApiService.useMockData) return;
    _socket = IO.io(baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('Connected to System Event Engine');
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Disconnected from System Event Engine');
      notifyListeners();
    });

    // Central Event Listener
    _socket!.on('system_event', (data) {
      final String event = data['event'];
      debugPrint('System Event Received: $event');
      
      // Notify relevant providers based on event type
      if (event.startsWith('task_')) {
        providers['task']?.fetchTasks();
      }
      if (event.startsWith('reminder_')) {
        providers['reminder']?.fetchReminders();
      }
      if (event.startsWith('milestone_')) {
        providers['milestone']?.fetchMilestones();
      }
      if (event.startsWith('risk_')) {
        providers['risk']?.fetchRisks();
      }
      
      // Always refresh dashboard on any major event
      providers['dashboard']?.fetchData();
    });
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }
}
