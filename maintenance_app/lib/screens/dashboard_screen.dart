import 'package:flutter/material.dart';

import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final String role;

  const DashboardScreen({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> futureDashboard;

  @override
  void initState() {
    super.initState();
    futureDashboard = ApiService.getDashboard(
      username: widget.username,
      role: widget.role,
    );
  }

  void reloadData() {
    setState(() {
      futureDashboard = ApiService.getDashboard(
        username: widget.username,
        role: widget.role,
      );
    });
  }

  Widget summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Mới tạo';
      case 'in_progress':
        return 'Đang xử lý';
      case 'done':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Widget statusCard(Map<String, dynamic> ticketStatus) {
    final items = [
      {'key': 'open', 'icon': Icons.fiber_new},
      {'key': 'in_progress', 'icon': Icons.pending_actions},
      {'key': 'done', 'icon': Icons.check_circle},
      {'key': 'cancelled', 'icon': Icons.cancel},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phiếu bảo trì theo trạng thái',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...items.map((item) {
              final key = item['key'] as String;
              final icon = item['icon'] as IconData;
              final count = ticketStatus[key] ?? 0;

              return ListTile(
                leading: Icon(icon),
                title: Text(statusLabel(key)),
                trailing: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget systemCard(List systems) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thiết bị theo hệ thống',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (systems.isEmpty)
              const Text('Chưa có dữ liệu hệ thống.')
            else
              ...systems.map((item) {
                return ListTile(
                  leading: const Icon(Icons.precision_manufacturing),
                  title: Text(item['system'].toString()),
                  trailing: Text(
                    item['count'].toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.role.trim().toLowerCase() == 'technician'
              ? 'Dashboard của tôi'
              : 'Dashboard bảo trì',
        ),
        actions: [
          IconButton(onPressed: reloadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureDashboard,
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

          final data = snapshot.data!;
          final ticketStatus = data['ticket_status'] as Map<String, dynamic>;
          final equipmentBySystem = data['equipment_by_system'] as List;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    widget.role.trim().toLowerCase() == 'technician'
                        ? 'Thống kê phiếu được giao cho tôi'
                        : 'Thống kê toàn bộ hệ thống',
                  ),
                  subtitle: Text(
                    'Tài khoản: ${widget.username} | Role: ${widget.role}',
                  ),
                ),
              ),

              const SizedBox(height: 12),
              
              summaryCard(
                icon: Icons.precision_manufacturing,
                title: 'Tổng số thiết bị',
                value: data['total_equipment'].toString(),
              ),
              summaryCard(
                icon: Icons.assignment,
                title: 'Tổng số phiếu bảo trì',
                value: data['total_tickets'].toString(),
              ),

              const SizedBox(height: 12),

              statusCard(ticketStatus),

              const SizedBox(height: 12),

              systemCard(equipmentBySystem),
            ],
          );
        },
      ),
    );
  }
}
