import 'package:flutter/material.dart';
import '../models/account.dart';

class AccountProvider extends ChangeNotifier {
  Account? currentAccount;

  // Lista di tutti gli account
  List<Account> accounts = [];

  AccountProvider() {
    // Account di default per test
    final defaultAccount = Account(
      id: "1",
      name: "Personale",
      description: "Conto personale",
      balance: 0.0,
    );
    accounts.add(defaultAccount);
    currentAccount = defaultAccount;
  }

  // Imposta l'account corrente
  void setCurrentAccount(Account account) {
    currentAccount = account;
    notifyListeners();
  }

  // Aggiungi un nuovo account
  void addAccount(String name, {String? description, double balance = 0.0}) {
    final newAccount = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description ?? "",
      balance: balance,
    );
    accounts.add(newAccount);
    currentAccount = newAccount;
    notifyListeners();
  }

  // Modifica un account esistente
  void updateAccount(Account account,
      {String? name, String? description, double? balance}) {
    if (name != null) account.name = name;
    if (description != null) account.description = description;
    if (balance != null) account.balance = balance;
    notifyListeners();
  }

  // Aggiorna il saldo dell'account (spesa/uscita)
  void updateBalance(String accountId, double amount, String type) {
    final accountIndex = accounts.indexWhere((acc) => acc.id == accountId);
    if (accountIndex == -1) return; // Account non trovato

    final account = accounts[accountIndex];

    if (type == "Spesa") {
      account.balance -= amount;
    } else if (type == "Entrata") {
      account.balance += amount;
    }

    // Aggiorna currentAccount se necessario
    if (currentAccount?.id == account.id) {
      currentAccount = account;
    }

    notifyListeners();
  }
}
