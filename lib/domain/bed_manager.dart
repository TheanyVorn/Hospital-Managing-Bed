import 'room.dart';

/// Main service class for managing hospital beds and rooms
class BedManager {
  final List<Room> rooms;

  BedManager({List<Room>? rooms}) : rooms = rooms ?? [];

  /// Adds a new room to the hospital
  void addRoom(Room room) {
    // Check if room already exists
    if (rooms.any((r) => r.roomNumber == room.roomNumber)) {
      throw Exception('Room ${room.roomNumber} already exists');
    }
    rooms.add(room);
  }

  /// Finds a room by room number
  Room? findRoom(String roomNumber) {
    try {
      return rooms.firstWhere((room) => room.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  /// Assigns a patient to a specific bed in a specific room
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

  /// Releases a bed in a specific room
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

  /// Gets total number of available beds across all rooms
  int getTotalAvailableBeds() {
    return rooms.fold(0, (sum, room) => sum + room.getAvailableBedsCount());
  }

  /// Gets total number of occupied beds across all rooms
  int getTotalOccupiedBeds() {
    return rooms.fold(0, (sum, room) => sum + room.getOccupiedBedsCount());
  }

  /// Gets total number of beds across all rooms
  int getTotalBeds() {
    return rooms.fold(0, (sum, room) => sum + room.getTotalBedsCount());
  }

  /// Gets all rooms by type
  List<Room> getRoomsByType(String roomType) {
    return rooms.where((room) => room.roomType == roomType).toList();
  }

  /// Searches for a patient across all rooms and beds
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
