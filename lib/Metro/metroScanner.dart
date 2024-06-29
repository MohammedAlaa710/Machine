import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scanner_machine/Metro/metroService.dart';

class QRCodeScannerPage extends StatefulWidget {
  final String station;

  const QRCodeScannerPage({super.key, required this.station});

  @override
  // ignore: library_private_types_in_public_api
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final metroService _metroService = metroService();
  String? qrText;
  bool isScanned = false;
  bool stop = false; // Control flag to stop the scanner

  Future<void> checkAndUpdateQRCode(String qrCodeString) async {
    if (isScanned) return; // If already scanned, do nothing

    // Search for the QR code document
    final qrCodeRef =
        FirebaseFirestore.instance.collection('QR').doc(qrCodeString);
    final qrCodeDoc = await qrCodeRef.get();

    // If the document exists
    if (qrCodeDoc.exists) {
      final qrCodeData = qrCodeDoc.data() as Map<String, dynamic>;
      final bool inStatus = qrCodeData['in'] ?? false;
      final bool outStatus = qrCodeData['out'] ?? false;

      // If 'in' is false, update it to true
      if (!inStatus) {
        await qrCodeRef.update({'in': true});
        await qrCodeRef.update({'fromStation': widget.station});
        isScanned = true; // Mark as scanned
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'The ticket has been successfully scanned for the first time.\n The gate will now open.')),
        );
      } else {
        // If 'in' is true, update 'out' to true
        if (!outStatus) {
          isScanned = true; // Mark as scanned
          String fromStation = qrCodeData['fromStation'];
          String price = qrCodeData['price'];
          String outprice =
              _metroService.calculatePrice(fromStation, widget.station);
          if (((price == '6.0 egp') && (outprice != '6.0 egp')) ||
              ((price == '8.0 egp') &&
                  (outprice == '12.0 egp' || outprice == '15.0 egp')) ||
              ((price == '12.0 egp') && (outprice == '15.0 egp'))) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'the price of the ticket is less than the needed.\n The gate will not open')));
            return;
          }
          await qrCodeRef.update({'out': true});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'The ticket has been successfully scanned for the second time\n The gate will now open')),
          );
        } else {
          // If 'out' is true, the QR code is already used
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'The ticket has already been scanned twice.\n The gate will not open.')),
          );
          throw Exception('This QR code is already used');
        }
      }
    } else {
      throw Exception('QR code not found');
    }
  }

  @override
  void dispose() {
    // Dispose of any resources here if necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          'Metro Ticket Scanner',
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
                          Navigator.of(context).pop();
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
                  : Text(widget.station),
            ),
          )
        ],
      ),
    );
  }
}
