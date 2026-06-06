import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';
import 'create_user_screen.dart';
import 'edit_user_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<AppUser>> futureUsers;

  Future<void> toggleUserActive(AppUser user) async {
    final newActive = user.isActive ? 0 : 1;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.isActive ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'),
          content: Text(
            user.isActive
                ? 'Bạn có chắc muốn khóa tài khoản ${user.username}?'
                : 'Bạn có chắc muốn mở khóa tài khoản ${user.username}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(user.isActive ? 'Khóa' : 'Mở khóa'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.updateUserActive(userId: user.id, active: newActive);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isActive ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản',
          ),
        ),
      );

      reloadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    super.initState();
    futureUsers = ApiService.getUsers();
  }

  void reloadData() {
    setState(() {
      futureUsers = ApiService.getUsers();
    });
  }

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

  IconData roleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'supervisor':
        return Icons.supervisor_account;
      case 'technician':
        return Icons.engineering;
      default:
        return Icons.person;
    }
  }

  Widget buildUserCard(AppUser user) {
    return Card(
      child: ListTile(
        leading: Icon(roleIcon(user.role)),
        title: Text(
          user.fullName == null || user.fullName!.isEmpty
              ? user.username
              : user.fullName!,
        ),
        subtitle: Text(
          '${user.username}\n${roleText(user.role)}\n'
          '${user.isActive ? 'Đang hoạt động' : 'Đã khóa'}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditUserScreen(user: user)),
              );

              if (result == true) {
                reloadData();
              }
            }

            if (value == 'toggle') {
              await toggleUserActive(user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Sửa tài khoản')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(
                user.isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
              ),
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditUserScreen(user: user)),
          );

          if (result == true) {
            reloadData();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tài khoản'),
        actions: [
          IconButton(onPressed: reloadData, icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateUserScreen()),
              );

              if (result == true) {
                reloadData();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<AppUser>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('Chưa có tài khoản nào.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return buildUserCard(users[index]);
            },
          );
        },
      ),
    );
  }
}
