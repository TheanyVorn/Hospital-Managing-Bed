import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';
import 'file_storage.dart';

class BedRepository {
  late BedManager _bedManager;

  Future<void> initialize() async {
    if (FileStorage.hasExistingData()) {
      _bedManager = await FileStorage.loadBedData();
    } else {
      _bedManager = BedManager();
      _initializeSampleData();
      await FileStorage.saveBedData(_bedManager);
    }
  }

  void _initializeSampleData() {
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

  Future<void> saveData() async {
    await FileStorage.saveBedData(_bedManager);
  }
}
