import 'dart:math';
import 'package:flutter/material.dart';
import 'select_account_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _coinsController;
  final List<CoinData> _coins = [];

  final int numberOfCoins = 20;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    // Animazione testo e pulsante
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Inizializza le monetine
    for (int i = 0; i < numberOfCoins; i++) {
      _coins.add(CoinData(
        x: random.nextDouble(),
        speed: 0.002 + random.nextDouble() * 0.004,
        size: 15 + random.nextDouble() * 15,
      ));
    }

    // Animazione monetine
    _coinsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        setState(() {
          for (var coin in _coins) {
            coin.y += coin.speed;
            if (coin.y > 1) {
              coin.y = 0;
              coin.x = random.nextDouble();
            }
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _coinsController.dispose();
    super.dispose();
  }

  void _navigateToSelectAccount() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SelectAccountScreen(),
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleAnimation =
              Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ));
          final fadeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);

          return ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),

          ..._coins.map((coin) {
            return Positioned(
              top: coin.y * screenSize.height,
              left: coin.x * screenSize.width,
              child: Icon(
                Icons.monetization_on,
                color: const Color.fromARGB(255, 255, 215, 71),
                size: coin.size,
              ),
            );
          }).toList(),
          
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Benvenuto! \nPronto a gestire le tue spese?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Smart money, smart choices, smart you",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _navigateToSelectAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.lightBlue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          "Inizia",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Classe per le monetine
class CoinData {
  double x; // posizione orizzontale (0-1)
  double y; // posizione verticale (0-1)
  double speed; // velocità di caduta
  double size; // dimensione della moneta

  CoinData({required this.x, this.y = 0, required this.speed, required this.size});
}
