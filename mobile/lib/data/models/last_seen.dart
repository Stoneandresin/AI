import 'location.dart';

class LastSeen {
  final String itemId;
  final Location location;
  final DateTime timestamp;
  final String userId;

  const LastSeen({
    required this.itemId,
    required this.location,
    required this.timestamp,
    required this.userId,
  });
}
