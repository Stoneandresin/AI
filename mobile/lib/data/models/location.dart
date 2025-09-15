enum LocationType {
  gps,
  qr,
  ar,
  ble,
}

class Location {
  final String id;
  final LocationType type;
  final String label;
  final double? latitude;
  final double? longitude;
  final String? indoorRef;
  final String? anchorId;

  const Location({
    required this.id,
    required this.type,
    required this.label,
    this.latitude,
    this.longitude,
    this.indoorRef,
    this.anchorId,
  });
}
