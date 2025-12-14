import 'bed.dart';

/// Represents a hospital room containing multiple beds
class Room {
  final String roomNumber;
  final String roomType; // e.g., General, ICU, Emergency
  final List<Bed> beds;

  Room({required this.roomNumber, required this.roomType, required this.beds});

  /// Gets the count of available beds in the room
  int getAvailableBedsCount() {
    return beds.where((bed) => !bed.isOccupied).length;
  }

  /// Gets the count of occupied beds in the room
  int getOccupiedBedsCount() {
    return beds.where((bed) => bed.isOccupied).length;
  }

  /// Gets the total number of beds
  int getTotalBedsCount() {
    return beds.length;
  }

  /// Gets a list of available beds
  List<Bed> getAvailableBeds() {
    return beds.where((bed) => !bed.isOccupied).toList();
  }

  /// Gets a list of occupied beds
  List<Bed> getOccupiedBeds() {
    return beds.where((bed) => bed.isOccupied).toList();
  }

  /// Finds a bed by bed number
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
