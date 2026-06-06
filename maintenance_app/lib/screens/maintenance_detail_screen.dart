import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/maintenance_note.dart';
import '../models/maintenance_ticket.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';

class MaintenanceDetailScreen extends StatefulWidget {
  final int ticketId;
  final String username;
  final String fullName;
  final String role;

  const MaintenanceDetailScreen({
    super.key,
    required this.ticketId,
    required this.username,
    required this.fullName,
    required this.role,
  });

  @override
  State<MaintenanceDetailScreen> createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  late Future<MaintenanceTicket> futureTicket;
  late Future<List<MaintenanceNote>> futureNotes;

  final noteController = TextEditingController();

  bool isUpdating = false;
  bool isAddingNote = false;

  bool get isAdmin => widget.role.trim().toLowerCase() == 'admin';
  bool get isSupervisor => widget.role.trim().toLowerCase() == 'supervisor';
  bool get isTechnician => widget.role.trim().toLowerCase() == 'technician';

  bool get canManageTicket => isAdmin || isSupervisor;

  @override
  void initState() {
    super.initState();
    loadTicket();
    loadNotes();
  }

  void loadTicket() {
    futureTicket = ApiService.getMaintenanceTicketById(widget.ticketId);
  }

  void loadNotes() {
    futureNotes = ApiService.getMaintenanceNotes(ticketId: widget.ticketId);
  }

  void reloadTicket() {
    setState(() {
      loadTicket();
    });
  }

  void reloadNotes() {
    setState(() {
      loadNotes();
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String statusText(String status) {
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

  String roleText(String role) {
    switch (role.trim().toLowerCase()) {
      case 'admin':
        return 'Quản trị hệ thống';
      case 'supervisor':
        return 'Giám sát bảo trì';
      case 'technician':
        return 'Kỹ thuật viên';
      default:
        return role;
    }
  }

  bool isAssignedToMe(MaintenanceTicket ticket) {
    final assignedTo = ticket.assignedTo?.trim().toLowerCase() ?? '';
    final username = widget.username.trim().toLowerCase();

    return assignedTo == username;
  }

  bool technicianCanUpdate(MaintenanceTicket ticket) {
    return isTechnician && isAssignedToMe(ticket);
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

  Future<void> updateStatus(String status) async {
    setState(() {
      isUpdating = true;
    });

    try {
      final success = await ApiService.updateMaintenanceStatus(
        ticketId: widget.ticketId,
        status: status,
        updatedBy: widget.username,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái: ${statusText(status)}'),
          ),
        );

        reloadTicket();
        reloadNotes();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> confirmUpdateStatus(String status) async {
    String title = '';
    String message = '';

    if (status == 'in_progress') {
      title = 'Chuyển sang đang xử lý';
      message =
          'Bạn có chắc muốn chuyển phiếu này sang trạng thái đang xử lý không?';
    } else if (status == 'done') {
      title = 'Đánh dấu hoàn thành';
      message = 'Bạn có chắc phiếu này đã được xử lý hoàn thành không?';
    } else if (status == 'cancelled') {
      title = 'Hủy phiếu';
      message =
          'Bạn có chắc muốn hủy phiếu này không? Thao tác này sẽ được ghi vào lịch sử xử lý.';
    } else {
      title = 'Cập nhật trạng thái';
      message = 'Bạn có chắc muốn cập nhật trạng thái phiếu không?';
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await updateStatus(status);
    }
  }

  Future<void> assignTicket(MaintenanceTicket ticket) async {
    if (!canManageTicket) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không có quyền gán người phụ trách')),
      );
      return;
    }

    try {
      final users = await ApiService.getUsers();

      final technicians = users.where((user) {
        final role = user.role.trim().toLowerCase();
        return role == 'technician' && user.active == 1;
      }).toList();

      if (!mounted) return;

      if (technicians.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có tài khoản kỹ thuật viên đang hoạt động'),
          ),
        );
        return;
      }

      String selectedUsername = ticket.assignedTo ?? technicians.first.username;

      final assignedTo = await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Gán người phụ trách'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: DropdownButtonFormField<String>(
                    value: selectedUsername,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Chọn kỹ thuật viên',
                      border: OutlineInputBorder(),
                    ),
                    items: technicians.map((user) {
                      return DropdownMenuItem(
                        value: user.username,
                        child: Text(
                          '${user.fullName} (${user.username})',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return technicians.map((user) {
                        return Text(
                          '${user.fullName} (${user.username})',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }).toList();
                    },
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedUsername = value;
                        });
                      }
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedUsername);
                    },
                    child: const Text('Gán'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (assignedTo == null || assignedTo.isEmpty) return;

      await ApiService.assignMaintenanceTicket(
        ticketId: ticket.id,
        assignedTo: assignedTo,
        assignedBy: widget.username,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã gán người phụ trách')));

      reloadTicket();
      reloadNotes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> submitNote() async {
    final note = noteController.text.trim();

    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung ghi chú')),
      );
      return;
    }

    setState(() {
      isAddingNote = true;
    });

    try {
      await ApiService.createMaintenanceNote(
        ticketId: widget.ticketId,
        note: note,
        createdBy: widget.fullName.isNotEmpty
            ? widget.fullName
            : widget.username,
      );

      if (!mounted) return;

      noteController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm ghi chú xử lý')));

      reloadNotes();
      reloadTicket();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isAddingNote = false;
        });
      }
    }
  }

  Widget buildPermissionCard(MaintenanceTicket ticket) {
    String title;
    String subtitle;
    IconData icon;

    if (isAdmin) {
      icon = Icons.admin_panel_settings;
      title = 'Quyền Admin';
      subtitle =
          'Được gán người phụ trách, cập nhật trạng thái, hủy phiếu và thêm ghi chú.';
    } else if (isSupervisor) {
      icon = Icons.supervisor_account;
      title = 'Quyền Supervisor';
      subtitle =
          'Được gán người phụ trách, cập nhật trạng thái, hủy phiếu và thêm ghi chú.';
    } else if (isTechnician) {
      icon = Icons.engineering;
      title = 'Quyền Technician';

      if (isAssignedToMe(ticket)) {
        subtitle =
            'Phiếu này được giao cho bạn. Bạn được cập nhật đang xử lý, hoàn thành và thêm ghi chú.';
      } else {
        subtitle =
            'Phiếu này không được giao cho bạn. Bạn chỉ nên xem thông tin, không cập nhật trạng thái.';
      }
    } else {
      icon = Icons.person;
      title = 'Thông tin quyền';
      subtitle = 'Role: ${widget.role}';
    }

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          '$subtitle\nTài khoản: ${widget.username} | Role: ${roleText(widget.role)}',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget buildInfoCard(MaintenanceTicket ticket) {
    final assignedText = ticket.assignedTo == null || ticket.assignedTo!.isEmpty
        ? 'Chưa gán'
        : '${ticket.assignedFullName ?? ticket.assignedTo} (${ticket.assignedTo})';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            infoRow('Trạng thái', statusText(ticket.status)),
            infoRow('Mã thiết bị', ticket.equipmentCode),
            infoRow('Tên thiết bị', ticket.equipmentName),
            infoRow('Hệ thống', ticket.equipmentSystem),
            infoRow('Vị trí', ticket.equipmentLocation),
            infoRow('Loại việc', ticket.issueType),
            infoRow('Ưu tiên', ticket.priority),
            infoRow('Phụ trách', assignedText),
            infoRow('Người tạo', ticket.createdBy),
            infoRow('Ngày tạo', ticket.createdAt),
            infoRow('Cập nhật', ticket.updatedAt),
            infoRow('Mô tả', ticket.description),
          ],
        ),
      ),
    );
  }

  Widget buildImage(MaintenanceTicket ticket) {
    if (ticket.imagePath == null || ticket.imagePath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageUrl = '${ApiConfig.baseUrl}${ticket.imagePath}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Ảnh hiện trường',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Không tải được ảnh hiện trường'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildStatusButtons(MaintenanceTicket ticket) {
    final bool canTechnicianUpdate = technicianCanUpdate(ticket);
    final bool canUpdateStatus = canManageTicket || canTechnicianUpdate;
    final bool canCancel = canManageTicket;
    final bool canAssign = canManageTicket;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cập nhật phiếu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),

            if (canAssign) ...[
              ElevatedButton.icon(
                onPressed: () => assignTicket(ticket),
                icon: const Icon(Icons.person_add),
                label: const Text('Gán người phụ trách'),
              ),
              const SizedBox(height: 8),
            ],

            ElevatedButton.icon(
              onPressed: isUpdating || !canUpdateStatus
                  ? null
                  : () => confirmUpdateStatus('in_progress'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Chuyển sang đang xử lý'),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: isUpdating || !canUpdateStatus
                  ? null
                  : () => confirmUpdateStatus('done'),
              icon: const Icon(Icons.check_circle),
              label: const Text('Đánh dấu hoàn thành'),
            ),

            const SizedBox(height: 8),

            if (canCancel)
              OutlinedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () => confirmUpdateStatus('cancelled'),
                icon: const Icon(Icons.cancel),
                label: const Text('Hủy phiếu'),
              ),

            if (isTechnician && !isAssignedToMe(ticket)) ...[
              const SizedBox(height: 12),
              const Text(
                'Bạn không phải người phụ trách phiếu này nên không thể cập nhật trạng thái.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget notesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghi chú xử lý',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nhập ghi chú xử lý',
                hintText: 'Ví dụ: Đã kiểm tra nguồn, chờ vật tư thay thế...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAddingNote ? null : submitNote,
                icon: const Icon(Icons.note_add),
                label: Text(isAddingNote ? 'Đang lưu...' : 'Thêm ghi chú'),
              ),
            ),

            const Divider(height: 32),

            FutureBuilder<List<MaintenanceNote>>(
              future: futureNotes,
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

                final notes = snapshot.data ?? [];

                if (notes.isEmpty) {
                  return const Text('Chưa có ghi chú xử lý.');
                }

                return Column(
                  children: notes.map((item) {
                    return ListTile(
                      leading: const Icon(Icons.notes),
                      title: Text(item.note),
                      subtitle: Text(
                        'Người ghi: ${item.createdBy ?? ''}\n'
                        'Thời gian: ${item.createdAt ?? ''}',
                      ),
                      isThreeLine: true,
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MaintenanceTicket>(
      future: futureTicket,
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

        final ticket = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text('Phiếu #${ticket.id}')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              buildPermissionCard(ticket),

              const SizedBox(height: 16),

              buildInfoCard(ticket),

              buildImage(ticket),

              const SizedBox(height: 16),

              buildStatusButtons(ticket),

              const SizedBox(height: 16),

              notesSection(),
            ],
          ),
        );
      },
    );
  }
}
