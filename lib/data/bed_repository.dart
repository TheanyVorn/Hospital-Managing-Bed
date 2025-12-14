import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';
import 'file_storage.dart';

/// Repository for managing bed data (with file persistence)
class BedRepository {
  late BedManager _bedManager;

  /// Initialize with saved data or sample data if first run
  Future<void> initialize() async {
    if (FileStorage.hasExistingData()) {
      // Load from file if data exists
      _bedManager = await FileStorage.loadBedData();
    } else {
      // Initialize with sample data on first run
      _bedManager = BedManager();
      _initializeSampleData();
      // Save sample data to file
      await FileStorage.saveBedData(_bedManager);
    }
  }

  /// Initialize with sample data for demonstration
  void _initializeSampleData() {
    // Add General Ward rooms
    _bedManager.addRoom(
      Room(
        roomNumber: '101',
        roomType: 'General',
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
        ],
      ),
    );

    // Add ICU rooms
    _bedManager.addRoom(
      Room(
        roomNumber: '102',
        roomType: 'ICU',
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
        ],
      ),
    );

    // Add Emergency room
    _bedManager.addRoom(
      Room(
        roomNumber: '103',
        roomType: 'Emergency',
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
        ],
      ),
    );
  }

  BedManager getBedManager() => _bedManager;

  /// Save current state to file
  Future<void> saveData() async {
    await FileStorage.saveBedData(_bedManager);
  }
}
