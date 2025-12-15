import 'dart:io';
import 'dart:convert';
import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';

// handles saving and loading bed data to/from json file
class FileStorage {
  // file name where we save data
  static const String _fileName = 'hospital_data.json';

  // save bed manager data to file
  // this is async (future) because file operations take time
  static Future<void> saveBedData(BedManager bedManager) async {
    try {
      // create a file object
      final file = File(_fileName);

      // step 1: convert all rooms and beds to a list that we can save
      List<Map> roomsData = [];

      for (var room in bedManager.rooms) {
        // convert beds to a list
        List<Map> bedsData = [];

        for (var bed in room.beds) {
          // create a map with bed information
          Map<String, Object?> bedMap = {};
          bedMap['bedNumber'] = bed.bedNumber;
          bedMap['isOccupied'] = bed.isOccupied;
          bedMap['patientName'] = bed.patientName;
          // convert date to text format for saving
          bedMap['assignedDate'] = bed.assignedDate?.toIso8601String();

          bedsData.add(bedMap);
        }

        // create a map with room information
        Map<String, Object> roomMap = {};
        roomMap['roomNumber'] = room.roomNumber;
        roomMap['roomType'] = room.roomType;
        roomMap['beds'] = bedsData;

        roomsData.add(roomMap);
      }

      // step 2: convert data to json format
      final jsonString = jsonEncode(roomsData);

      // step 3: write to file
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  // load bed manager data from file
  // this is async because reading files takes time
  static Future<BedManager> loadBedData() async {
    try {
      // create a file object
      final file = File(_fileName);

      // if file doesn't exist, return empty bedmanager
      if (!file.existsSync()) {
        return BedManager();
      }

      // step 1: read the file
      final jsonString = await file.readAsString();

      // step 2: convert json text back to data
      final roomsData = jsonDecode(jsonString);

      // step 3: create room and bed objects from data
      List<Room> rooms = [];

      for (var roomData in roomsData) {
        // create beds list
        List<Bed> beds = [];

        for (var bedData in roomData['beds']) {
          // get the assigned date if it exists
          DateTime? assignedDate;
          if (bedData['assignedDate'] != null) {
            // convert text back to datetime
            assignedDate = DateTime.parse(bedData['assignedDate']);
          }

          // create a bed with the saved data
          Bed newBed = Bed(
            bedNumber: bedData['bedNumber'],
            isOccupied: bedData['isOccupied'],
            patientName: bedData['patientName'],
            assignedDate: assignedDate,
          );
          beds.add(newBed);
        }

        // create a room with all its beds
        Room newRoom = Room(
          roomNumber: roomData['roomNumber'],
          roomType: roomData['roomType'],
          beds: beds,
        );
        rooms.add(newRoom);
      }

      // return the reconstructed bedmanager
      return BedManager(rooms: rooms);
    } catch (e) {
      print('Error loading data: $e');
      return BedManager();
    }
  }

  // check if the data file already exists
  static bool hasExistingData() {
    return File(_fileName).existsSync();
  }

  // delete the data file
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
