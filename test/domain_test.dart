import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/bed.dart';
import '../lib/domain/room.dart';
import '../lib/domain/bed_manager.dart';

void main() {
  group('Bed Tests', () {
    test('Bed should be created with initial state as available', () {
      final bed = Bed(bedNumber: 'A');

      expect(bed.bedNumber, 'A');
      expect(bed.isOccupied, false);
      expect(bed.patientName, null);
      expect(bed.assignedDate, null);
    });

    test('Bed should assign patient correctly', () {
      final bed = Bed(bedNumber: 'A');

      bed.assignPatient('John Doe');

      expect(bed.isOccupied, true);
      expect(bed.patientName, 'John Doe');
      expect(bed.assignedDate, isNotNull);
    });

    test('Bed should throw exception when assigning to occupied bed', () {
      final bed = Bed(bedNumber: 'A');
      bed.assignPatient('John Doe');

      expect(() => bed.assignPatient('Jane Smith'), throwsException);
    });

    test('Bed should release correctly', () {
      final bed = Bed(bedNumber: 'A');
      bed.assignPatient('John Doe');

      bed.releaseBed();

      expect(bed.isOccupied, false);
      expect(bed.patientName, null);
      expect(bed.assignedDate, null);
    });

    test('Bed should throw exception when releasing vacant bed', () {
      final bed = Bed(bedNumber: 'A');

      expect(() => bed.releaseBed(), throwsException);
    });

    test('Bed should return correct status', () {
      final bed = Bed(bedNumber: 'A');

      expect(bed.isOccupied, false);

      bed.assignPatient('John Doe');
      expect(bed.isOccupied, true);
    });
  });

  group('Room Tests', () {
    late Room room;

    setUp(() {
      room = Room(
        roomNumber: '101',
        roomType: 'General',
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
          Bed(bedNumber: 'C'),
        ],
      );
    });

    test('Room should be created with correct properties', () {
      expect(room.roomNumber, '101');
      expect(room.roomType, 'General');
      expect(room.getTotalBedsCount(), 3);
    });

    test('Room should count available beds correctly', () {
      expect(room.getAvailableBedsCount(), 3);

      room.beds[0].assignPatient('Patient 1');
      expect(room.getAvailableBedsCount(), 2);

      room.beds[1].assignPatient('Patient 2');
      expect(room.getAvailableBedsCount(), 1);
    });

    test('Room should count occupied beds correctly', () {
      expect(room.getOccupiedBedsCount(), 0);

      room.beds[0].assignPatient('Patient 1');
      expect(room.getOccupiedBedsCount(), 1);

      room.beds[1].assignPatient('Patient 2');
      expect(room.getOccupiedBedsCount(), 2);
    });

    test('Room should check availability correctly', () {
      expect(room.getAvailableBedsCount(), 3);

      room.beds.forEach((bed) => bed.assignPatient('Patient'));
      expect(room.getAvailableBedsCount(), 0);
    });
    test('Room should find bed by bed number', () {
      final bed = room.findBed('B');

      expect(bed, isNotNull);
      expect(bed?.bedNumber, 'B');
    });

    test('Room should return null for non-existent bed', () {
      final bed = room.findBed('Z');

      expect(bed, null);
    });

    test('Room should get list of available beds', () {
      room.beds[0].assignPatient('Patient 1');

      final availableBeds = room.getAvailableBeds();

      expect(availableBeds.length, 2);
      expect(availableBeds.any((bed) => bed.bedNumber == 'A'), false);
    });

    test('Room should get list of occupied beds', () {
      room.beds[0].assignPatient('Patient 1');
      room.beds[1].assignPatient('Patient 2');

      final occupiedBeds = room.getOccupiedBeds();

      expect(occupiedBeds.length, 2);
      expect(occupiedBeds.every((bed) => bed.isOccupied), true);
    });
  });

  group('BedManager Tests', () {
    late BedManager bedManager;
    late Room room1;
    late Room room2;

    setUp(() {
      room1 = Room(
        roomNumber: '101',
        roomType: 'General',
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
        ],
      );

      room2 = Room(
        roomNumber: '201',
        roomType: 'ICU',
        beds: [
          Bed(bedNumber: 'A'),
          Bed(bedNumber: 'B'),
        ],
      );

      bedManager = BedManager(rooms: [room1, room2]);
    });

    test('BedManager should add room correctly', () {
      final newRoom = Room(
        roomNumber: '301',
        roomType: 'Emergency',
        beds: [Bed(bedNumber: 'A')],
      );

      bedManager.addRoom(newRoom);

      expect(bedManager.rooms.length, 3);
      expect(bedManager.findRoom('301'), isNotNull);
    });

    test('BedManager should throw exception when adding duplicate room', () {
      final duplicateRoom = Room(
        roomNumber: '101',
        roomType: 'General',
        beds: [Bed(bedNumber: 'A')],
      );

      expect(() => bedManager.addRoom(duplicateRoom), throwsException);
    });

    test('BedManager should find room correctly', () {
      final room = bedManager.findRoom('101');

      expect(room, isNotNull);
      expect(room?.roomNumber, '101');
    });

    test('BedManager should assign bed to patient correctly', () {
      bedManager.assignBedToPatient('101', 'A', 'John Doe');

      final room = bedManager.findRoom('101');
      final bed = room?.findBed('A');

      expect(bed?.isOccupied, true);
      expect(bed?.patientName, 'John Doe');
    });

    test('BedManager should throw exception for non-existent room', () {
      expect(
        () => bedManager.assignBedToPatient('999', 'A', 'John Doe'),
        throwsException,
      );
    });

    test('BedManager should throw exception for non-existent bed', () {
      expect(
        () => bedManager.assignBedToPatient('101', 'Z', 'John Doe'),
        throwsException,
      );
    });

    test('BedManager should release bed correctly', () {
      bedManager.assignBedToPatient('101', 'A', 'John Doe');
      bedManager.releaseBed('101', 'A');

      final room = bedManager.findRoom('101');
      final bed = room?.findBed('A');

      expect(bed?.isOccupied, false);
      expect(bed?.patientName, null);
    });

    test('BedManager should count total available beds correctly', () {
      expect(bedManager.getTotalAvailableBeds(), 4);

      bedManager.assignBedToPatient('101', 'A', 'Patient 1');
      expect(bedManager.getTotalAvailableBeds(), 3);

      bedManager.assignBedToPatient('201', 'B', 'Patient 2');
      expect(bedManager.getTotalAvailableBeds(), 2);
    });

    test('BedManager should count total occupied beds correctly', () {
      expect(bedManager.getTotalOccupiedBeds(), 0);

      bedManager.assignBedToPatient('101', 'A', 'Patient 1');
      expect(bedManager.getTotalOccupiedBeds(), 1);
    });

    test('BedManager should get rooms by type', () {
      final generalRooms = bedManager.getRoomsByType('General');

      expect(generalRooms.length, 1);
      expect(generalRooms[0].roomNumber, '101');
    });

    test('BedManager should find patient correctly', () {
      bedManager.assignBedToPatient('101', 'A', 'John Doe');
      bedManager.assignBedToPatient('201', 'B', 'Jane Smith');

      final results = bedManager.findPatient('John');

      expect(results.length, 1);
      expect(results[0]['patientName'], 'John Doe');
      expect(results[0]['roomNumber'], '101');
      expect(results[0]['bedNumber'], 'A');
    });

    test(
      'BedManager should find multiple patients with partial name match',
      () {
        bedManager.assignBedToPatient('101', 'A', 'John Doe');
        bedManager.assignBedToPatient('101', 'B', 'Johnny Smith');
        bedManager.assignBedToPatient('201', 'A', 'Jane Doe');

        final results = bedManager.findPatient('john');

        expect(results.length, 2);
      },
    );
  });
}
