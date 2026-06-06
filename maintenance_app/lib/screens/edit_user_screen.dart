import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';

class EditUserScreen extends StatefulWidget {
  final AppUser user;

  const EditUserScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController fullNameController;

  String role = 'technician';
  bool isSubmitting = false;
  bool obscurePassword = true;

  final roles = ['admin', 'technician', 'supervisor'];

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(text: widget.user.username);
    passwordController = TextEditingController();
    fullNameController = TextEditingController(text: widget.user.fullName ?? '');
    role = roles.contains(widget.user.role) ? widget.user.role : 'technician';
  }

  String roleText(String value) {
    switch (value) {
      case 'admin':
        return 'Quản trị viên';
      case 'technician':
        return 'Kỹ thuật viên';
      case 'supervisor':
        return 'Giám sát';
      default:
        return value;
    }
  }

  Future<void> submit() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final fullName = fullNameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập username')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final success = await ApiService.updateUser(
        userId: widget.user.id,
        username: username,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật tài khoản')),
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
    usernameController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  Widget textField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa tài khoản'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge),
              title: Text('ID: ${widget.user.id}'),
              subtitle: const Text('Mã ID không sửa'),
            ),
          ),

          const SizedBox(height: 16),

          textField(
            controller: usernameController,
            label: 'Tên đăng nhập',
          ),

          textField(
            controller: passwordController,
            label: 'Mật khẩu mới',
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),

          const Text(
            'Để trống mật khẩu nếu không muốn đổi.',
            style: TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 14),

          textField(
            controller: fullNameController,
            label: 'Họ tên',
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(
                labelText: 'Vai trò',
                border: OutlineInputBorder(),
              ),
              items: roles.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(roleText(item)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    role = value;
                  });
                }
              },
            ),
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