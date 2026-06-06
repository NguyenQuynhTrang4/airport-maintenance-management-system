import 'package:flutter/material.dart';

import '../models/equipment.dart';
import '../services/api_service.dart';
import 'equipment_detail_screen.dart';
import 'create_equipment_screen.dart';

class EquipmentListScreen extends StatefulWidget {
  final String username;
  final String fullName;
  final String role;

  const EquipmentListScreen({
    super.key,
    required this.username,
    required this.fullName,
    required this.role,
  });

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  late Future<List<Equipment>> futureEquipment;
  final searchController = TextEditingController();

  String selectedSystem = 'all';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    futureEquipment = ApiService.getEquipmentList();
  }

  void reloadData() {
    setState(() {
      futureEquipment = ApiService.getEquipmentList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<String> getSystems(List<Equipment> equipmentList) {
    final systems = equipmentList
        .map((e) => e.system ?? '')
        .where((system) => system.trim().isNotEmpty)
        .toSet()
        .toList();

    systems.sort();
    return systems;
  }

  List<Equipment> filterEquipment(List<Equipment> equipmentList) {
    return equipmentList.where((equipment) {
      final matchesSystem =
          selectedSystem == 'all' ||
          (equipment.system ?? '').toLowerCase() ==
              selectedSystem.toLowerCase();

      final keyword = searchText.toLowerCase().trim();

      final matchesSearch =
          keyword.isEmpty ||
          equipment.code.toLowerCase().contains(keyword) ||
          equipment.name.toLowerCase().contains(keyword) ||
          (equipment.location ?? '').toLowerCase().contains(keyword) ||
          (equipment.floor ?? '').toLowerCase().contains(keyword) ||
          (equipment.area ?? '').toLowerCase().contains(keyword);

      return matchesSystem && matchesSearch;
    }).toList();
  }

  Widget buildSystemFilter(List<String> systems) {
    return SizedBox(
      height: 58,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tất cả'),
              selected: selectedSystem == 'all',
              onSelected: (_) {
                setState(() {
                  selectedSystem = 'all';
                });
              },
            ),
          ),

          ...systems.map((system) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(system),
                selected: selectedSystem == system,
                onSelected: (_) {
                  setState(() {
                    selectedSystem = system;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildEquipmentCard(Equipment equipment) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.precision_manufacturing),
        title: Text(equipment.name),
        subtitle: Text(
          '${equipment.code}\n'
          '${equipment.system ?? '-'} | ${equipment.floor ?? '-'} | ${equipment.area ?? '-'}\n'
          '${equipment.location ?? '-'}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EquipmentDetailScreen(
                equipmentCode: equipment.code,
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

  Future<void> openCreateEquipmentScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEquipmentScreen()),
    );

    if (result == true) {
      reloadData();
    }
  }

  void clearSearch() {
    searchController.clear();

    setState(() {
      searchText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thiết bị'),
        actions: [
          IconButton(onPressed: reloadData, icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: openCreateEquipmentScreen,
          ),
        ],
      ),
      body: FutureBuilder<List<Equipment>>(
        future: futureEquipment,
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

          final equipmentList = snapshot.data ?? [];
          final systems = getSystems(equipmentList);
          final filteredList = filterEquipment(equipmentList);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Tìm kiếm thiết bị',
                    hintText: 'Nhập mã, tên, vị trí...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchText.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: clearSearch,
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),

              buildSystemFilter(systems),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tìm thấy ${filteredList.length}/${equipmentList.length} thiết bị',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                        child: Text('Không tìm thấy thiết bị phù hợp.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return buildEquipmentCard(filteredList[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
