import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/equipment.dart';
import '../models/maintenance_ticket.dart';
import '../models/app_user.dart';
import '../models/maintenance_note.dart';

class ApiService {
  static Future<List<MaintenanceNote>> getMaintenanceNotes({
    required int ticketId,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/maintenance/$ticketId/notes',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => MaintenanceNote.fromJson(item)).toList();
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không tải được ghi chú xử lý: $body');
    }
  }

  static Future<bool> createMaintenanceNote({
    required int ticketId,
    required String note,
    required String createdBy,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/maintenance/$ticketId/notes',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'note': note, 'created_by': createdBy},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không thêm được ghi chú: $body');
    }
  }

  static Future<bool> assignMaintenanceTicket({
    required int ticketId,
    required String assignedTo,
    required String assignedBy,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/maintenance/$ticketId/assign',
    );

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'assigned_to': assignedTo, 'assigned_by': assignedBy},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không gán được người phụ trách: $body');
    }
  }

  static Future<Map<String, dynamic>> getEquipmentByCode(String code) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/equipment/$code');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy thiết bị có mã: $code');
    } else {
      throw Exception('Lỗi server: ${response.statusCode}');
    }
  }

  static Future<Equipment> getEquipmentOnly(String code) async {
    final data = await getEquipmentByCode(code);
    return Equipment.fromJson(data['equipment']);
  }

  static Future<bool> createMaintenanceTicket({
    required String equipmentCode,
    required String title,
    required String issueType,
    required String priority,
    required String description,
    required String createdBy,
    File? imageFile,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/maintenance');

    final request = http.MultipartRequest('POST', url);

    request.fields['equipment_code'] = equipmentCode;
    request.fields['title'] = title;
    request.fields['issue_type'] = issueType;
    request.fields['priority'] = priority;
    request.fields['description'] = description;
    request.fields['created_by'] = createdBy;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      return true;
    } else {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Không tạo được phiếu bảo trì: $responseBody');
    }
  }

  static Future<List<MaintenanceTicket>> getMaintenanceTickets({
    String status = '',
    String system = '',
    String keyword = '',
    String assignedTo = '',
  }) async {
    final queryParams = <String, String>{};

    if (status.isNotEmpty) {
      queryParams['status'] = status;
    }

    if (system.isNotEmpty) {
      queryParams['system'] = system;
    }

    if (keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }

    if (assignedTo.isNotEmpty) {
      queryParams['assigned_to'] = assignedTo;
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/maintenance',
    ).replace(queryParameters: queryParams);

    print('Maintenance API URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => MaintenanceTicket.fromJson(item)).toList();
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không tải được danh sách phiếu bảo trì: $body');
    }
  }

  static Future<MaintenanceTicket> getMaintenanceTicketById(
    int ticketId,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/maintenance/$ticketId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return MaintenanceTicket.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy phiếu bảo trì ID: $ticketId');
    } else {
      throw Exception('Lỗi server: ${response.statusCode}');
    }
  }

  static Future<bool> updateMaintenanceStatus({
    required int ticketId,
    required String status,
    required String updatedBy,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/maintenance/$ticketId/status',
    );

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'status': status, 'updated_by': updatedBy},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không cập nhật được trạng thái: $body');
    }
  }

  static Future<List<Equipment>> getEquipmentList() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/equipment');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Equipment.fromJson(item)).toList();
    } else {
      throw Exception('Không tải được danh sách thiết bị');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      throw Exception('Sai tên đăng nhập hoặc mật khẩu');
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Lỗi đăng nhập: ${response.statusCode} - $body');
    }
  }

  static Future<Map<String, dynamic>> getDashboard({
    required String username,
    required String role,
  }) async {
    final queryParams = <String, String>{'username': username, 'role': role};

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/dashboard',
    ).replace(queryParameters: queryParams);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không tải được dữ liệu dashboard: $body');
    }
  }

  static Future<bool> createEquipment({
    required String code,
    required String name,
    required String system,
    required String equipmentType,
    required String location,
    required String floor,
    required String area,
    required String ipAddress,
    required String serialNumber,
    required String model,
    required String manufacturer,
    required String status,
    required String description,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/equipment');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'code': code,
        'name': name,
        'system': system,
        'equipment_type': equipmentType,
        'location': location,
        'floor': floor,
        'area': area,
        'ip_address': ipAddress,
        'serial_number': serialNumber,
        'model': model,
        'manufacturer': manufacturer,
        'status': status,
        'description': description,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không thêm được thiết bị: $body');
    }
  }

  static Future<bool> updateEquipment({
    required String code,
    required String name,
    required String system,
    required String equipmentType,
    required String location,
    required String floor,
    required String area,
    required String ipAddress,
    required String serialNumber,
    required String model,
    required String manufacturer,
    required String status,
    required String description,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/equipment/$code');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'name': name,
        'system': system,
        'equipment_type': equipmentType,
        'location': location,
        'floor': floor,
        'area': area,
        'ip_address': ipAddress,
        'serial_number': serialNumber,
        'model': model,
        'manufacturer': manufacturer,
        'status': status,
        'description': description,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không cập nhật được thiết bị: $body');
    }
  }

  static Future<List<AppUser>> getUsers() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/users');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => AppUser.fromJson(item)).toList();
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không tải được danh sách tài khoản: $body');
    }
  }

  static Future<List<MaintenanceTicket>> getEquipmentMaintenanceHistory({
    required String equipmentCode,
    required String username,
    required String role,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/equipment/$equipmentCode/maintenance',
    ).replace(queryParameters: {'username': username, 'role': role});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => MaintenanceTicket.fromJson(item)).toList();
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không tải được lịch sử phiếu bảo trì: $body');
    }
  }

  static Future<bool> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
        'full_name': fullName,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không tạo được tài khoản: $body');
    }
  }

  static Future<bool> updateUser({
    required int userId,
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
        'full_name': fullName,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không cập nhật được tài khoản: $body');
    }
  }

  static Future<bool> updateUserActive({
    required int userId,
    required int active,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/active');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'active': active.toString()},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('Không cập nhật được trạng thái tài khoản: $body');
    }
  }
}
