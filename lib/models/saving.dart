class Saving {
  String id;
  String accountId;       // Collegamento all’account
  String title;           // Obiettivo del salvadanaio
  double targetAmount;    // Totale da risparmiare
  double currentAmount;   // Somma già versata
  DateTime? deadline;     // Data entro cui raggiungere obiettivo
  String? frequency;      // "settimanale", "bisettimanale", "mensile"

  Saving({
    required this.id,
    required this.accountId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.frequency,
  });
}
