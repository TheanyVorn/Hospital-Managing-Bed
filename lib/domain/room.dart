import 'bed.dart';

// represents a hospital room with multiple beds
class Room {
  final String roomNumber;
  final String roomType; // like General, ICU, Emergency
  final List<Bed> beds;

  // constructor to create a room
  Room({required this.roomNumber, required this.roomType, required this.beds});

  // count how many beds are available
  int getAvailableBedsCount() {
    int count = 0;
    for (var bed in beds) {
      if (!bed.isOccupied) {
        count++;
      }
    }
    return count;
  }

  // count how many beds is occupied
  int getOccupiedBedsCount() {
    int count = 0;
    for (var bed in beds) {
      if (bed.isOccupied) {
        count++;
      }
    }
    return count;
  }

  // get total number of beds in the room
  int getTotalBedsCount() {
    return beds.length;
  }

  // get list of beds that is available
  List<Bed> getAvailableBeds() {
    List<Bed> available = [];
    for (var bed in beds) {
      if (!bed.isOccupied) {
        available.add(bed);
      }
    }
    return available;
  }

  // get list of beds that is occupied
  List<Bed> getOccupiedBeds() {
    List<Bed> occupied = [];
    for (var bed in beds) {
      if (bed.isOccupied) {
        occupied.add(bed);
      }
    }
    return occupied;
  }

  // find a bed by bed number
  Bed? findBed(String bedNumber) {
    for (var bed in beds) {
      if (bed.bedNumber == bedNumber) {
        return bed;
      }
    }
    return null;
  }

  // display room information
  @override
  String toString() {
    return 'Room $roomNumber ($roomType): ${getAvailableBedsCount()}/${getTotalBedsCount()} beds available';
  }
}
