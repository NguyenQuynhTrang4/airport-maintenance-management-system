import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class CreateMaintenanceScreen extends StatefulWidget {
  final String? initialEquipmentCode;
  final String username;

  const CreateMaintenanceScreen({
    super.key,
    this.initialEquipmentCode,
    required this.username,
  });

  @override
  State<CreateMaintenanceScreen> createState() =>
      _CreateMaintenanceScreenState();
}

class _CreateMaintenanceScreenState extends State<CreateMaintenanceScreen> {
  final equipmentCodeController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final createdByController = TextEditingController();

  String issueType = 'Kiểm tra định kỳ';
  String priority = 'Trung bình';

  File? imageFile;
  bool isSubmitting = false;

  final List<String> issueTypes = [
    'Kiểm tra định kỳ',
    'Xử lý lỗi',
    'Thay thế thiết bị',
    'Vệ sinh thiết bị',
    'Hiệu chỉnh thiết bị',
    'Kiểm tra sau sửa chữa',
  ];

  final List<String> priorities = [
    'Thấp',
    'Trung bình',
    'Cao',
    'Khẩn cấp',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialEquipmentCode != null &&
        widget.initialEquipmentCode!.isNotEmpty) {
      equipmentCodeController.text = widget.initialEquipmentCode!;
    }

    createdByController.text = widget.username;
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> submitTicket() async {
    final equipmentCode = equipmentCodeController.text.trim();
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final createdBy = createdByController.text.trim();

    if (equipmentCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã thiết bị')),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề công việc')),
      );
      return;
    }

    if (createdBy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập người tạo phiếu')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final success = await ApiService.createMaintenanceTicket(
        equipmentCode: equipmentCode,
        title: title,
        issueType: issueType,
        priority: priority,
        description: description,
        createdBy: createdBy,
        imageFile: imageFile,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo phiếu bảo trì thành công')),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
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
    equipmentCodeController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    createdByController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget equipmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thiết bị',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: equipmentCodeController,
              readOnly: widget.initialEquipmentCode != null &&
                  widget.initialEquipmentCode!.isNotEmpty,
              decoration: const InputDecoration(
                labelText: 'Mã thiết bị',
                hintText: 'Ví dụ: LTIA-CCTV-CAM-001',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Ảnh hiện trường'),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pickImageFromGallery,
                icon: const Icon(Icons.photo),
                label: const Text('Chọn ảnh'),
              ),
            ),
          ],
        ),

        if (imageFile != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              imageFile!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                imageFile = null;
              });
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Xóa ảnh'),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFixedEquipment = widget.initialEquipmentCode != null &&
        widget.initialEquipmentCode!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFixedEquipment
              ? 'Tạo phiếu cho thiết bị'
              : 'Tạo phiếu bảo trì',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          equipmentSection(),

          const SizedBox(height: 16),

          sectionTitle('Tiêu đề công việc'),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Kiểm tra camera định kỳ',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          sectionTitle('Loại công việc'),
          DropdownButtonFormField<String>(
            value: issueType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: issueTypes.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  issueType = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          sectionTitle('Mức độ ưu tiên'),
          DropdownButtonFormField<String>(
            value: priority,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: priorities.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  priority = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          sectionTitle('Người tạo phiếu'),
          TextField(
            controller: createdByController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          sectionTitle('Mô tả hiện trạng'),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'Mô tả tình trạng thiết bị, lỗi phát hiện, nội dung kiểm tra...',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          imageSection(),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: isSubmitting ? null : submitTicket,
            icon: const Icon(Icons.save),
            label: Text(
              isSubmitting ? 'Đang lưu...' : 'Lưu phiếu bảo trì',
            ),
          ),
        ],
      ),
    );
  }
}