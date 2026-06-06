class MaintenanceNote {
  final int id;
  final int ticketId;
  final String note;
  final String? createdBy;
  final String? createdAt;

  MaintenanceNote({
    required this.id,
    required this.ticketId,
    required this.note,
    this.createdBy,
    this.createdAt,
  });

  factory MaintenanceNote.fromJson(Map<String, dynamic> json) {
    return MaintenanceNote(
      id: json['id'] ?? 0,
      ticketId: json['ticket_id'] ?? 0,
      note: json['note'] ?? '',
      createdBy: json['created_by'],
      createdAt: json['created_at'],
    );
  }
}