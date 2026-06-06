import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'equipment_detail_screen.dart';

class QrScanScreen extends StatefulWidget {
  final String username;
  final String fullName;
  final String role;

  const QrScanScreen({
    super.key,
    required this.username,
    required this.fullName,
    required this.role,
  });

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool isScanned = false;

  void handleScan(String code) {
    if (isScanned) return;

    setState(() {
      isScanned = true;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentDetailScreen(
          equipmentCode: code,
          username: widget.username,
          fullName: widget.fullName,
          role: widget.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR thiết bị')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;

              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;

                if (code != null && code.trim().isNotEmpty) {
                  handleScan(code.trim());
                }
              }
            },
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Đưa QR thiết bị vào khung camera',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
