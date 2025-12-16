import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';
import '../domain/room_type.dart';
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
        roomType: RoomType.general,
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
        ],
      ),
    );

    _bedManager.addRoom(
      Room(
        roomNumber: '102',
        roomType: RoomType.icu,
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
        ],
      ),
    );

    _bedManager.addRoom(
      Room(
        roomNumber: '103',
        roomType: RoomType.emergency,
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
