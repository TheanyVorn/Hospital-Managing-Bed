import 'dart:io';
import '../domain/bed_manager.dart';
import '../domain/room.dart';
import '../domain/bed.dart';
import '../data/bed_repository.dart';

// console-based ui for hospital bed management system
class BedManagementConsoleUI {
  final BedRepository _repository;
  BedManager _bedManager = BedManager();

  BedManagementConsoleUI() : _repository = BedRepository();

  // initialize the ui (load data from file)
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

      // get user choice from keyboard
      String? userInput = stdin.readLineSync();
      String choice = '';
      if (userInput != null) {
        choice = userInput.trim();
      }

      // handle user choice
      if (choice == '1') {
        _viewAllRoomsAndBeds();
      } else if (choice == '2') {
        _assignBedToPatient();
        await _repository.saveData();
      } else if (choice == '3') {
        _releaseBed();
        await _repository.saveData();
      } else if (choice == '4') {
        _searchPatient();
      } else if (choice == '5') {
        await _repository.saveData();
        isRunning = false;
        print('\nData saved successfully.');
        print('Thank you for using Hospital Bed Management System!');
      } else {
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

  // option 1: view all rooms and beds
  void _viewAllRoomsAndBeds() {
    print('\nALL ROOMS AND BEDS');

    // check if there are any rooms
    if (_bedManager.rooms.isEmpty) {
      print('No rooms available.');
      return;
    }

    // show each room
    for (var room in _bedManager.rooms) {
      print('\nRoom ${room.roomNumber} (${room.roomType})');

      int availableCount = room.getAvailableBedsCount();
      int totalCount = room.getTotalBedsCount();
      print('Available: $availableCount/$totalCount');

      // show each bed in the room
      for (var bed in room.beds) {
        if (bed.isOccupied) {
          // bed is occupied
          String dateStr = 'N/A';
          if (bed.assignedDate != null) {
            dateStr = bed.assignedDate.toString().substring(0, 19);
          }
          print(
            '  Bed ${bed.bedNumber}: [OCCUPIED] ${bed.patientName} (Assigned: $dateStr)',
          );
        } else {
          // bed is available
          print('  Bed ${bed.bedNumber}: [AVAILABLE]');
        }
      }
    }
    print('\n');
  }

  // option 2: assign bed to patient
  void _assignBedToPatient() {
    print('\nASSIGN BED TO PATIENT');

    // Get room number from user
    stdout.write('\nEnter room number: ');
    String? userInput = stdin.readLineSync();
    String roomNumber = '';
    if (userInput != null) {
      roomNumber = userInput.trim();
    }

    // check if room number is empty
    if (roomNumber.isEmpty) {
      print('Error: Room number cannot be empty.');
      return;
    }

    // find the room
    Room? room = _bedManager.findRoom(roomNumber);
    if (room == null) {
      print('Error: Room $roomNumber not found.');
      return;
    }

    // show available beds
    List<Bed> availableBeds = room.getAvailableBeds();
    if (availableBeds.isEmpty) {
      print('Error: No available beds in room $roomNumber.');
      return;
    }

    print('\nAvailable beds in this room:');
    for (var bed in availableBeds) {
      print('  - Bed ${bed.bedNumber}');
    }

    // get bed number from user
    stdout.write('\nEnter bed number: ');
    userInput = stdin.readLineSync();
    String bedNumber = '';
    if (userInput != null) {
      bedNumber = userInput.trim();
    }

    // check if bed number is empty
    if (bedNumber.isEmpty) {
      print('Error: Bed number cannot be empty.');
      return;
    }

    // find the bed
    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      print('Error: Bed $bedNumber not found in room $roomNumber.');
      return;
    }

    // check if bed is already occupied
    if (bed.isOccupied) {
      print('Error: Bed $bedNumber is already occupied.');
      return;
    }

    // get patient name from user
    stdout.write('Enter patient name: ');
    userInput = stdin.readLineSync();
    String patientName = '';
    if (userInput != null) {
      patientName = userInput.trim();
    }

    // check if patient name is empty
    if (patientName.isEmpty) {
      print('Error: Patient name cannot be empty.');
      return;
    }

    // try to assign the patient
    try {
      _bedManager.assignBedToPatient(roomNumber, bedNumber, patientName);
      print('\nSuccess: Assigned bed $roomNumber-$bedNumber to $patientName.');
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  // option 3: discharge patient
  void _releaseBed() {
    print('\nDISCHARGE PATIENT');

    // get room number from user
    stdout.write('\nEnter room number: ');
    String? userInput = stdin.readLineSync();
    String roomNumber = '';
    if (userInput != null) {
      roomNumber = userInput.trim();
    }

    // check if room number is empty
    if (roomNumber.isEmpty) {
      print('Error: Room number cannot be empty.');
      return;
    }

    // find the room
    Room? room = _bedManager.findRoom(roomNumber);
    if (room == null) {
      print('Error: Room $roomNumber not found.');
      return;
    }

    // show occupied beds
    List<Bed> occupiedBeds = room.getOccupiedBeds();
    if (occupiedBeds.isEmpty) {
      print('Error: No occupied beds in room $roomNumber.');
      return;
    }

    print('\nOccupied beds in this room:');
    for (var bed in occupiedBeds) {
      print('  - Bed ${bed.bedNumber}: ${bed.patientName}');
    }

    // get bed number to release
    stdout.write('\nEnter bed number to release: ');
    userInput = stdin.readLineSync();
    String bedNumber = '';
    if (userInput != null) {
      bedNumber = userInput.trim();
    }

    // check if bed number is empty
    if (bedNumber.isEmpty) {
      print('Error: Bed number cannot be empty.');
      return;
    }

    // find the bed
    Bed? bed = room.findBed(bedNumber);
    if (bed == null) {
      print('Error: Bed $bedNumber not found in room $roomNumber.');
      return;
    }

    // check if bed is empty
    if (!bed.isOccupied) {
      print('Error: Bed $bedNumber is empty.');
      return;
    }

    // ask for confirmation
    stdout.write('Are you sure you want to discharge this patient? (y/n): ');
    userInput = stdin.readLineSync();
    String confirmation = '';
    if (userInput != null) {
      confirmation = userInput.trim().toLowerCase();
    }

    // check confirmation
    if (confirmation != 'y' && confirmation != 'yes') {
      print('Discharge cancelled.');
      return;
    }

    // try to discharge the patient
    try {
      _bedManager.releaseBed(roomNumber, bedNumber);
      print(
        'Success: Patient discharged successfully from bed $roomNumber-$bedNumber.',
      );
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  // Option 4: Search for patient
  void _searchPatient() {
    print('\nSEARCH PATIENT');

    // Get patient name from user
    stdout.write('\nEnter patient name to search: ');
    String? userInput = stdin.readLineSync();
    String patientName = '';
    if (userInput != null) {
      patientName = userInput.trim();
    }

    // Check if patient name is empty
    if (patientName.isEmpty) {
      print('Error: Patient name cannot be empty.');
      return;
    }

    // find patients
    List<Map<String, String>> results = _bedManager.findPatient(patientName);

    // check if any patients were found
    if (results.isEmpty) {
      print('\nNo patients foun "$patientName".');
      return;
    }

    // Show results
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
