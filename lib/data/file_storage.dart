import 'dart:io';
import 'dart:convert';
import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';

/// File-based storage for hospital bed data
class FileStorage {
  static const String _fileName = 'hospital_data.json';

  /// Save bed manager data to file
  static Future<void> saveBedData(BedManager bedManager) async {
    try {
      final file = File(_fileName);

      // Convert rooms and beds to JSON-serializable format
      final roomsData = bedManager.rooms.map((room) {
        return {
          'roomNumber': room.roomNumber,
          'roomType': room.roomType,
          'beds': room.beds.map((bed) {
            return {
              'bedNumber': bed.bedNumber,
              'isOccupied': bed.isOccupied,
              'patientName': bed.patientName,
              'assignedDate': bed.assignedDate?.toIso8601String(),
            };
          }).toList(),
        };
      }).toList();

      final jsonString = jsonEncode(roomsData);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// Load bed manager data from file
  static Future<BedManager> loadBedData() async {
    try {
      final file = File(_fileName);

      if (!file.existsSync()) {
        // If file doesn't exist, return empty manager
        return BedManager();
      }

      final jsonString = await file.readAsString();
      final roomsData = jsonDecode(jsonString) as List;

      final rooms = <Room>[];
      for (var roomData in roomsData) {
        final beds = <Bed>[];
        for (var bedData in roomData['beds'] as List) {
          final bed = Bed(
            bedNumber: bedData['bedNumber'] as String,
            isOccupied: bedData['isOccupied'] as bool,
            patientName: bedData['patientName'] as String?,
            assignedDate: bedData['assignedDate'] != null
                ? DateTime.parse(bedData['assignedDate'] as String)
                : null,
          );
          beds.add(bed);
        }

        final room = Room(
          roomNumber: roomData['roomNumber'] as String,
          roomType: roomData['roomType'] as String,
          beds: beds,
        );
        rooms.add(room);
      }

      return BedManager(rooms: rooms);
    } catch (e) {
      print('Error loading data: $e');
      return BedManager();
    }
  }

  /// Check if data file exists
  static bool hasExistingData() {
    return File(_fileName).existsSync();
  }

  /// Delete data file
  static Future<void> deleteData() async {
    try {
      final file = File(_fileName);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting data: $e');
    }
  }
}
