import 'dart:io';
import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';
import '../data/bed_repository.dart';

class BedManagementConsoleUI {
  final BedRepository _repository;
  BedManager _bedManager = BedManager();

  BedManagementConsoleUI() : _repository = BedRepository();

  Future<void> initialize() async {
    await _repository.initialize();
    _bedManager = _repository.getBedManager();
  }

  Future<void> run() async {
    await initialize();
    bool isRunning = true;

    while (isRunning) {
      _displayMainMenu();

      String? userInput = stdin.readLineSync();
      String choice = '';
      if (userInput != null) {
        choice = userInput.trim();
      }

      if (choice == '1') {
        _viewAllRoomsAndBeds();
      } else if (choice == '2') {
        _assignBedToPatient();
        bool saved = await _repository.saveData();
        if (saved) {
          print('Data saved successfully.');
        } else {
          print('Error: Failed to save data.');
        }
      } else if (choice == '3') {
        _releaseBed();
        bool saved = await _repository.saveData();
        if (saved) {
          print('Data saved successfully.');
        } else {
          print('Error: Failed to save data.');
        }
      } else if (choice == '4') {
        _searchPatient();
      } else if (choice == '5') {
        bool saved = await _repository.saveData();
        isRunning = false;
        if (saved) {
          print('\nData saved successfully.');
        } else {
          print('\nError: Failed to save data.');
        }
        print('Thank you for using Hospital Bed Management System!');
      } else {
        print('\nInvalid choice. Please try again.\n');
      }
    }
  }

  void _displayMainMenu() {
    print('\nHOSPITAL BED MANAGEMENT SYSTEM');
    print('1. View all Rooms and beds');
    print('2. Assign bed to patient');
    print('3. Discharge patient');
    print('4. Search patient');
    print('5. Exit');
    stdout.write('\nSelect option: ');
  }

  void _viewAllRoomsAndBeds() {
    print('\nVIEW ALL ROOMS AND BEDS');

    if (_bedManager.rooms.isEmpty) {
      print('No rooms available.');
      return;
    }

    for (var room in _bedManager.rooms) {
      print('\nRoom ${room.roomNumber} (${room.roomType})');

      int availableCount = room.getAvailableBedsCount();
      int totalCount = room.getTotalBedsCount();
      print('Available: $availableCount/$totalCount');

      for (var bed in room.beds) {
        if (bed.isOccupied) {
          String dateStr = 'N/A';
          if (bed.assignedDate != null) {
            dateStr = bed.assignedDate.toString().substring(0, 19);
          }
          print(
            '  Bed ${bed.bedNumber}: [OCCUPIED] ${bed.patientName} (Assigned: $dateStr)',
          );
        } else {
          print('  Bed ${bed.bedNumber}: [AVAILABLE]');
        }
      }
    }
    print('\n');
  }

  void _assignBedToPatient() {
    print('\nASSIGN BED TO PATIENT');

    stdout.write('\nEnter room number: ');
    String? userInput = stdin.readLineSync();
    String roomNumber = '';
    if (userInput != null) {
      roomNumber = userInput.trim();
    }

    if (roomNumber.isEmpty) {
      print('Error: Room number cannot be empty.');
      return;
    }

    Room? room = _bedManager.findRoom(roomNumber);
    if (room == null) {
      print('Error: Room $roomNumber not found.');
      return;
    }

    List<Bed> availableBeds = room.getAvailableBeds();
    if (availableBeds.isEmpty) {
      print('Error: No available beds in room $roomNumber.');
      return;
    }

    print('\nAvailable beds in this room:');
    for (var bed in availableBeds) {
      print('  - Bed ${bed.bedNumber}');
    }

    stdout.write('\nEnter bed number: ');
    userInput = stdin.readLineSync();
    String bedNumber = '';
    if (userInput != null) {
      bedNumber = userInput.trim();
    }

    if (bedNumber.isEmpty) {
      print('Error: Bed number cannot be empty.');
      return;
    }

    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      print('Error: Bed $bedNumber not found in room $roomNumber.');
      return;
    }

    if (bed.isOccupied) {
      print('Error: Bed $bedNumber is already occupied.');
      return;
    }

    stdout.write('Enter patient name: ');
    userInput = stdin.readLineSync();
    String patientName = '';
    if (userInput != null) {
      patientName = userInput.trim();
    }

    if (patientName.isEmpty) {
      print('Error: Patient name cannot be empty.');
      return;
    }

    try {
      _bedManager.assignBedToPatient(roomNumber, bedNumber, patientName);
      print('\nSuccess: Assigned bed $roomNumber-$bedNumber to $patientName.');
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void _releaseBed() {
    print('\nDISCHARGE PATIENT');

    stdout.write('\nEnter room number: ');
    String? userInput = stdin.readLineSync();
    String roomNumber = '';
    if (userInput != null) {
      roomNumber = userInput.trim();
    }

    if (roomNumber.isEmpty) {
      print('Error: Room number cannot be empty.');
      return;
    }

    Room? room = _bedManager.findRoom(roomNumber);
    if (room == null) {
      print('Error: Room $roomNumber not found.');
      return;
    }

    List<Bed> occupiedBeds = room.getOccupiedBeds();
    if (occupiedBeds.isEmpty) {
      print('Error: No occupied beds in room $roomNumber.');
      return;
    }

    print('\nOccupied beds in this room:');
    for (var bed in occupiedBeds) {
      print('  - Bed ${bed.bedNumber}: ${bed.patientName}');
    }

    stdout.write('\nEnter bed number to release: ');
    userInput = stdin.readLineSync();
    String bedNumber = '';
    if (userInput != null) {
      bedNumber = userInput.trim();
    }

    if (bedNumber.isEmpty) {
      print('Error: Bed number cannot be empty.');
      return;
    }

    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      print('Error: Bed $bedNumber not found in room $roomNumber.');
      return;
    }

    if (!bed.isOccupied) {
      print('Error: Bed $bedNumber is empty.');
      return;
    }

    stdout.write('Are you sure you want to discharge this patient? (y/n): ');
    userInput = stdin.readLineSync();
    String confirmation = '';
    if (userInput != null) {
      confirmation = userInput.trim().toLowerCase();
    }

    if (confirmation != 'y' && confirmation != 'yes') {
      print('Discharge cancelled.');
      return;
    }

    try {
      _bedManager.releaseBed(roomNumber, bedNumber);
      print(
        'Success: Patient discharged successfully from bed $roomNumber-$bedNumber.',
      );
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void _searchPatient() {
    print('\nSEARCH PATIENT');

    stdout.write('\nEnter patient name to search: ');
    String? userInput = stdin.readLineSync();
    String patientName = '';
    if (userInput != null) {
      patientName = userInput.trim();
    }

    if (patientName.isEmpty) {
      print('Error: Patient name cannot be empty.');
      return;
    }

    List<Map<String, String>> results = _bedManager.findPatient(patientName);

    if (results.isEmpty) {
      print('\nNo patients foun "$patientName".');
      return;
    }

    print('\nFound ${results.length} patient(s):');

    for (var result in results) {
      String? patName = result['patientName'];
      String? roomNum = result['roomNumber'];
      String? bedNum = result['bedNumber'];
      String? assignedDate = result['assignedDate'];

      print('\nPatient: $patName');
      print('Room: $roomNum, Bed: $bedNum');

      if (assignedDate != null) {
        String dateStr = assignedDate.substring(0, 19);
        print('Assigned: $dateStr');
      }
    }
    print('\n');
  }
}
