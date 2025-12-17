import 'package:flutter_test/flutter_test.dart';
import 'package:test/domain/bed.dart';
import 'package:test/domain/bed_manager.dart';
import 'package:test/domain/room.dart';
import 'package:test/domain/room_type.dart';

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

    test('Cannot discharge empty bed', () {
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

    test('Cannot assign to non-exist room or bed', () {
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

    test('Find multiple patients with same exact name', () {
      bedManager.assignBedToPatient('101', 'A', 'Theany');
      bedManager.assignBedToPatient('101', 'B', 'Theany');

      final results = bedManager.findPatient('Theany');
      expect(results.length, 2);
    });
  });
}
