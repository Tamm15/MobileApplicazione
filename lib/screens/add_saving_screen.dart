import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/saving_provider.dart';

class AddSavingScreen extends StatefulWidget {
  const AddSavingScreen({super.key});

  @override
  _AddSavingScreenState createState() => _AddSavingScreenState();
}

class _AddSavingScreenState extends State<AddSavingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime? _deadline;
  DateTime _focusedDay = DateTime.now();
  String? _frequency;
  double? depositAmount;

  void updateDepositAmount() {
    if (_amountController.text.isEmpty || _deadline == null || _frequency == null) {
      setState(() => depositAmount = null);
      return;
    }

    final target = double.tryParse(_amountController.text);
    if (target == null) return;

    final now = DateTime.now();
    final daysUntilDeadline = _deadline!.difference(now).inDays;
    if (daysUntilDeadline <= 0) return;

    int numPayments;
    switch (_frequency) {
      case "settimana":
        numPayments = (daysUntilDeadline / 7).ceil();
        break;
      case "due settimane":
        numPayments = (daysUntilDeadline / 14).ceil();
        break;
      case "mese":
        numPayments = (daysUntilDeadline / 30).ceil();
        break;
      default:
        numPayments = 1;
    }

    if (numPayments <= 0) numPayments = 1;

    setState(() => depositAmount = target / numPayments);
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selectedDayPredicate: (day) =>
                        _deadline != null && isSameDay(_deadline, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _deadline = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      updateDepositAmount();
                      Navigator.pop(context);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Titolo
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Nuovo Salvadanaio",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Obiettivo
                  _buildCard(
                    child: TextFormField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: "Per cosa vuoi risparmiare?",
                        hintText: "Es. Viaggio a New York",
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Inserisci un obiettivo" : null,
                    ),
                  ),

                  // Importo totale
                  _buildCard(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: "Importo totale",
                        hintText: "Es. 10000",
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Inserisci un importo" : null,
                      onChanged: (val) => updateDepositAmount(),
                    ),
                  ),

                  // Data limite
                  _buildCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_deadline == null
                          ? "Data limite (opzionale)"
                          : "Data limite: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}"),
                      trailing: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                      onTap: _showCalendarDialog,
                    ),
                  ),

                  // Frequenza
                  _buildCard(
                    child: DropdownButtonFormField<String>(
                      initialValue: _frequency,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: "Frequenza di versamento",
                      ),
                      items: const [
                        DropdownMenuItem(value: "settimana", child: Text("Ogni settimana")),
                        DropdownMenuItem(value: "due settimane", child: Text("Ogni due settimane")),
                        DropdownMenuItem(value: "mese", child: Text("Ogni mese")),
                      ],
                      onChanged: (val) {
                        setState(() => _frequency = val);
                        updateDepositAmount();
                      },
                    ),
                  ),

                  if (depositAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 60.0, top: 8),
                      child: Text(
                        "Dovresti versare circa ${depositAmount!.toStringAsFixed(2)} € ogni ${_frequency ?? ""}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Pulsante crea salvadanaio
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final savingProvider =
                              Provider.of<SavingProvider>(context, listen: false);
                          savingProvider.addSaving(
                            goal: _goalController.text.trim(),
                            targetAmount:
                                double.parse(_amountController.text.trim()),
                            deadline: _deadline,
                            frequency: _frequency,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Crea Salvadanaio",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}
