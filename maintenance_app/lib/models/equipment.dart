class Equipment {
  final int id;
  final String code;
  final String name;
  final String? system;
  final String? equipmentType;
  final String? location;
  final String? floor;
  final String? area;
  final String? ipAddress;
  final String? serialNumber;
  final String? model;
  final String? manufacturer;
  final String? status;
  final String? description;

  Equipment({
    required this.id,
    required this.code,
    required this.name,
    this.system,
    this.equipmentType,
    this.location,
    this.floor,
    this.area,
    this.ipAddress,
    this.serialNumber,
    this.model,
    this.manufacturer,
    this.status,
    this.description,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      system: json['system'],
      equipmentType: json['equipment_type'],
      location: json['location'],
      floor: json['floor'],
      area: json['area'],
      ipAddress: json['ip_address'],
      serialNumber: json['serial_number'],
      model: json['model'],
      manufacturer: json['manufacturer'],
      status: json['status'],
      description: json['description'],
    );
  }
}