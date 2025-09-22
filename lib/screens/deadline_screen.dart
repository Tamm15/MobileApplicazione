import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/deadline_provider.dart';

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({super.key});

  @override
  _DeadlineScreenState createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  void _showAddDeadlineDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final provider = Provider.of<DeadlineProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuova Scadenza"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Titolo (es. Affitto)"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Importo (€)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Annulla"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Aggiungi"),
            onPressed: () {
              final title = titleController.text.trim();
              final amount = double.tryParse(amountController.text.trim()) ?? 0;

              if (title.isNotEmpty && amount > 0) {
                provider.addDeadline(title, amount, _selectedDay);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAllDeadlinesScreen(BuildContext context) {
    final deadlineProvider = Provider.of<DeadlineProvider>(context, listen: false);
    final allDeadlines = deadlineProvider.deadlines;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text("Tutte le scadenze"),
            backgroundColor: Color.fromRGBO(154, 223, 255, 1),
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          ),
          backgroundColor: Color.fromRGBO(154, 223, 255, 1),
          body: allDeadlines.isEmpty
              ? const Center(child: Text("Nessuna scadenza disponibile"))
              : ListView.builder(
                  itemCount: allDeadlines.length,
                  itemBuilder: (context, index) {
                    final d = allDeadlines[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(
                          d.paid ? Icons.check_circle : Icons.error,
                          color: d.paid ? Colors.green : Colors.red,
                        ),
                        title: Text("${d.title} - €${d.amount.toStringAsFixed(2)}"),
                        subtitle: Text(
                            "Scadenza: ${d.date.day}/${d.date.month}/${d.date.year}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.check, color: Color(0xFF0277BD)),
                          onPressed: () => deadlineProvider.togglePaid(d.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deadlineProvider = Provider.of<DeadlineProvider>(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(154, 223, 255, 1),
      appBar: AppBar(
        title: const Text("Scadenziario"),
        backgroundColor: Color.fromRGBO(154, 223, 255, 1),
        foregroundColor: const Color.fromARGB(255, 3, 42, 69),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "Tutte le scadenze",
            onPressed: () => _showAllDeadlinesScreen(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mini calendario orizzontale
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarFormat: CalendarFormat.week,
            startingDayOfWeek: StartingDayOfWeek.monday,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w600, fontSize: 22),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF0277BD)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF0277BD)),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 111, 209, 255),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 25, 182, 254),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.white),
              selectedTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),

          // Lista scadenze del giorno selezionato
          Expanded(
            child: deadlineProvider.getDeadlinesForDay(_selectedDay).isEmpty
                ? const Center(child: Text("Nessuna scadenza per questo giorno"))
                : ListView.builder(
                    itemCount: deadlineProvider.getDeadlinesForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final d = deadlineProvider.getDeadlinesForDay(_selectedDay)[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: ListTile(
                          leading: Icon(
                            d.paid ? Icons.check_circle : Icons.error,
                            color: d.paid ? Colors.green : Colors.red,
                          ),
                          title: Text("${d.title} - €${d.amount.toStringAsFixed(2)}"),
                          subtitle: Text(
                              "Scadenza: ${d.date.day}/${d.date.month}/${d.date.year}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.check, color: Color(0xFF0277BD)),
                            onPressed: () => deadlineProvider.togglePaid(d.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 41, 187, 255),
        foregroundColor: const Color.fromARGB(255, 3, 42, 69),
        child: const Icon(Icons.add),
        onPressed: () => _showAddDeadlineDialog(context),
      ),
    );
  }
}


