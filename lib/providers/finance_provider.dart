// lib/providers/finance_provider.dart

import '../services/supabase_service.dart';
import '../realtime/realtime_service.dart';

class FinanceProvider with ChangeNotifier {
  final RealtimeService _realtime = RealtimeService();
  
  List<Transaction> _transactions = [];
  List<Debt> _debts = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions..sort((a, b) => b.date.compareTo(a.date));
  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;

  FinanceProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();

    // Stream Transactions
    _realtime.financeStream.listen((data) {
      _transactions = data.map((item) => Transaction.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    });

    // Stream Debts
    _realtime.client.from('debts').stream(primaryKey: ['id']).listen((data) {
      _debts = data.map((item) => Debt.fromMap(item)).toList();
      notifyListeners();
    });
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  double get netBalance => totalIncome - totalExpense;

  Future<void> addTransaction(Transaction t) async {
    try {
      await Supabase.instance.client.from('finance_transactions').insert(t.toMap());
    } catch (e) {
      debugPrint("Error adding transaction: $e");
    }
  }

  Future<void> addDebt(Debt d) async {
    try {
      await Supabase.instance.client.from('debts').insert(d.toMap());
    } catch (e) {
      debugPrint("Error adding debt: $e");
    }
  }
}
