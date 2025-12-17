import 'dart:io';
import 'dart:convert';
import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';
import '../domain/room_type.dart';

class FileStorage {
  static const String _fileName = 'hospital_data.json';

  // save bed data
  static Future<bool> saveBedData(BedManager bedManager) async {
    try {
      final file = File(_fileName);

      // convert bed objects to json for readbility 
      List<Map> roomsData = [];

      for (var room in bedManager.rooms) {
        List<Map> bedsData = [];

        for (var bed in room.beds) {
          Map<String, Object?> bedMap = {};
          bedMap['bedNumber'] = bed.bedNumber;
          bedMap['isOccupied'] = bed.isOccupied;
          bedMap['patientName'] = bed.patientName;

          if (bed.assignedDate != null) {
            bedMap['assignedDate'] = bed.assignedDate!.toIso8601String();
          } else {
            bedMap['assignedDate'] = null;
          }

          bedsData.add(bedMap);
        }

        Map<String, Object> roomMap = {};
        roomMap['roomNumber'] = room.roomNumber;
        roomMap['roomType'] = room.roomType.toString();
        roomMap['beds'] = bedsData;

        roomsData.add(roomMap);
      }

      final jsonString = jsonEncode(roomsData); // Convert to json text

      // write to json
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      print('Error saving data: $e');
      return false;
    }
  }
 // load bed data
  static Future<BedManager> loadBedData() async {
    try {
      final file = File(_fileName);

      if (!file.existsSync()) {
        return BedManager();
      }

      // read from file
      final jsonString = await file.readAsString();
      // convert json text to dart objects
      final roomsData = jsonDecode(jsonString);

      List<Room> rooms = [];

      for (var roomData in roomsData) {
        List<Bed> beds = [];

        for (var bedData in roomData['beds']) {
          DateTime? assignedDate;
          if (bedData['assignedDate'] != null) {
            assignedDate = DateTime.parse(bedData['assignedDate']);
          }
          // extract data from json
          Bed newBed = Bed(
            bedNumber: bedData['bedNumber'], // getting data back
            isOccupied: bedData['isOccupied'],
            patientName: bedData['patientName'],
            assignedDate: assignedDate,
          );
          beds.add(newBed);
        }

        Room newRoom = Room(  //recreate room object
          roomNumber: roomData['roomNumber'],
          roomType: RoomType.fromString(roomData['roomType']),
          beds: beds,
        );
        rooms.add(newRoom);
      }

      return BedManager(rooms: rooms);
    } catch (e) {
      print('Error loading data: $e');
      return BedManager();
    }
  }

  static bool hasExistingData() {
    final file = File(_fileName);
    return file.existsSync();
  }
}
