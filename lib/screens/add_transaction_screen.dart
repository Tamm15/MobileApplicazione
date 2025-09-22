import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../providers/category_provider.dart';
import '../providers/account_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final String accountId;
  final DateTime day;
  final Transaction? transaction;      // Transazione da modificare (null se nuova)
  final int? transactionIndex;         // Indice della transazione da modificare

  const AddTransactionScreen({super.key, 
    required this.accountId,
    required this.day,
    this.transaction,
    this.transactionIndex,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _type = "Spesa";
  String? _category;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note ?? "";
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _showAddCategoryDialog(CategoryProvider categoryProvider) async {
    String? newCat = await showDialog(
      context: context,
      builder: (_) {
        TextEditingController newCatController = TextEditingController();
        return AlertDialog(
          title: const Text("Nuova categoria"),
          content: TextField(
            controller: newCatController,
            decoration: const InputDecoration(hintText: "Nome categoria"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annulla")),
            TextButton(
                onPressed: () => Navigator.pop(context, newCatController.text),
                child: const Text("Aggiungi")),
          ],
        );
      },
    );

    if (newCat != null && newCat.isNotEmpty) {
      categoryProvider.addCategory(newCat);
      setState(() => _category = newCat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);

    // Categorie predefinite per le entrate
    final List<String> defaultIncomeCategories = ["Stipendio", "Regalo", "Extra"];

    return Scaffold(
      backgroundColor: Color.fromRGBO(154, 223, 255, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 1, 3)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.transaction != null ? "Modifica Transazione" : "Nuova Transazione",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildCard(
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Tipo",
                  ),
                  items: ["Spesa", "Entrata"]
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setState(() => _type = val!),
                ),
              ),

              // Categoria per Spesa o Entrata
              _buildCard(
                child: DropdownButtonFormField<String?>(
                  value: _category,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Categoria",
                  ),
                  hint: const Text("Seleziona categoria"),
                  items: [
                    if (_type == "Spesa")
                      ...categoryProvider.categories.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c))),
                    if (_type == "Entrata")
                      ...defaultIncomeCategories.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c))),
                    DropdownMenuItem(
                      value: "__add_new__",
                      child: Row(
                        children: const [
                          Icon(Icons.add, size: 18, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text("Aggiungi nuova categoria",
                              style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val == "__add_new__") {
                      _showAddCategoryDialog(categoryProvider);
                    } else {
                      setState(() => _category = val);
                    }
                  },
                ),
              ),

              _buildCard(
                child: TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Importo",
                    prefixText: "€ ",
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),

              _buildCard(
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Nota",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 92, 191, 236),
                    foregroundColor: const Color.fromARGB(255, 3, 42, 69),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Salva", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    double amount =
                        double.tryParse(_amountController.text) ?? 0;
                    if (_category == null || _category!.isEmpty) return;

                    final transaction = Transaction(
                      type: _type,
                      amount: amount,
                      category: _category ?? "",
                      note: _noteController.text,
                    );

                    // Se sto modificando una transazione esistente, prima annullo il saldo precedente
                    if (widget.transaction != null &&
                        widget.transactionIndex != null) {
                      // Rimuovo l'effetto precedente sul saldo
                      accountProvider.updateBalance(
                        widget.accountId,
                        widget.transaction!.amount,
                        widget.transaction!.type,
                      );

                      // Modifico la transazione
                      eventProvider.editTransaction(widget.accountId, widget.day,
                          widget.transactionIndex!, transaction);

                      // Aggiorno il saldo con la nuova transazione
                      accountProvider.updateBalance(
                        widget.accountId,
                        transaction.amount,
                        transaction.type,
                      );
                    } else {
                      // Aggiungo la nuova transazione
                      eventProvider.addTransaction(
                          widget.accountId, widget.day, transaction);

                      // Aggiorno subito il saldo
                      accountProvider.updateBalance(
                        widget.accountId,
                        transaction.amount,
                        transaction.type,
                      );
                    }

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
