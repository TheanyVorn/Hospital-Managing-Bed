enum RoomType {
  general('General', 'General hospital beds'),
  icu('ICU', 'Intensive Care Unit'),
  emergency('Emergency', 'Emergency ward');

  final String displayName;
  final String description;

  const RoomType(this.displayName, this.description);

  static RoomType fromString(String value) {
    for (var type in RoomType.values) {
      if (type.displayName == value) {
        return type;
      }
    }
    return RoomType.general;
  }

  @override
  String toString() {
    return displayName;
  }
}
