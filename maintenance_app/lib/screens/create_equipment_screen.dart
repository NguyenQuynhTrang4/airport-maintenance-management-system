import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'equipment_qr_screen.dart';

class CreateEquipmentScreen extends StatefulWidget {
  const CreateEquipmentScreen({super.key});

  @override
  State<CreateEquipmentScreen> createState() => _CreateEquipmentScreenState();
}

class _CreateEquipmentScreenState extends State<CreateEquipmentScreen> {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final equipmentTypeController = TextEditingController();
  final locationController = TextEditingController();
  final areaController = TextEditingController();
  final ipController = TextEditingController();
  final serialController = TextEditingController();
  final modelController = TextEditingController();
  final manufacturerController = TextEditingController();
  final descriptionController = TextEditingController();

  String system = 'CCTV';
  String floor = 'Tầng 3';
  String status = 'normal';
  bool isSubmitting = false;

  final systems = [
    'CCTV',
    'ACS',
    'FAS',
    'BHS',
    'FIDS',
    'CMS',
    'Network',
    'Other',
  ];
  final floors = ['Tầng G', 'Tầng 1', 'Tầng 2', 'Tầng 3', 'Tầng 4', 'Khác'];
  final statuses = ['normal', 'fault', 'maintenance'];

  @override
  void initState() {
    super.initState();
    equipmentTypeController.text = 'Camera';
    manufacturerController.text = 'Axis';
  }

  Future<void> submit() async {
    final code = codeController.text.trim();
    final name = nameController.text.trim();

    if (code.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã và tên thiết bị')),
      );
      return;
    }

    if (!code.startsWith('LTIA-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã thiết bị nên bắt đầu bằng LTIA-')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final success = await ApiService.createEquipment(
        code: code,
        name: name,
        system: system,
        equipmentType: equipmentTypeController.text.trim(),
        location: locationController.text.trim(),
        floor: floor,
        area: areaController.text.trim(),
        ipAddress: ipController.text.trim(),
        serialNumber: serialController.text.trim(),
        model: modelController.text.trim(),
        manufacturer: manufacturerController.text.trim(),
        status: status,
        description: descriptionController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm thiết bị thành công')),
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EquipmentQrScreen(equipmentCode: code, equipmentName: name),
          ),
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Widget textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  String statusText(String value) {
    switch (value) {
      case 'normal':
        return 'Bình thường';
      case 'fault':
        return 'Đang lỗi';
      case 'maintenance':
        return 'Đang bảo trì';
      default:
        return value;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    equipmentTypeController.dispose();
    locationController.dispose();
    areaController.dispose();
    ipController.dispose();
    serialController.dispose();
    modelController.dispose();
    manufacturerController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrContent = codeController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm thiết bị mới')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          textField(
            controller: codeController,
            label: 'Mã thiết bị',
            hint: 'Ví dụ: LTIA-CCTV-CAM-003',
          ),
          textField(
            controller: nameController,
            label: 'Tên thiết bị',
            hint: 'Ví dụ: Camera khu vực Check-in C',
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              value: system,
              decoration: const InputDecoration(
                labelText: 'Hệ thống',
                border: OutlineInputBorder(),
              ),
              items: systems.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    system = value;
                  });
                }
              },
            ),
          ),

          textField(
            controller: equipmentTypeController,
            label: 'Loại thiết bị',
            hint: 'Camera, Card Reader, Detector...',
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              value: floor,
              decoration: const InputDecoration(
                labelText: 'Tầng',
                border: OutlineInputBorder(),
              ),
              items: floors.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    floor = value;
                  });
                }
              },
            ),
          ),

          textField(
            controller: areaController,
            label: 'Khu vực',
            hint: 'Zone A, Zone B, Technical Room...',
          ),
          textField(
            controller: locationController,
            label: 'Vị trí lắp đặt',
            hint: 'Nhà ga hành khách - khu vực Check-in C',
          ),
          textField(
            controller: ipController,
            label: 'IP Address',
            hint: '10.10.20.103',
          ),
          textField(controller: serialController, label: 'Serial Number'),
          textField(controller: modelController, label: 'Model'),
          textField(controller: manufacturerController, label: 'Hãng sản xuất'),

          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
              ),
              items: statuses.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(statusText(item)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    status = value;
                  });
                }
              },
            ),
          ),

          textField(
            controller: descriptionController,
            label: 'Mô tả',
            maxLines: 3,
          ),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                qrContent.isEmpty
                    ? 'Sau khi nhập mã thiết bị, nội dung QR sẽ là mã đó.'
                    : 'Nội dung QR cần tạo/in:\n$qrContent',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: isSubmitting ? null : submit,
            icon: const Icon(Icons.save),
            label: Text(isSubmitting ? 'Đang lưu...' : 'Lưu thiết bị'),
          ),
        ],
      ),
    );
  }
}
