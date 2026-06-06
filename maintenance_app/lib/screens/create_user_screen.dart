import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController(text: '123456');
  final fullNameController = TextEditingController();

  String role = 'technician';
  bool isSubmitting = false;
  bool obscurePassword = true;

  final roles = ['admin', 'technician', 'supervisor'];

  String roleText(String role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'technician':
        return 'Kỹ thuật viên';
      case 'supervisor':
        return 'Giám sát';
      default:
        return role;
    }
  }

  Future<void> submit() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final fullName = fullNameController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập username và mật khẩu')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final success = await ApiService.createUser(
        username: username,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo tài khoản thành công')),
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
        title: const Text('Thêm tài khoản'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          textField(
            controller: usernameController,
            label: 'Tên đăng nhập',
          ),

          textField(
            controller: passwordController,
            label: 'Mật khẩu',
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

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Vai trò:\n'
                '- Admin: quản trị hệ thống\n'
                '- Kỹ thuật viên: tạo và xử lý phiếu\n'
                '- Giám sát: theo dõi dashboard và phiếu bảo trì',
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: isSubmitting ? null : submit,
            icon: const Icon(Icons.save),
            label: Text(isSubmitting ? 'Đang lưu...' : 'Lưu tài khoản'),
          ),
        ],
      ),
    );
  }
}