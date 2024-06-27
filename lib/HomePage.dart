import 'package:flutter/material.dart';
import 'package:scanner_machine/Bus/BusScanner.dart';
import 'package:scanner_machine/Metro/metroStations.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //a7mr Color(0xFFB31312),,  a5dr Color(0xFF00796B),,  Color(0xFF073042)
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AdminButton(
                icon: Icons.qr_code_scanner,
                text: "Scan Metro Code",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MetroStations()),
                  );
                },
                backgroundColor: const Color(0xFF00796B),
              ),
              const SizedBox(height: 40),
              AdminButton(
                icon: Icons.qr_code,
                text: "Scan Bus Code",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const busQRCodeScannerPage()),
                  );
                },
                backgroundColor: const Color(0xFF00796B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const AdminButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Fixed width
      height: 80, // Fixed height
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 40),
        label: Text(text, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: backgroundColor ?? Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
