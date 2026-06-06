import 'package:flutter/material.dart';

import '../models/maintenance_ticket.dart';
import '../services/api_service.dart';
import 'maintenance_detail_screen.dart';

class MaintenanceListScreen extends StatefulWidget {
  final String username;
  final String fullName;
  final String role;

  const MaintenanceListScreen({
    super.key,
    required this.username,
    required this.fullName,
    required this.role,
  });

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  late Future<List<MaintenanceTicket>> futureTickets;

  String selectedStatus = '';
  String selectedSystem = '';

  final keywordController = TextEditingController();
  final assignedToController = TextEditingController();

  final statuses = ['', 'open', 'in_progress', 'done', 'cancelled'];

  final systems = [
    '',
    'CCTV',
    'ACS',
    'FAS',
    'BHS',
    'FIDS',
    'CMS',
    'Network',
    'Other',
  ];

  bool get isTechnician => widget.role.trim().toLowerCase() == 'technician';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    String assignedFilter = assignedToController.text.trim();

    // Technician chỉ được xem phiếu được giao cho chính username của mình
    if (isTechnician) {
      assignedFilter = widget.username;
    }

    futureTickets = ApiService.getMaintenanceTickets(
      status: selectedStatus,
      system: selectedSystem,
      keyword: keywordController.text.trim(),
      assignedTo: assignedFilter,
    );
  }

  void reloadData() {
    setState(() {
      loadData();
    });
  }

  @override
  void dispose() {
    keywordController.dispose();
    assignedToController.dispose();
    super.dispose();
  }

  String statusText(String value) {
    switch (value) {
      case '':
        return 'Tất cả trạng thái';
      case 'open':
        return 'Mới tạo';
      case 'in_progress':
        return 'Đang xử lý';
      case 'done':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return value;
    }
  }

  String systemText(String value) {
    if (value.isEmpty) return 'Tất cả hệ thống';
    return value;
  }

  Widget filterBox() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Thông tin đăng nhập'),
                subtitle: Text(
                  'Username: ${widget.username}\nRole: ${widget.role}',
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (isTechnician) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_ind),
                  title: const Text('Phiếu được giao cho tôi'),
                  subtitle: Text('Tài khoản: ${widget.username}'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: keywordController,
              decoration: InputDecoration(
                labelText: 'Tìm mã thiết bị / tên thiết bị / lỗi',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    keywordController.clear();
                    reloadData();
                  },
                ),
              ),
              onSubmitted: (_) {
                reloadData();
              },
            ),

            const SizedBox(height: 12),

            if (!isTechnician) ...[
              TextField(
                controller: assignedToController,
                decoration: InputDecoration(
                  labelText: 'Lọc theo người phụ trách',
                  hintText: 'Ví dụ: thang, tech01',
                  prefixIcon: const Icon(Icons.person_search),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      assignedToController.clear();
                      reloadData();
                    },
                  ),
                ),
                onSubmitted: (_) {
                  reloadData();
                },
              ),
              const SizedBox(height: 12),
            ],

            DropdownButtonFormField<String>(
              value: selectedStatus,
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
                  selectedStatus = value;
                  reloadData();
                }
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedSystem,
              decoration: const InputDecoration(
                labelText: 'Hệ thống',
                border: OutlineInputBorder(),
              ),
              items: systems.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(systemText(item)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedSystem = value;
                  reloadData();
                }
              },
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: reloadData,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Lọc phiếu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTicketCard(MaintenanceTicket ticket) {
    final assignedText = ticket.assignedTo == null || ticket.assignedTo!.isEmpty
        ? 'Chưa gán'
        : '${ticket.assignedFullName ?? ticket.assignedTo} (${ticket.assignedTo})';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.assignment),
        title: Text('Phiếu #${ticket.id} - ${ticket.equipmentCode}'),
        subtitle: Text(
          'Trạng thái: ${statusText(ticket.status)}\n'
          'Phụ trách: $assignedText\n'
          'Ngày tạo: ${ticket.createdAt ?? ''}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MaintenanceDetailScreen(
                ticketId: ticket.id,
                username: widget.username,
                fullName: widget.fullName,
                role: widget.role,
              ),
            ),
          );

          if (result == true) {
            reloadData();
          }
        },
      ),
    );
  }

  void clearFilters() {
    setState(() {
      selectedStatus = '';
      selectedSystem = '';
      keywordController.clear();

      // Technician không dùng ô lọc người phụ trách
      if (!isTechnician) {
        assignedToController.clear();
      }

      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTechnician ? 'Phiếu của tôi' : 'Phiếu bảo trì'),
        actions: [
          IconButton(
            onPressed: clearFilters,
            icon: const Icon(Icons.filter_alt_off),
          ),
          IconButton(onPressed: reloadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<MaintenanceTicket>>(
        future: futureTickets,
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

          final tickets = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              filterBox(),

              const SizedBox(height: 12),

              Text(
                'Tổng số phiếu: ${tickets.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              if (tickets.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Không có phiếu phù hợp.'),
                  ),
                )
              else
                ...tickets.map((ticket) {
                  return buildTicketCard(ticket);
                }),
            ],
          );
        },
      ),
    );
  }
}
