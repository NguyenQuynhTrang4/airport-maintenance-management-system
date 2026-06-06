import 'package:flutter/material.dart';

import '../models/equipment.dart';
import '../services/api_service.dart';
import 'create_maintenance_screen.dart';
import 'edit_equipment_screen.dart';
import 'equipment_qr_screen.dart';
import '../models/maintenance_ticket.dart';
import 'maintenance_detail_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final String equipmentCode;
  final String username;
  final String fullName;
  final String role;

  const EquipmentDetailScreen({
    super.key,
    required this.equipmentCode,
    required this.username,
    required this.fullName,
    required this.role,
  });

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  late Future<Equipment> futureEquipment;
  late Future<List<MaintenanceTicket>> futureMaintenanceHistory;

  bool get isAdmin => widget.role.trim().toLowerCase() == 'admin';
  bool get isSupervisor => widget.role.trim().toLowerCase() == 'supervisor';
  bool get canEditEquipment => isAdmin || isSupervisor;

  @override
  void initState() {
    super.initState();
    loadEquipment();
    loadMaintenanceHistory();
  }

  void loadMaintenanceHistory() {
    futureMaintenanceHistory = ApiService.getEquipmentMaintenanceHistory(
      equipmentCode: widget.equipmentCode,
      username: widget.username,
      role: widget.role,
    );
  }

  void reloadMaintenanceHistory() {
    setState(() {
      loadMaintenanceHistory();
    });
  }

  void loadEquipment() {
    futureEquipment = ApiService.getEquipmentOnly(widget.equipmentCode);
  }

  void reloadData() {
    setState(() {
      loadEquipment();
      loadMaintenanceHistory();
    });
  }

  String ticketStatusText(String status) {
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

  Widget buildMaintenanceHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử phiếu bảo trì của thiết bị',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),

            FutureBuilder<List<MaintenanceTicket>>(
              future: futureMaintenanceHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  );
                }

                final tickets = snapshot.data ?? [];

                if (tickets.isEmpty) {
                  return const Text('Thiết bị này chưa có phiếu bảo trì.');
                }

                return Column(
                  children: tickets.map((ticket) {
                    final assignedText =
                        ticket.assignedTo == null || ticket.assignedTo!.isEmpty
                        ? 'Chưa gán'
                        : '${ticket.assignedFullName ?? ticket.assignedTo} (${ticket.assignedTo})';

                    return ListTile(
                      leading: const Icon(Icons.assignment),
                      title: Text(
                        'Phiếu #${ticket.id} - ${ticket.title}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Trạng thái: ${ticketStatusText(ticket.status)}\n'
                        'Phụ trách: $assignedText\n'
                        'Ngày tạo: ${ticket.createdAt ?? ''}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaintenanceDetailScreen(
                              ticketId: ticket.id,
                              username: widget.username,
                              fullName: widget.username,
                              role: widget.role,
                            ),
                          ),
                        );

                        if (result == true) {
                          reloadMaintenanceHistory();
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value == null || value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  String statusText(String? status) {
    switch (status) {
      case 'normal':
        return 'Bình thường';
      case 'fault':
        return 'Đang lỗi';
      case 'maintenance':
        return 'Đang bảo trì';
      default:
        return status ?? '-';
    }
  }

  Future<void> openCreateMaintenanceScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMaintenanceScreen(
          initialEquipmentCode: widget.equipmentCode,
          username: widget.username,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã tạo phiếu bảo trì')));

      reloadMaintenanceHistory();
    }
  }

  Future<void> openEditEquipmentScreen(Equipment equipment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEquipmentScreen(equipment: equipment),
      ),
    );

    if (result == true) {
      reloadData();
    }
  }

  void openQrScreen(Equipment equipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentQrScreen(
          equipmentCode: equipment.code,
          equipmentName: equipment.name,
        ),
      ),
    );
  }

  Widget buildInfoCard(Equipment equipment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              equipment.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            infoRow('Mã thiết bị', equipment.code),
            infoRow('Hệ thống', equipment.system),
            infoRow('Tầng', equipment.floor),
            infoRow('Khu vực', equipment.area),
            infoRow('Vị trí', equipment.location),
            infoRow('Trạng thái', statusText(equipment.status)),
            infoRow('Loại thiết bị', equipment.equipmentType),
            infoRow('IP Address', equipment.ipAddress),
            infoRow('Serial', equipment.serialNumber),
            infoRow('Model', equipment.model),
            infoRow('Hãng SX', equipment.manufacturer),
            //infoRow('Ngày tạo', equipment.createdAt),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons(Equipment equipment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Thao tác',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: openCreateMaintenanceScreen,
              icon: const Icon(Icons.add_task),
              label: const Text('Tạo phiếu bảo trì cho thiết bị này'),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: () => openQrScreen(equipment),
              icon: const Icon(Icons.qr_code),
              label: const Text('Xem mã QR thiết bị'),
            ),

            if (canEditEquipment) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => openEditEquipmentScreen(equipment),
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa thiết bị'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildPermissionNote() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Thông tin người thao tác'),
        subtitle: Text('Tài khoản: ${widget.username}\nRole: ${widget.role}'),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Equipment>(
      future: futureEquipment,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Đang tải...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final equipment = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text(equipment.code)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildPermissionNote(),

              const SizedBox(height: 16),

              buildInfoCard(equipment),

              const SizedBox(height: 16),

              buildActionButtons(equipment),

              const SizedBox(height: 16),

              buildMaintenanceHistorySection(),
            ],
          ),
        );
      },
    );
  }
}
