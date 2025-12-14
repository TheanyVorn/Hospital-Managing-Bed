import 'bed.dart';

class Room {
  final String roomNumber;
  final String roomType; // e.g., General, ICU, Emergency
  final List<Bed> beds;

  Room({required this.roomNumber, required this.roomType, required this.beds});

  int getAvailableBedsCount() {
    return beds.where((bed) => !bed.isOccupied).length;
  }

  int getOccupiedBedsCount() {
    return beds.where((bed) => bed.isOccupied).length;
  }

  int getTotalBedsCount() {
    return beds.length;
  }

  List<Bed> getAvailableBeds() {
    return beds.where((bed) => !bed.isOccupied).toList();
  }

  List<Bed> getOccupiedBeds() {
    return beds.where((bed) => bed.isOccupied).toList();
  }

  Bed? findBed(String bedNumber) {
    try {
      return beds.firstWhere((bed) => bed.bedNumber == bedNumber);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Room $roomNumber ($roomType): ${getAvailableBedsCount()}/${getTotalBedsCount()} beds available';
  }
}
