import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EquipmentQrScreen extends StatelessWidget {
  final String equipmentCode;
  final String equipmentName;

  const EquipmentQrScreen({
    super.key,
    required this.equipmentCode,
    required this.equipmentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR thiết bị'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    equipmentName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    equipmentCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 24),

                  QrImageView(
                    data: equipmentCode,
                    version: QrVersions.auto,
                    size: 260,
                    backgroundColor: Colors.white,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Nội dung QR chính là mã thiết bị.\nKhi quét QR này, app sẽ mở chi tiết thiết bị tương ứng.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }
}