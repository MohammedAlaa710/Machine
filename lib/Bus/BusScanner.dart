import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanner_machine/main.dart';

// ignore: camel_case_types
class busQRCodeScannerPage extends StatefulWidget {
  const busQRCodeScannerPage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _busQRCodeScannerPageState createState() => _busQRCodeScannerPageState();
}

// ignore: camel_case_types
class _busQRCodeScannerPageState extends State<busQRCodeScannerPage> {
  String? qrText;
  bool isScanned = false;
  bool stop = false;

  Future<void> checkAndUpdateQRCode(String qrCodeString) async {
    if (isScanned) return;
    final qrCodeRef =
        FirebaseFirestore.instance.collection('BusQRcodes').doc(qrCodeString);
    final qrCodeDoc = await qrCodeRef.get();
    if (qrCodeDoc.exists) {
      final qrCodeData = qrCodeDoc.data() as Map<String, dynamic>;
      final bool scannedStatus = qrCodeData['scanned'] ?? false;
      if (!scannedStatus) {
        await qrCodeRef.update({'scanned': true});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('the first scan (scanned=true)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('already scaned twice (scanned=out=true)')),
        );
        throw Exception('This QR code is already used');
      }
    } else {
      throw Exception('QR code not found');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          'Bus Ticket Scanner',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: stop
                ? const Center(child: Text('Processing QR code...'))
                : MobileScanner(
                    onDetect: (qrcodeCapture) async {
                      if (qrcodeCapture.barcodes.isEmpty || stop) return;

                      final qrcode = qrcodeCapture.barcodes.first;
                      if (qrcode.rawValue != null) {
                        setState(() {
                          qrText = qrcode.rawValue!;
                          stop = true; // Stop further scanning
                        });

                        try {
                          await checkAndUpdateQRCode(qrText!);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('QR code processed successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          // Navigate back to the previous page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyApp()),
                          );
                        } catch (e) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          // Allow scanning again if an error occurs
                          setState(() {
                            stop = false;
                          });
                        }
                      }
                    },
                  ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (qrText != null)
                  ? Text('Scan result: $qrText')
                  : const Text('Scan the code'),
            ),
          ),
        ],
      ),
    );
  }
}
