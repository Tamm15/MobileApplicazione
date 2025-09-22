class Account {
  String id;          // ID univoco
  String name;        // Nome del conto 
  String description; // Descrizione (opzionale)
  double balance;     // Saldo del conto

  Account({
    required this.id,
    required this.name,
    this.description = "",
    this.balance = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'balance': balance,
    };
  }

  // Crea un Account da una mappa
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? "",
      balance: (map['balance'] != null)
          ? double.tryParse(map['balance'].toString()) ?? 0.0
          : 0.0,
    );
  }
}
