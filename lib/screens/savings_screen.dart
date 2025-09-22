import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saving_provider.dart';
import 'add_saving_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savingProvider = Provider.of<SavingProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(173, 229, 255, 1), // Azzurro chiaro
              Color.fromRGBO(94, 204, 255, 1),],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizzata
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 3, 42, 69)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "I tuoi Salvadanai",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 3, 42, 69),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color.fromARGB(255, 3, 42, 69)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddSavingScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Contenuto
              Expanded(
                child: savingProvider.savings.isEmpty
                    ? const Center(
                        child: Text(
                          "Nessun salvadanaio creato",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: savingProvider.savings.length,
                        itemBuilder: (context, index) {
                          final s = savingProvider.savings[index];
                          final remaining = (s.targetAmount - s.currentAmount).clamp(0, s.targetAmount);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.goal,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 3, 42, 69),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Totale: ${s.currentAmount.toStringAsFixed(2)} €",
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                                Text(
                                  "Rimanente: ${remaining.toStringAsFixed(2)} €",
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                                      label: const Text(
                                        "Aggiungi soldi",
                                        style: TextStyle(color: Colors.blueAccent),
                                      ),
                                      onPressed: () => _showAddMoneyDialog(context, s.id),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      label: const Text(
                                        "Modifica",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      onPressed: () => _showEditSavingDialog(context, s.id, s.goal, s.targetAmount),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, String savingId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Aggiungi soldi"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Importo da aggiungere"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                Provider.of<SavingProvider>(context, listen: false).addMoney(savingId, amount);
                Navigator.pop(context);
              }
            },
            child: const Text("Aggiungi"),
          ),
        ],
      ),
    );
  }

  void _showEditSavingDialog(BuildContext context, String savingId, String currentGoal, double currentTarget) {
    final goalController = TextEditingController(text: currentGoal);
    final targetController = TextEditingController(text: currentTarget.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifica salvadanaio"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: goalController,
              decoration: const InputDecoration(labelText: "Obiettivo"),
            ),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Importo da raggiungere"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              final newGoal = goalController.text.trim();
              final newTarget = double.tryParse(targetController.text);
              if (newTarget != null && newGoal.isNotEmpty) {
                Provider.of<SavingProvider>(context, listen: false)
                    .updateSavingGoal(savingId, newTarget, newGoal: newGoal);
                Navigator.pop(context);
              }
            },
            child: const Text("Salva"),
          ),
        ],
      ),
    );
  }
}
