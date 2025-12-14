/// Represents a hospital bed with its status and patient information
class Bed {
  final String bedNumber;
  bool isOccupied;
  String? patientName;
  DateTime? assignedDate;

  Bed({
    required this.bedNumber,
    this.isOccupied = false,
    this.patientName,
    this.assignedDate,
  });

  /// Assigns a patient to this bed
  void assignPatient(String patientName) {
    if (isOccupied) {
      throw Exception('Bed $bedNumber is already occupied');
    }
    this.patientName = patientName;
    isOccupied = true;
    assignedDate = DateTime.now();
  }

  /// Releases the bed by removing patient information
  void releaseBed() {
    if (!isOccupied) {
      throw Exception('Bed $bedNumber is already vacant');
    }
    patientName = null;
    isOccupied = false;
    assignedDate = null;
  }

  @override
  String toString() {
    if (isOccupied) {
      return 'Bed $bedNumber: $patientName (since ${assignedDate?.toString().substring(0, 10)})';
    }
    return 'Bed $bedNumber: Available';
  }
}
