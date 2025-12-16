import 'bed.dart';
import 'room_type.dart';

class Room {
  final String roomNumber;
  final RoomType roomType;
  final List<Bed> beds;

  Room({required this.roomNumber, required this.roomType, required this.beds});

  int getAvailableBedsCount() {
    int count = 0;
    for (var bed in beds) {
      if (!bed.isOccupied) {
        count++;
      }
    }
    return count;
  }

  int getOccupiedBedsCount() {
    int count = 0;
    for (var bed in beds) {
      if (bed.isOccupied) {
        count++;
      }
    }
    return count;
  }

  int getTotalBedsCount() {
    return beds.length;
  }

  List<Bed> getAvailableBeds() {
    List<Bed> available = [];
    for (var bed in beds) {
      if (!bed.isOccupied) {
        available.add(bed);
      }
    }
    return available;
  }

  List<Bed> getOccupiedBeds() {
    List<Bed> occupied = [];
    for (var bed in beds) {
      if (bed.isOccupied) {
        occupied.add(bed);
      }
    }
    return occupied;
  }

  Bed? findBed(String bedNumber) {
    for (var bed in beds) {
      if (bed.bedNumber == bedNumber) {
        return bed;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'Room $roomNumber ($roomType): ${getAvailableBedsCount()}/${getTotalBedsCount()} beds available';
  }
}
