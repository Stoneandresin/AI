import 'package:flutter/material.dart';
import '../../data/models/observation.dart';
import '../../data/services/inventory_service.dart';

/// A screen that displays a list of observations.
class ObservationListScreen extends StatelessWidget {
  final List<Observation> observations;

  const ObservationListScreen({Key? key, required this.observations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inventoryService = InventoryService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Observations'),
      ),
      body: observations.isEmpty
          ? const Center(
              child: Text(
                'No observations yet.\nStart scanning items to see them here!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: observations.length,
              itemBuilder: (context, index) {
                final obs = observations[index];
                final item = inventoryService.getItemById(obs.itemId);
                final itemName = item?.name ?? 'Unknown Item';
                final itemSku = item?.sku ?? 'No SKU';
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getMethodColor(obs.method),
                      child: Text('${obs.quantity}'),
                    ),
                    title: Text(itemName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SKU: $itemSku'),
                        Text('Method: ${obs.method.name}'),
                        Text('Time: ${_formatDateTime(obs.timestamp)}'),
                        if (obs.userId != null) Text('User: ${obs.userId}'),
                        if (obs.locationId != null) Text('Location: ${obs.locationId}'),
                        if (obs.notes.isNotEmpty) Text('Notes: ${obs.notes}'),
                      ],
                    ),
                    trailing: obs.confidence > 0
                        ? Chip(
                            label: Text('${(obs.confidence * 100).toInt()}%'),
                            backgroundColor: _getConfidenceColor(obs.confidence),
                          )
                        : Icon(_getMethodIcon(obs.method)),
                  ),
                );
              },
            ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green.withOpacity(0.2);
    if (confidence >= 0.5) return Colors.orange.withOpacity(0.2);
    return Colors.red.withOpacity(0.2);
  }

  Color _getMethodColor(ObservationMethod method) {
    switch (method) {
      case ObservationMethod.scan:
        return Colors.blue;
      case ObservationMethod.cv:
        return Colors.green;
      case ObservationMethod.qr:
        return Colors.orange;
      case ObservationMethod.voice:
        return Colors.purple;
    }
  }

  IconData _getMethodIcon(ObservationMethod method) {
    switch (method) {
      case ObservationMethod.scan:
        return Icons.camera_alt;
      case ObservationMethod.cv:
        return Icons.visibility;
      case ObservationMethod.qr:
        return Icons.qr_code_scanner;
      case ObservationMethod.voice:
        return Icons.mic;
    }
  }
}
}
