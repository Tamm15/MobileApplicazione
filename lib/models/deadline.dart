class Deadline {
  String id;
  String title;
  double amount;
  DateTime date;
  bool paid;

  Deadline({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.paid = false,
  });
}
