// represents a single hospital bed
class Bed {
  final String bedNumber;
  bool isOccupied;
  String? patientName;
  DateTime? assignedDate;

  // constructor to create a bed
  Bed({
    required this.bedNumber,
    this.isOccupied = false,
    this.patientName,
    this.assignedDate,
  });

  // assign a patient to this bed
  void assignPatient(String patientName) {
    if (isOccupied) {
      throw Exception('Bed $bedNumber is already occupied');
    }
    this.patientName = patientName;
    isOccupied = true;
    assignedDate = DateTime.now();
  }

  // release the bed when patient is discharging
  void releaseBed() {
    if (!isOccupied) {
      throw Exception('Bed $bedNumber is already vacant');
    }
    patientName = null;
    isOccupied = false;
    assignedDate = null;
  }

  // shows bed info
  @override
  String toString() {
    if (isOccupied) {
      return 'Bed $bedNumber: $patientName (since ${assignedDate?.toString().substring(0, 10)})';
    }
    return 'Bed $bedNumber: Available';
  }
}
