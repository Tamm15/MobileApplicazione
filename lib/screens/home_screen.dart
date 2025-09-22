import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/account_provider.dart';
import '../providers/event_provider.dart';
import 'add_transaction_screen.dart';
import 'all_reminders_screen.dart';
import 'savings_screen.dart';
import 'deadline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showOptions = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
      if (_showOptions) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _showAddReminderDialog(BuildContext context, String accountId) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuovo promemoria"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Es. Pagare bollo auto"),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 249, 37, 37), // colore del testo
              textStyle: const TextStyle(fontWeight: FontWeight.w500), // stile testo opzionale
            ),
            child: const Text("Annulla"),
            onPressed: () => Navigator.pop(context),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255), // colore di sfondo
              foregroundColor: const Color.fromARGB(255, 37, 153, 249),      // colore del testo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // bordi arrotondati opzionali
              ),
            ),
            child: const Text("Aggiungi"),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                eventProvider.addReminder(accountId, _selectedDay!, controller.text);
              }
            Navigator.pop(context);
            },
          )

        ],
      ),
    );
  }

  void _showAccountsBottomSheet(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Seleziona un conto",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accountProvider.accounts.length,
                  itemBuilder: (context, index) {
                    final account = accountProvider.accounts[index];
                    final gradients = [
                      [Colors.lightBlueAccent, Colors.blueAccent],
                      [Colors.purpleAccent, Colors.deepPurple],
                      [Colors.orangeAccent, Colors.deepOrange],
                      [Colors.greenAccent, Colors.green],
                    ];
                    final gradientColors = gradients[index % gradients.length];

                    return GestureDetector(
                      onTap: () {
                        accountProvider.setCurrentAccount(account);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.credit_card,
                                  color: Colors.white70, size: 30),
                              Text(
                                account.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Saldo: €${account.balance.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Crea nuovo conto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showAddAccountDialog(context, accountProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, AccountProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final balanceController = TextEditingController(text: '0.00');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuovo Conto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome Conto'),
            ),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(labelText: 'Descrizione (opzionale)'),
            ),
            TextField(
              controller: balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Saldo iniziale'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              final balance =
                  double.tryParse(balanceController.text.trim()) ?? 0.0;

              if (name.isNotEmpty) {
                provider.addAccount(name, description: desc, balance: balance);
                Navigator.pop(context);
              }
            },
            child: const Text('Crea'),
          ),
        ],
      ),
    );
  }

  void _showTransactionOptions(
      BuildContext context, String accountId, DateTime day, int index) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final transaction = eventProvider.getTransactionsForDay(accountId, day)[index];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Modifica"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(
                      accountId: accountId,
                      day: day,
                      transaction: transaction,
                      transactionIndex: index,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Elimina", style: TextStyle(color: Colors.red)),
              onTap: () {
                // Aggiorna il saldo prima di eliminare
                accountProvider.updateBalance(
                    accountId,
                    transaction.amount,
                    transaction.type == "Spesa" ? "Entrata" : "Spesa");
                eventProvider.deleteTransaction(accountId, day, index);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAccount = Provider.of<AccountProvider>(context).currentAccount;

    if (currentAccount == null) {
      return const Scaffold(
        body: Center(child: Text("Nessun account selezionato")),
      );
    }

    final String accountId = currentAccount.id;
    final eventProvider = Provider.of<EventProvider>(context);
    final selectedDay = _selectedDay!;
    final transactions =
        eventProvider.getTransactionsForDay(accountId, selectedDay);
    final reminders = eventProvider.getRemindersForDay(accountId, selectedDay);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(154, 223, 255, 1), // Azzurro chiaro
                  Color.fromRGBO(67, 196, 255, 1),],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: GestureDetector(
                      onTap: () => _showAccountsBottomSheet(context),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentAccount.name,
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(
                                  "Saldo: €${currentAccount.balance.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                headerStyle: HeaderStyle(
                                  titleCentered: true,
                                  formatButtonVisible: false,
                                  titleTextStyle: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(159, 224, 254, 1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: Color.fromRGBO(172, 229, 255, 1),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: Color.fromRGBO(114, 210, 255, 1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      "Transazioni",
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (transactions.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        "Nessuna transazione effettuata",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black54),
                                      ),
                                    ),
                                  ...transactions.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final t = entry.value;
                                    return Card(
                                      child: ListTile(
                                        leading: Icon(
                                          t.type == "Spesa"
                                              ? Icons.remove_circle
                                              : Icons.add_circle,
                                          color:
                                              t.type == "Spesa" ? Colors.red : Colors.green,
                                        ),
                                        title: Text(
                                            "${t.category} - ${t.amount.toStringAsFixed(2)} €"),
                                        subtitle: Text(t.note ?? ""),
                                        onTap: () => _showTransactionOptions(
                                            context, accountId, selectedDay, index),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Promemoria",
                                          style: TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => AllRemindersScreen(accountId: accountId),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.list_alt, size: 20),
                                          label: const Text("Tutti"),
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color.fromARGB(255, 46, 154, 204),
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(50, 30),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (reminders.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        "Nessun promemoria",
                                        style: TextStyle(fontSize: 16, color: Colors.black54),
                                      ),
                                    ),
                                  ...reminders.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final reminder = entry.value;
                                    return CheckboxListTile(
                                      value: reminder["done"],
                                      title: Text(reminder["text"]),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      onChanged: (val) {
                                        eventProvider.toggleReminder(accountId, selectedDay, index, val);
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ..._buildSlideOptions(accountId, selectedDay),
                FloatingActionButton(
                  heroTag: "fab_main",
                  backgroundColor: const Color.fromARGB(255, 137, 201, 230),
                  foregroundColor: const Color.fromARGB(255, 3, 42, 69),
                  onPressed: _toggleOptions,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (_, __) {
                      return Transform.rotate(
                        angle: _animation.value * 0.785398,
                        child: const Icon(Icons.add),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlideOptions(String accountId, DateTime selectedDay) {
    final buttons = [
      {
        "icon": Icons.attach_money,
        "label": "Nuova transazione",
        "onPressed": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddTransactionScreen(accountId: accountId, day: selectedDay),
            ),
          );
          _toggleOptions();
        },
      },
      {
        "icon": Icons.event_note,
        "label": "Promemoria",
        "onPressed": () {
          _showAddReminderDialog(context, accountId);
          _toggleOptions();
        },
      },
      {
        "icon": Icons.savings,
        "label": "Salvadanai",
        "onPressed": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SavingsScreen()),
          );
          _toggleOptions();
        },
      },
      {
        "icon": Icons.schedule,
        "label": "Scadenziario",
        "onPressed": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DeadlineScreen()),
          );
          _toggleOptions();
        },
      },
    ];

    List<Widget> widgets = [];
    for (int i = 0; i < buttons.length; i++) {
      widgets.add(
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: FloatingActionButton.extended(
              heroTag: "slide_$i",
              backgroundColor: const Color.fromARGB(255, 141, 219, 255),
              foregroundColor: const Color.fromARGB(255, 3, 42, 69),
              icon: Icon(buttons[i]["icon"] as IconData),
              label: Text(buttons[i]["label"] as String),
              onPressed: buttons[i]["onPressed"] as void Function()?,
            ),
          ),
        ),
      );
    }

    return widgets.reversed.toList();
  }
}
