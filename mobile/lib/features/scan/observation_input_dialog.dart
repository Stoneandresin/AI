import 'package:flutter/material.dart';
import '../../data/models/observation.dart';
import '../../data/models/item.dart';
import '../../data/services/inventory_service.dart';

/// A dialog for capturing observation details including item selection, quantity and notes.
class ObservationInputDialog extends StatefulWidget {
  const ObservationInputDialog({super.key});

  @override
  State<ObservationInputDialog> createState() => _ObservationInputDialogState();
}

class _ObservationInputDialogState extends State<ObservationInputDialog> {
  final InventoryService _inventoryService = InventoryService();
  int _quantity = 1;
  final _notesController = TextEditingController();
  ObservationMethod _method = ObservationMethod.scan;
  Item? _selectedItem;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final items = _inventoryService.searchItems(_searchQuery);
    
    return AlertDialog(
      title: const Text('Log Observation'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Selection
              const Text(
                'Select Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = _selectedItem?.id == item.id;
                    return ListTile(
                      selected: isSelected,
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(item.category),
                        child: Text(
                          item.category.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: Text('${item.brand} - ${item.sku}'),
                      onTap: () => setState(() => _selectedItem = item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Quantity Selection
              const Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Method Selection
              const Text(
                'Detection Method',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ObservationMethod>(
                value: _method,
                items: ObservationMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Row(
                      children: [
                        Icon(_getMethodIcon(method)),
                        const SizedBox(width: 8),
                        Text(_getMethodLabel(method)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _method = value!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Notes
              const Text(
                'Notes (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add any additional notes...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedItem != null ? () {
            final observation = Observation(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              itemId: _selectedItem!.id,
              timestamp: DateTime.now(),
              quantity: _quantity,
              method: _method,
              notes: _notesController.text.trim(),
            );
            Navigator.of(context).pop(observation);
          } : null,
          child: const Text('Log Observation'),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tools':
        return Colors.blue;
      case 'ppe':
        return Colors.orange;
      case 'materials':
        return Colors.green;
      case 'equipment':
        return Colors.purple;
      default:
        return Colors.grey;
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

  String _getMethodLabel(ObservationMethod method) {
    switch (method) {
      case ObservationMethod.scan:
        return 'Manual Scan';
      case ObservationMethod.cv:
        return 'Computer Vision';
      case ObservationMethod.qr:
        return 'QR Code';
      case ObservationMethod.voice:
        return 'Voice Input';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}