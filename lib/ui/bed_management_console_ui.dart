import 'dart:io';
import '../domain/bed_manager.dart';
import '../data/bed_repository.dart';

// console-based UI for hospital bed management system
class BedManagementConsoleUI {
  final BedRepository _repository;
  late BedManager _bedManager;

  BedManagementConsoleUI() : _repository = BedRepository();

  // initialize the UI (load data from file)
  Future<void> initialize() async {
    await _repository.initialize();
    _bedManager = _repository.getBedManager();
  }

  // main menu loop
  Future<void> run() async {
    await initialize();
    bool isRunning = true;

    while (isRunning) {
      _displayMainMenu();
      final choice = stdin.readLineSync()?.trim() ?? '';

      switch (choice) {
        case '1':
          _viewAllRoomsAndBeds();
          break;
        case '2':
          _assignBedToPatient();
          await _repository.saveData();
          break;
        case '3':
          _releaseBed();
          await _repository.saveData();
          break;
        case '4':
          _searchPatient();
          break;
        case '5':
          await _repository.saveData();
          isRunning = false;
          print('\nData saved successfully.');
          print('Thank you for using Hospital Bed Management System!');
          break;
        default:
          print('\nInvalid choice. Please try again.\n');
      }
    }
  }

  // display main menu
  void _displayMainMenu() {
    print('\nHOSPITAL BED MANAGEMENT SYSTEM');
    print('1. View all Rooms and beds');
    print('2. Assign bed to patient');
    print('3. Discharge patient');
    print('4. Search patient');
    print('5. Exit');
    stdout.write('\nSelect option: ');
  }

  // option 1: View all rooms and beds
  void _viewAllRoomsAndBeds() {
    print('\nALL ROOMS AND BEDS');

    if (_bedManager.rooms.isEmpty) {
      print('No rooms available.');
      return;
    }

    for (var room in _bedManager.rooms) {
      print('\nRoom ${room.roomNumber} (${room.roomType})');
      print(
        'Available: ${room.getAvailableBedsCount()}/${room.getTotalBedsCount()}',
      );

      for (var bed in room.beds) {
        if (bed.isOccupied) {
          final dateStr =
              bed.assignedDate?.toString().substring(0, 19) ?? 'N/A';
          print(
            'Bed ${bed.bedNumber}: [OCCUPIED] Patient: ${bed.patientName} | Assigned: $dateStr',
          );
        } else {
          print('Bed ${bed.bedNumber}: [AVAILABLE]');
        }
      }
    }
    print('\n');
  }

  // option 2: Assign bed to patient
  void _assignBedToPatient() {
    print('\nASSIGN BED TO PATIENT');

    // get room number
    stdout.write('Enter room number: ');
    final roomNumber = stdin.readLineSync()?.trim() ?? '';

    if (roomNumber.isEmpty) {
      print('Room number cannot be empty.');
      return;
    }

    final room = _bedManager.findRoom(roomNumber);
    if (room == null) {
      print('Room $roomNumber not found.');
      return;
    }

    // show available beds
    final availableBeds = room.getAvailableBeds();
    if (availableBeds.isEmpty) {
      print('NO available beds in room $roomNumber.');
      return;
    }

    print('\nAvailable beds:');
    for (var bed in availableBeds) {
      print('  - ${bed.bedNumber}');
    }

    // get bed number
    stdout.write('\nEnter bed availability: ');
    final bedNumber = stdin.readLineSync()?.trim() ?? '';

    if (bedNumber.isEmpty) {
      print('Bed number cannot be empty.');
      return;
    }

    final bed = room.findBed(bedNumber);
    if (bed == null) {
      print('Bed $bedNumber not found in room $roomNumber.');
      return;
    }

    if (bed.isOccupied) {
      print('Bed $bedNumber is already occupied.');
      return;
    }

    // get patient name
    stdout.write('Enter patient name: ');
    final patientName = stdin.readLineSync()?.trim() ?? '';

    if (patientName.isEmpty) {
      print('Patient name cannot be empty.');
      return;
    }

    try {
      _bedManager.assignBedToPatient(roomNumber, bedNumber, patientName);
      print(
        'Successfully assigned bed $roomNumber-$bedNumber to $patientName.',
      );
    } on Exception catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  // option 3: discharge bed
  void _releaseBed() {
    print('\nDISCHARGE PATIENT');

    // get room number
    stdout.write('Enter room number: ');
    final roomNumber = stdin.readLineSync()?.trim() ?? '';

    if (roomNumber.isEmpty) {
      print('Room number cannot be empty.');
      return;
    }

    final room = _bedManager.findRoom(roomNumber);
    if (room == null) {
      print('Room $roomNumber not found.');
      return;
    }

    // show occupied beds
    final occupiedBeds = room.getOccupiedBeds();
    if (occupiedBeds.isEmpty) {
      print('NO occupied beds in room $roomNumber.');
      return;
    }

    print('\nOccupied beds:');
    for (var bed in occupiedBeds) {
      print('   - ${bed.bedNumber}: ${bed.patientName}');
    }

    // get bed number
    stdout.write('\nEnter bed to release: ');
    final bedNumber = stdin.readLineSync()?.trim() ?? '';

    if (bedNumber.isEmpty) {
      print('Bed number cannot be empty.');
      return;
    }

    final bed = room.findBed(bedNumber);
    if (bed == null) {
      print('Bed $bedNumber not found in room $roomNumber.');
      return;
    }

    if (!bed.isOccupied) {
      print('Bed $bedNumber is empty.');
      return;
    }

    // confirmation
    stdout.write('Are you sure? (y/n): ');
    final confirmation = stdin.readLineSync()?.trim().toLowerCase() ?? '';

    if (confirmation != 'y' && confirmation != 'yes') {
      print('Discharging cancelled.');
      return;
    }

    try {
      _bedManager.releaseBed(roomNumber, bedNumber);
      print('Patient discharged successfully.');
    } on Exception catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  /// Option 4: Search patient
  void _searchPatient() {
    print('\nSEARCH PATIENT');

    stdout.write('Enter patient name: ');
    final patientName = stdin.readLineSync()?.trim() ?? '';

    if (patientName.isEmpty) {
      print('Patient name cannot be empty.');
      return;
    }

    final results = _bedManager.findPatient(patientName);

    if (results.isEmpty) {
      print('NO patients found matching "$patientName".');
      return;
    }

    print('\nFound ${results.length} patient(s):');
    for (var result in results) {
      print('\n ${result['patientName']}');
      print('Room: ${result['roomNumber']}, Bed: ${result['bedNumber']}');
      print('Assigned: ${result['assignedDate']?.substring(0, 19)}');
    }
    print('\n');
  }
}
