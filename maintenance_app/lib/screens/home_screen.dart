import 'package:flutter/material.dart';
import 'qr_scan_screen.dart';
import 'equipment_detail_screen.dart';
import 'maintenance_list_screen.dart';
import 'equipment_list_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'user_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final String fullName;
  final String role;
  final String username;

  const HomeScreen({
    super.key,
    required this.fullName,
    required this.role,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final codeController = TextEditingController();

  bool get isAdmin => widget.role == 'admin';
  bool get isTechnician => widget.role == 'technician';
  bool get isSupervisor => widget.role == 'supervisor';

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

  void openEquipmentByCode() {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã thiết bị')),
      );
      return;
    }

    Navigator.push(
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
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảo trì thiết bị sân bay'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'user',
                enabled: false,
                child: Text('${widget.fullName}\n${widget.role}'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  widget.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner, size: 36),
                title: const Text('Quét QR thiết bị'),
                subtitle: const Text('Quét mã QR dán trên thiết bị'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrScanScreen(
                        username: widget.username,
                        fullName: widget.fullName,
                        role: widget.role,
                      ),
                    ),
                  );
                },
              ),
            ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${widget.username} | ${roleText(widget.role)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.precision_manufacturing, size: 36),
                title: const Text('Danh sách thiết bị'),
                subtitle: const Text('Tìm kiếm và xem toàn bộ thiết bị'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipmentListScreen(
                        username: widget.username,
                        fullName: widget.fullName,
                        role: widget.role,
                      ),
                    ),
                  );
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment, size: 36),
                title: const Text('Danh sách phiếu bảo trì'),
                subtitle: const Text(
                  'Xem và cập nhật trạng thái các phiếu đã tạo',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaintenanceListScreen(
                        username: widget.username,
                        fullName: widget.fullName,
                        role: widget.role,
                      ),
                    ),
                  );
                },
              ),
            ),

            if (isAdmin || isSupervisor || isTechnician) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.dashboard, size: 36),
                  title: const Text('Dashboard bảo trì'),
                  subtitle: const Text(
                    'Xem tổng quan phiếu và trạng thái thiết bị',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardScreen(
                          username: widget.username,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (isAdmin) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.manage_accounts, size: 36),
                  title: const Text('Quản lý tài khoản'),
                  subtitle: const Text('Thêm/sửa người dùng và phân quyền'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserListScreen()),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),

            const Text(
              'Hoặc nhập mã thiết bị để test nhanh',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Mã thiết bị',
                hintText: 'Ví dụ: LTIA-CCTV-CAM-001',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: openEquipmentByCode,
              icon: const Icon(Icons.search),
              label: const Text('Tra cứu thiết bị'),
            ),

            const SizedBox(height: 24),

            const Text(
              'Mã test nhanh:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('LTIA-CCTV-CAM-001'),
            const Text('LTIA-CCTV-CAM-002'),
            const Text('LTIA-ACS-CR-001'),
            const Text('LTIA-FAS-DET-001'),
          ],
        ),
      ),
    );
  }
}
