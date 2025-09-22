import 'package:flutter/material.dart';

class Transaction {
  String type; // "Spesa" o "Entrata"
  double amount;
  String category;
  String? note;

  Transaction({
    required this.type,
    required this.amount,
    required this.category,
    this.note,
  });
}

class EventProvider extends ChangeNotifier {
  // Transazioni per conto e giorno
  Map<String, Map<DateTime, List<Transaction>>> _transactionsByAccount = {};
  // Promemoria per conto e giorno
  Map<String, Map<DateTime, List<Map<String, dynamic>>>> _remindersByAccount = {};

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  // TRANSAZIONI
  List<Transaction> getTransactionsForDay(String accountId, DateTime day) {
    final normalized = _normalizeDate(day);
    return _transactionsByAccount[accountId]?[normalized] ?? [];
  }

  void addTransaction(String accountId, DateTime day, Transaction transaction) {
    final normalized = _normalizeDate(day);
    _transactionsByAccount[accountId] ??= {};
    _transactionsByAccount[accountId]![normalized] ??= [];
    _transactionsByAccount[accountId]![normalized]!.add(transaction);
    notifyListeners();
  }

  void editTransaction(String accountId, DateTime day, int index, Transaction transaction) {
    final normalized = _normalizeDate(day);
    if (_transactionsByAccount[accountId]?[normalized] != null &&
        index < _transactionsByAccount[accountId]![normalized]!.length) {
      _transactionsByAccount[accountId]![normalized]![index] = transaction;
      notifyListeners();
    }
  }

  void deleteTransaction(String accountId, DateTime day, int index) {
    final normalized = _normalizeDate(day);
    if (_transactionsByAccount[accountId]?[normalized] != null &&
        index < _transactionsByAccount[accountId]![normalized]!.length) {
      _transactionsByAccount[accountId]![normalized]!.removeAt(index);
      notifyListeners();
    }
  }

  // PROMEMORIA
  List<Map<String, dynamic>> getRemindersForDay(String accountId, DateTime day) {
    final normalized = _normalizeDate(day);
    return _remindersByAccount[accountId]?[normalized] ?? [];
  }

  void addReminder(String accountId, DateTime day, String text) {
    final normalized = _normalizeDate(day);
    _remindersByAccount[accountId] ??= {};
    _remindersByAccount[accountId]![normalized] ??= [];
    _remindersByAccount[accountId]![normalized]!.add({"text": text, "done": false});
    notifyListeners();
  }

  void toggleReminder(String accountId, DateTime day, int index, bool? value) {
    final normalized = _normalizeDate(day);
    if (_remindersByAccount[accountId]?[normalized] != null &&
        index < _remindersByAccount[accountId]![normalized]!.length) {
      _remindersByAccount[accountId]![normalized]![index]["done"] = value ?? false;
      notifyListeners();
    }
  }

  Map<DateTime, List<Map<String, dynamic>>> getAllRemindersForAccount(String accountId) {
    return _remindersByAccount[accountId] ?? {};
  }
}

