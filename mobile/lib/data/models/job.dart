import 'location.dart';

class Job {
  final String id;
  final String name;
  final Location? siteGeo;
  final String customer;
  final String status;
  final DateTime? startTs;
  final DateTime? endTs;

  const Job({
    required this.id,
    required this.name,
    this.siteGeo,
    required this.customer,
    required this.status,
    this.startTs,
    this.endTs,
  });
}
