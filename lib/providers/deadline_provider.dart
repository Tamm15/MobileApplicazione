import 'package:flutter/material.dart';
import '../models/deadline.dart';

class DeadlineProvider extends ChangeNotifier {
  final List<Deadline> _deadlines = [];

  List<Deadline> get deadlines => _deadlines;

  // Aggiunge una scadenza
  void addDeadline(String title, double amount, DateTime date) {
    final newDeadline = Deadline(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: date,
    );
    _deadlines.add(newDeadline);
    notifyListeners();
  }

  // Restituisce le scadenze per un giorno specifico
  List<Deadline> getDeadlinesForDay(DateTime day) {
    return _deadlines.where((d) =>
      d.date.year == day.year &&
      d.date.month == day.month &&
      d.date.day == day.day
    ).toList();
  }

  // Segna come pagata / non pagata
  void togglePaid(String id) {
    final index = _deadlines.indexWhere((d) => d.id == id);
    if (index != -1) {
      _deadlines[index].paid = !_deadlines[index].paid;
      notifyListeners();
    }
  }
}
