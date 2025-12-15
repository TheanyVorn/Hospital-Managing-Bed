import 'package:test/domain/bed.dart';
import 'room.dart';

// manages all hospital rooms and beds
class BedManager {
  // list to store all the rooms
  final List<Room> rooms;

  // constructor - initialize with rooms or empty list
  BedManager({List<Room>? rooms}) : rooms = rooms ?? [];

  // add new room
  void addRoom(Room room) {
    // check if room already exists
    for (var existingRoom in rooms) {
      if (existingRoom.roomNumber == room.roomNumber) {
        throw Exception('Room ${room.roomNumber} already exists');
      }
    }
    rooms.add(room);
  }

  // find a room by room number
  // returns the room if found, or null if not found
  Room? findRoom(String roomNumber) {
    for (var room in rooms) {
      if (room.roomNumber == roomNumber) {
        return room; // Found the room, return it
      }
    }
    return null; // room not found
  }

  // assign a patient to a specific bed
  void assignBedToPatient(
    String roomNumber,
    String bedNumber,
    String patientName,
  ) {
    // step 1: find the room
    Room? room = findRoom(roomNumber);
    if (room == null) {
      throw Exception('Room $roomNumber not found');
    }

    // step 2: find the bed in the room
    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      throw Exception('Bed $bedNumber not found in room $roomNumber');
    }

    // step 3: assign the patient to the bed
    bed.assignPatient(patientName);
  }

  // release a bed (discharge patient)
  void releaseBed(String roomNumber, String bedNumber) {
    // step 1: find the room
    Room? room = findRoom(roomNumber);
    if (room == null) {
      throw Exception('Room $roomNumber not found');
    }

    // step 2: find the bed in the room
    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      throw Exception('Bed $bedNumber not found in room $roomNumber');
    }

    // step 3: release the bed
    bed.releaseBed();
  }

  // count total available beds across all rooms
  int getTotalAvailableBeds() {
    int total = 0;
    for (var room in rooms) {
      total = total + room.getAvailableBedsCount();
    }
    return total;
  }

  // count total occupied beds across all rooms
  int getTotalOccupiedBeds() {
    int total = 0;
    for (var room in rooms) {
      total = total + room.getOccupiedBedsCount();
    }
    return total;
  }

  // count total beds across all rooms
  int getTotalBeds() {
    int total = 0;
    for (var room in rooms) {
      total = total + room.getTotalBedsCount();
    }
    return total;
  }

  // get rooms by type (e.g., "icu", "general")
  List<Room> getRoomsByType(String roomType) {
    List<Room> result = [];
    for (var room in rooms) {
      if (room.roomType == roomType) {
        result.add(room);
      }
    }
    return result;
  }

  // find patients by name - searches through all beds
  List<Map<String, String>> findPatient(String patientName) {
    List<Map<String, String>> results = [];

    // loop through all rooms
    for (var room in rooms) {
      // loop through all beds in each room
      for (var bed in room.beds) {
        // check if bed has a patient
        if (bed.isOccupied && bed.patientName != null) {
          // convert patient name to lowercase for comparison
          String pName = bed.patientName!.toLowerCase();
          String searchName = patientName.toLowerCase();

          // check if patient name contains the search text
          if (pName.contains(searchName)) {
            // add this patient to results
            results.add({
              'roomNumber': room.roomNumber,
              'bedNumber': bed.bedNumber,
              'patientName': bed.patientName!,
              'assignedDate': bed.assignedDate.toString(),
            });
          }
        }
      }
    }

    return results;
  }
}
