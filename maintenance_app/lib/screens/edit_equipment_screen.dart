import 'package:flutter/material.dart';

import '../models/equipment.dart';
import '../services/api_service.dart';

class EditEquipmentScreen extends StatefulWidget {
  final Equipment equipment;

  const EditEquipmentScreen({
    super.key,
    required this.equipment,
  });

  @override
  State<EditEquipmentScreen> createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen> {
  late TextEditingController nameController;
  late TextEditingController equipmentTypeController;
  late TextEditingController locationController;
  late TextEditingController areaController;
  late TextEditingController ipController;
  late TextEditingController serialController;
  late TextEditingController modelController;
  late TextEditingController manufacturerController;
  late TextEditingController descriptionController;

  late String system;
  late String floor;
  late String status;

  bool isSubmitting = false;

  final systems = ['CCTV', 'ACS', 'FAS', 'BHS', 'FIDS', 'CMS', 'Network', 'Other'];
  final floors = ['Tầng G', 'Tầng 1', 'Tầng 2', 'Tầng 3', 'Tầng 4', 'Khác'];
  final statuses = ['normal', 'fault', 'maintenance'];

  @override
  void initState() {
    super.initState();

    final e = widget.equipment;

    nameController = TextEditingController(text: e.name);
    equipmentTypeController = TextEditingController(text: e.equipmentType ?? '');
    locationController = TextEditingController(text: e.location ?? '');
    areaController = TextEditingController(text: e.area ?? '');
    ipController = TextEditingController(text: e.ipAddress ?? '');
    serialController = TextEditingController(text: e.serialNumber ?? '');
    modelController = TextEditingController(text: e.model ?? '');
    manufacturerController = TextEditingController(text: e.manufacturer ?? '');
    descriptionController = TextEditingController(text: e.description ?? '');

    system = systems.contains(e.system) ? e.system! : 'Other';
    floor = floors.contains(e.floor) ? e.floor! : 'Khác';
    status = statuses.contains(e.status) ? e.status! : 'normal';
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

  Widget textField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> submit() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thiết bị')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final success = await ApiService.updateEquipment(
        code: widget.equipment.code,
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
          const SnackBar(content: Text('Đã cập nhật thiết bị')),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa thiết bị'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(widget.equipment.code),
              subtitle: const Text('Mã thiết bị không sửa tại bước này'),
            ),
          ),

          const SizedBox(height: 16),

          textField(
            controller: nameController,
            label: 'Tên thiết bị',
          ),

          DropdownButtonFormField<String>(
            value: system,
            decoration: const InputDecoration(
              labelText: 'Hệ thống',
              border: OutlineInputBorder(),
            ),
            items: systems.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  system = value;
                });
              }
            },
          ),

          const SizedBox(height: 14),

          textField(
            controller: equipmentTypeController,
            label: 'Loại thiết bị',
          ),

          DropdownButtonFormField<String>(
            value: floor,
            decoration: const InputDecoration(
              labelText: 'Tầng',
              border: OutlineInputBorder(),
            ),
            items: floors.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  floor = value;
                });
              }
            },
          ),

          const SizedBox(height: 14),

          textField(
            controller: areaController,
            label: 'Khu vực',
          ),
          textField(
            controller: locationController,
            label: 'Vị trí lắp đặt',
          ),
          textField(
            controller: ipController,
            label: 'IP Address',
          ),
          textField(
            controller: serialController,
            label: 'Serial Number',
          ),
          textField(
            controller: modelController,
            label: 'Model',
          ),
          textField(
            controller: manufacturerController,
            label: 'Hãng sản xuất',
          ),

          DropdownButtonFormField<String>(
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

          const SizedBox(height: 14),

          textField(
            controller: descriptionController,
            label: 'Mô tả',
            maxLines: 3,
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: isSubmitting ? null : submit,
            icon: const Icon(Icons.save),
            label: Text(isSubmitting ? 'Đang lưu...' : 'Lưu thay đổi'),
          ),
        ],
      ),
    );
  }
}