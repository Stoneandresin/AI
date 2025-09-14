import 'package:flutter/foundation.dart';

/// Records a user observation of an [Item] at a particular point in
/// time and location.
///
/// Observations capture the quantity, confidence score and any
/// additional notes provided by the operator. The `method` field
/// indicates how the observation was created (computer vision,
/// QR code scan, voice input, etc.).
@immutable
class Observation {
  final String id;
  final String itemId;
  final String userId;
  final DateTime timestamp;
  final int quantity;
  final double confidence;
  final ObservationMethod method;
  final String notes;

  const Observation({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.timestamp,
    required this.quantity,
    required this.confidence,
    required this.method,
    this.notes = '',
  });
}

/// Enumerates the supported ways an [Observation] can be created.
enum ObservationMethod { cv, qr, voice }