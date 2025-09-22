import 'package:flutter/material.dart';

class Saving {
  String id;
  String goal;             // Obiettivo (es. "Viaggio New York")
  double targetAmount;     // Importo da raggiungere
  double currentAmount;    // Totale versato finora
  DateTime? deadline;      // Data entro cui raggiungere l'obiettivo
  String? frequency;       // Frequenza: "settimanale", "bisettimanale", "mensile"

  Saving({
    required this.id,
    required this.goal,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.frequency,
  });
}

class SavingProvider extends ChangeNotifier {
  final List<Saving> _savings = [];

  List<Saving> get savings => _savings;

  // Aggiunge un nuovo salvadanaio
  void addSaving({
    required String goal,
    required double targetAmount,
    DateTime? deadline,
    String? frequency,
  }) {
    final newSaving = Saving(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goal: goal,
      targetAmount: targetAmount,
      deadline: deadline,
      frequency: frequency,
    );
    _savings.add(newSaving);
    notifyListeners();
  }

  // Aggiunge soldi a un salvadanaio esistente
  void addMoney(String savingId, double amount) {
    final saving = _savings.firstWhere((s) => s.id == savingId);
    saving.currentAmount += amount;
    notifyListeners();
  }

  // Modifica obiettivo e nome del salvadanaio
  void updateSavingGoal(String savingId, double newTargetAmount, {String? newGoal}) {
    final saving = _savings.firstWhere((s) => s.id == savingId);
    saving.targetAmount = newTargetAmount;
    if (newGoal != null) saving.goal = newGoal;
    notifyListeners();
  }

  // Calcola importo da versare in base a frequenza e data limite
  double calculateDepositAmount({
    required double targetAmount,
    required double currentAmount,
    required DateTime deadline,
    required String frequency, // "settimanale", "bisettimanale", "mensile"
  }) {
    final today = DateTime.now();
    final remaining = targetAmount - currentAmount;

    int intervals;

    switch (frequency) {
      case "settimanale":
        intervals = ((deadline.difference(today).inDays) / 7).ceil();
        break;
      case "bisettimanale":
        intervals = ((deadline.difference(today).inDays) / 14).ceil();
        break;
      case "mensile":
        intervals = ((deadline.difference(today).inDays) / 30).ceil();
        break;
      default:
        intervals = 1;
    }

    if (intervals <= 0) intervals = 1;
    return remaining / intervals;
  }
}
