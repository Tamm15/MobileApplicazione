import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class AllRemindersScreen extends StatelessWidget {
  final String accountId;

  AllRemindersScreen({required this.accountId});

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    // Lista di tutti i promemoria del conto
    final allReminders = eventProvider
        .getAllRemindersForAccount(accountId)
        .entries
        .expand((entry) {
      final day = entry.key;
      final reminders = entry.value;
      return reminders.asMap().entries.map((reminderEntry) {
        return {
          "day": day,
          "index": reminderEntry.key,
          "text": reminderEntry.value["text"],
          "done": reminderEntry.value["done"],
        };
      }).toList();
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(154, 223, 255, 1),
              Color.fromRGBO(67, 196, 255, 1),],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personalizzato
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Tutti i promemoria",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 0, 2, 5),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenuto
              Expanded(
                child: allReminders.isEmpty
                    ? const Center(
                        child: Text(
                          "Nessun promemoria disponibile",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allReminders.length,
                        itemBuilder: (context, i) {
                          final reminder = allReminders[i];
                          final date = reminder["day"];
                          return _buildCard(
                            child: CheckboxListTile(
                              value: reminder["done"],
                              onChanged: (val) {
                                eventProvider.toggleReminder(accountId, date,
                                    reminder["index"], val);
                              },
                              title: Text(
                                reminder["text"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                "Creato il ${date.day}/${date.month}/${date.year}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
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
}


