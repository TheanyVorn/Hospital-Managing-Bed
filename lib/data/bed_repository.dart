import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';
import '../domain/room_type.dart';
import 'file_storage.dart';

// Repository: handles data access and persistence
class BedRepository {
  late BedManager _bedManager;

  // Initialize: load data from file or create sample data
  Future<void> initialize() async {
    if (FileStorage.hasExistingData()) {
      // If file exists, load data from file
      _bedManager = await FileStorage.loadBedData();
    } else {
      // If file does not exist, create new manager and sample data
      _bedManager = BedManager();
      _initializeSampleData();
      await FileStorage.saveBedData(_bedManager);
    }
  }

  // Create sample data: 3 rooms with 2 beds each
  void _initializeSampleData() {
    List<Room> rooms = [];

    rooms.add(Room(
      roomNumber: '101',
      roomType: RoomType.general,
      beds: [
        Bed(bedNumber: 'A'),
        Bed(bedNumber: 'B'),
      ],
    ));

    rooms.add(Room(
      roomNumber: '102',
      roomType: RoomType.icu,
      beds: [
        Bed(bedNumber: 'A'),
        Bed(bedNumber: 'B'),
      ],
    ));

    rooms.add(Room(
      roomNumber: '103',
      roomType: RoomType.emergency,
      beds: [
        Bed(bedNumber: 'A'),
        Bed(bedNumber: 'B'),
      ],
    ));

    _bedManager = BedManager(rooms: rooms);
  }

  // Get bed manager instance
  BedManager getBedManager() => _bedManager;

  // Save current data to file
  Future<bool> saveData() async {
    return await FileStorage.saveBedData(_bedManager);
  }
}
