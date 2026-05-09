// lib/models/finance_model.dart

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final List<String> tags;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.tags = const [],
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'Untitled',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0,
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      date: map['date'] != null ? DateTime.parse(map['date']) : (map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now()),
      tags: map['category'] != null ? [map['category']] : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
      'category': tags.isNotEmpty ? tags.first : 'misc',
    };
  }
}

class Debt {
  final String id;
  final String personName;
  final double amount;
  final bool isOwedToMe; // true = to_receive, false = to_pay
  final DateTime dueDate;

  Debt({
    required this.id,
    required this.personName,
    required this.amount,
    required this.isOwedToMe,
    required this.dueDate,
  });

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id']?.toString() ?? '',
      personName: map['creditor_debtor'] ?? 'Unknown',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0,
      isOwedToMe: map['type'] == 'to_receive',
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creditor_debtor': personName,
      'amount': amount,
      'type': isOwedToMe ? 'to_receive' : 'to_pay',
      'due_date': dueDate.toIso8601String(),
    };
  }
}
