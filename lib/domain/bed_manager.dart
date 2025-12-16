import 'package:test/domain/bed.dart';
import 'room.dart';
import 'room_type.dart';

class BedManager {
  final List<Room> rooms;

  BedManager({List<Room>? rooms}) : rooms = rooms ?? [];

  void addRoom(Room room) {
    for (var existingRoom in rooms) {
      if (existingRoom.roomNumber == room.roomNumber) {
        throw Exception('Room ${room.roomNumber} already exists');
      }
    }
    rooms.add(room);
  }

  Room? findRoom(String roomNumber) {
    for (var room in rooms) {
      if (room.roomNumber == roomNumber) {
        return room;
      }
    }
    return null;
  }

  void assignBedToPatient(
    String roomNumber,
    String bedNumber,
    String patientName,
  ) {
    Room? room = findRoom(roomNumber);
    if (room == null) {
      throw Exception('Room $roomNumber not found');
    }

    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      throw Exception('Bed $bedNumber not found in room $roomNumber');
    }

    bed.assignPatient(patientName);
  }

  void releaseBed(String roomNumber, String bedNumber) {
    Room? room = findRoom(roomNumber);
    if (room == null) {
      throw Exception('Room $roomNumber not found');
    }

    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      throw Exception('Bed $bedNumber not found in room $roomNumber');
    }

    bed.releaseBed();
  }

  int getTotalAvailableBeds() {
    int total = 0;
    for (var room in rooms) {
      total = total + room.getAvailableBedsCount();
    }
    return total;
  }

  int getTotalOccupiedBeds() {
    int total = 0;
    for (var room in rooms) {
      total = total + room.getOccupiedBedsCount();
    }
    return total;
  }

  int getTotalBeds() {
    int total = 0;
    for (var room in rooms) {
      total = total + room.getTotalBedsCount();
    }
    return total;
  }

  List<Room> getRoomsByType(RoomType roomType) {
    List<Room> result = [];
    for (var room in rooms) {
      if (room.roomType == roomType) {
        result.add(room);
      }
    }
    return result;
  }

  List<Map<String, String>> findPatient(String patientName) {
    List<Map<String, String>> results = [];

    for (var room in rooms) {
      for (var bed in room.beds) {
        if (bed.isOccupied && bed.patientName != null) {
          String pName = bed.patientName!.toLowerCase();
          String searchName = patientName.toLowerCase();

          if (pName == searchName) {
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
