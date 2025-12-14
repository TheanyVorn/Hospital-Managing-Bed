import 'room.dart';

class BedManager {
  final List<Room> rooms;

  BedManager({List<Room>? rooms}) : rooms = rooms ?? [];

  void addRoom(Room room) {
    if (rooms.any((r) => r.roomNumber == room.roomNumber)) {
      throw Exception('Room ${room.roomNumber} already exists');
    }
    rooms.add(room);
  }

  Room? findRoom(String roomNumber) {
    try {
      return rooms.firstWhere((room) => room.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  void assignBedToPatient(
    String roomNumber,
    String bedNumber,
    String patientName,
  ) {
    final room = findRoom(roomNumber);
    if (room == null) {
      throw Exception('Room $roomNumber not found');
    }

    final bed = room.findBed(bedNumber);
    if (bed == null) {
      throw Exception('Bed $bedNumber not found in room $roomNumber');
    }

    bed.assignPatient(patientName);
  }

  void releaseBed(String roomNumber, String bedNumber) {
    final room = findRoom(roomNumber);
    if (room == null) {
      throw Exception('Room $roomNumber not found');
    }

    final bed = room.findBed(bedNumber);
    if (bed == null) {
      throw Exception('Bed $bedNumber not found in room $roomNumber');
    }

    bed.releaseBed();
  }
  
  int getTotalAvailableBeds() {
    return rooms.fold(0, (sum, room) => sum + room.getAvailableBedsCount());
  }

  int getTotalOccupiedBeds() {
    return rooms.fold(0, (sum, room) => sum + room.getOccupiedBedsCount());
  }

  int getTotalBeds() {
    return rooms.fold(0, (sum, room) => sum + room.getTotalBedsCount());
  }

  List<Room> getRoomsByType(String roomType) {
    return rooms.where((room) => room.roomType == roomType).toList();
  }

  List<Map<String, String>> findPatient(String patientName) {
    List<Map<String, String>> results = [];

    for (var room in rooms) {
      for (var bed in room.beds) {
        if (bed.isOccupied &&
            bed.patientName?.toLowerCase().contains(
                  patientName.toLowerCase(),
                ) ==
                true) {
          results.add({
            'roomNumber': room.roomNumber,
            'bedNumber': bed.bedNumber,
            'patientName': bed.patientName!,
            'assignedDate': bed.assignedDate.toString(),
          });
        }
      }
    }

    return results;
  }
}
