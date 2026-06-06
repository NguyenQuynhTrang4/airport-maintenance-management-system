class MaintenanceTicket {
  final int id;
  final String equipmentCode;
  final String? equipmentName;
  final String? equipmentSystem;
  final String? equipmentLocation;
  final String title;
  final String? issueType;
  final String? priority;
  final String? description;
  final String? imagePath;
  final String status;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? assignedTo;
  final String? assignedFullName;

  MaintenanceTicket({
    required this.id,
    required this.equipmentCode,
    this.equipmentName,
    this.equipmentSystem,
    this.equipmentLocation,
    required this.title,
    this.issueType,
    this.priority,
    this.description,
    this.imagePath,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.assignedTo,
    this.assignedFullName,
  });

  factory MaintenanceTicket.fromJson(Map<String, dynamic> json) {
    return MaintenanceTicket(
      id: json['id'] ?? 0,
      equipmentCode: json['equipment_code'] ?? '',
      equipmentName: json['equipment_name'],
      equipmentSystem: json['equipment_system'],
      equipmentLocation: json['equipment_location'],
      title: json['title'] ?? '',
      issueType: json['issue_type'],
      priority: json['priority'],
      description: json['description'],
      imagePath: json['image_path'],
      status: json['status'] ?? 'open',
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      assignedTo: json['assigned_to'],
      assignedFullName: json['assigned_full_name'],
    );
  }
}