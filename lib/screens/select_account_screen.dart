import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';
import 'home_screen.dart';

class SelectAccountScreen extends StatefulWidget {
  const SelectAccountScreen({super.key});

  @override
  _SelectAccountScreenState createState() => _SelectAccountScreenState();
}

class _SelectAccountScreenState extends State<SelectAccountScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(154, 223, 255, 1),
              Color.fromRGBO(0, 174, 255, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Seleziona il tuo conto",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: GestureDetector(
                            onTap: () {
                              accountProvider.setCurrentAccount(account);

                              // Navigazione con effetto fade + scale
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const HomeScreen(),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.9, end: 1).animate(
                                          CurvedAnimation(
                                              parent: animation, curve: Curves.easeOutBack),
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 600),
                                ),
                              );
                            },
                            child: Container(
                              height: 150,
                              margin: const EdgeInsets.symmetric(vertical: 10),
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
                              child: Stack(
                                children: [
                                  const Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Icon(
                                      Icons.credit_card,
                                      color: Colors.white70,
                                      size: 30,
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    bottom: 50,
                                    child: Text(
                                      account.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    bottom: 16,
                                    child: Text(
                                      "Saldo: €${account.balance.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 16),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      onPressed: () {
                                        _showAccountDialog(context, accountProvider,
                                            account: account);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _showAccountDialog(context, accountProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.lightBlue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: -10),
                    elevation: 20,
                  ),
                  child: const Text(
                    'Crea Nuovo Conto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      height: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAccountDialog(BuildContext context, AccountProvider provider,
      {Account? account}) {
    final nameController = TextEditingController(text: account?.name ?? '');
    final descController =
        TextEditingController(text: account?.description ?? '');
    final balanceController = TextEditingController(
        text: account != null ? account.balance.toStringAsFixed(2) : '0.00');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(account == null ? 'Nuovo Conto' : 'Modifica Conto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome Conto'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrizione (opzionale)'),
            ),
            TextField(
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              final balance = double.tryParse(balanceController.text.trim()) ?? 0.0;

              if (name.isNotEmpty) {
                if (account == null) {
                  provider.addAccount(name, description: desc, balance: balance);
                } else {
                  provider.updateAccount(account,
                      name: name, description: desc, balance: balance);
                }
                Navigator.pop(context);
              }
            },
            child: Text(account == null ? 'Crea' : 'Salva'),
          ),
        ],
      ),
    );
  }
}
