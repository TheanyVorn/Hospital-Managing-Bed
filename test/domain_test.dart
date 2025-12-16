import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/bed.dart';
import '../lib/domain/room.dart';
import '../lib/domain/room_type.dart';
import '../lib/domain/bed_manager.dart';

void main() {
  group('Bed Tests', () {
    test('Create bed with initial state', () {
      final bed = Bed(bedNumber: 'A');
      expect(bed.bedNumber, 'A');
      expect(bed.isOccupied, false);
      expect(bed.patientName, null);
    });

    test('Assign patient to bed', () {
      final bed = Bed(bedNumber: 'A');
      bed.assignPatient('Theany');
      expect(bed.isOccupied, true);
      expect(bed.patientName, 'Theany');
      expect(bed.assignedDate, isNotNull);
    });

    test('Cannot assign to occupied bed', () {
      final bed = Bed(bedNumber: 'A');
      bed.assignPatient('Theany');
      expect(() => bed.assignPatient('Jane'), throwsException);
    });

    test('Discharge Patient', () {
      final bed = Bed(bedNumber: 'A');
      bed.assignPatient('Theany');
      bed.dischargePatient();
      expect(bed.isOccupied, false);
      expect(bed.patientName, null);
    });

    test('Cannot discharge vacant bed', () {
      final bed = Bed(bedNumber: 'A');
      expect(() => bed.dischargePatient(), throwsException);
    });
  });

  group('Room Tests', () {
    late Room room;

    setUp(() {
      room = Room(
        roomNumber: '101',
        roomType: RoomType.general,
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
          Bed(bedNumber: 'C'),
        ],
      );
    });

    test('Room creation', () {
      expect(room.roomNumber, '101');
      expect(room.roomType, RoomType.general);
      expect(room.getTotalBedsCount(), 3);
    });

    test('Count available and occupied beds', () {
      expect(room.getAvailableBedsCount(), 3);
      expect(room.getOccupiedBedsCount(), 0);

      room.beds[0].assignPatient('Patient 1');
      expect(room.getAvailableBedsCount(), 2);
      expect(room.getOccupiedBedsCount(), 1);
    });

    test('Find bed by number', () {
      expect(room.findBed('B'), isNotNull);
      expect(room.findBed('Z'), null);
    });

    test('Get available and occupied beds lists', () {
      room.beds[0].assignPatient('Patient 1');
      final available = room.getAvailableBeds();
      final occupied = room.getOccupiedBeds();
      expect(available.length, 2);
      expect(occupied.length, 1);
    });
  });

  group('BedManager Tests', () {
    late BedManager bedManager;

    setUp(() {
      bedManager = BedManager(
        rooms: [
          Room(
            roomNumber: '101',
            roomType: RoomType.general,
            beds: [
              Bed(bedNumber: 'A'),
              Bed(bedNumber: 'B'),
            ],
          ),
          Room(
            roomNumber: '201',
            roomType: RoomType.icu,
            beds: [
              Bed(bedNumber: 'A'),
              Bed(bedNumber: 'B'),
            ],
          ),
        ],
      );
    });

    test('Add room', () {
      bedManager.addRoom(
        Room(
          roomNumber: '301',
          roomType: RoomType.emergency,
          beds: [Bed(bedNumber: 'A')],
        ),
      );
      expect(bedManager.rooms.length, 3);
      expect(bedManager.findRoom('301'), isNotNull);
    });

    test('Cannot add duplicate room', () {
      expect(
        () => bedManager.addRoom(
          Room(
            roomNumber: '101',
            roomType: RoomType.general,
            beds: [Bed(bedNumber: 'A')],
          ),
        ),
        throwsException,
      );
    });

    test('Find room', () {
      expect(bedManager.findRoom('101'), isNotNull);
      expect(bedManager.findRoom('999'), null);
    });

    test('Assign bed to patient', () {
      bedManager.assignBedToPatient('101', 'A', 'Theany');
      final bed = bedManager.findRoom('101')?.findBed('A');
      expect(bed?.isOccupied, true);
      expect(bed?.patientName, 'Theany');
    });

    test('Cannot assign to non-existent room or bed', () {
      expect(
        () => bedManager.assignBedToPatient('999', 'A', 'Theany'),
        throwsException,
      );
      expect(
        () => bedManager.assignBedToPatient('101', 'Z', 'Thea'),
        throwsException,
      );
    });

    test('Discharge Patient', () {
      bedManager.assignBedToPatient('101', 'A', 'Theany');
      bedManager.dischargePatient('101', 'A');
      final bed = bedManager.findRoom('101')?.findBed('A');
      expect(bed?.isOccupied, false);
    });

    test('Count total beds', () {
      expect(bedManager.getTotalAvailableBeds(), 4);
      expect(bedManager.getTotalOccupiedBeds(), 0);

      bedManager.assignBedToPatient('101', 'A', 'Patient 1');
      expect(bedManager.getTotalAvailableBeds(), 3);
      expect(bedManager.getTotalOccupiedBeds(), 1);
    });

    test('Get rooms by type', () {
      final general = bedManager.getRoomsByType(RoomType.general);
      expect(general.length, 1);
      expect(general[0].roomNumber, '101');
    });

    test('Find patient', () {
      bedManager.assignBedToPatient('101', 'A', 'Theany');
      bedManager.assignBedToPatient('201', 'B', 'Jane');

      final results = bedManager.findPatient('Theany');
      expect(results.length, 1);
      expect(results[0]['patientName'], 'Theany');
    });

    test('Find patient with partial name match', () {
      bedManager.assignBedToPatient('101', 'A', 'Theany');
      bedManager.assignBedToPatient('101', 'B', 'Theany');

      final results = bedManager.findPatient('Theany');
      expect(results.length, 2);
    });
  });
}
