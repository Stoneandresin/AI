import '../models/item.dart';
import '../models/observation.dart';

/// Service for managing inventory items and observations.
/// This is a simple in-memory implementation that will be replaced
/// with a proper database implementation later.
class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  final List<Item> _items = [
    const Item(
      id: '1',
      name: 'Cordless Drill',
      category: 'Tools',
      sku: 'CD-001',
      brand: 'DeWalt',
      variant: '18V',
      reorderMin: 2,
      imageRef: 'drill.jpg',
    ),
    const Item(
      id: '2',
      name: 'Safety Helmet',
      category: 'PPE',
      sku: 'SH-001',
      brand: 'SafeMax',
      variant: 'White',
      reorderMin: 10,
      imageRef: 'helmet.jpg',
    ),
    const Item(
      id: '3',
      name: 'Concrete Mix',
      category: 'Materials',
      sku: 'CM-001',
      brand: 'QuickSet',
      variant: '50kg bag',
      reorderMin: 20,
      imageRef: 'concrete.jpg',
    ),
    const Item(
      id: '4',
      name: 'Level',
      category: 'Tools',
      sku: 'LV-001',
      brand: 'Stanley',
      variant: '48 inch',
      reorderMin: 3,
      imageRef: 'level.jpg',
    ),
    const Item(
      id: '5',
      name: 'Safety Goggles',
      category: 'PPE',
      sku: 'SG-001',
      brand: 'SafeMax',
      variant: 'Clear',
      reorderMin: 15,
      imageRef: 'goggles.jpg',
    ),
  ];

  final List<Observation> _observations = [];

  // Items management
  List<Item> get items => List.unmodifiable(_items);

  void addItem(Item item) {
    _items.add(item);
  }

  void updateItem(Item item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
  }

  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Item> searchItems(String query) {
    if (query.isEmpty) return items;
    
    final lowerQuery = query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.sku.toLowerCase().contains(lowerQuery) ||
          item.brand.toLowerCase().contains(lowerQuery) ||
          item.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Item> getItemsByCategory(String category) {
    if (category == 'All') return items;
    return _items.where((item) => item.category == category).toList();
  }

  // Observations management
  List<Observation> get observations => List.unmodifiable(_observations);

  void addObservation(Observation observation) {
    _observations.add(observation);
  }

  List<Observation> getObservationsForItem(String itemId) {
    return _observations.where((obs) => obs.itemId == itemId).toList();
  }

  List<Observation> getRecentObservations({int limit = 50}) {
    final sorted = List<Observation>.from(_observations)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  // Utility methods
  List<String> get categories {
    final categorySet = <String>{'All'};
    for (final item in _items) {
      categorySet.add(item.category);
    }
    return categorySet.toList();
  }

  Map<String, int> getInventoryCounts() {
    // This would normally calculate actual stock levels from observations
    // For now, return dummy data
    final counts = <String, int>{};
    for (final item in _items) {
      counts[item.id] = 10; // Dummy count
    }
    return counts;
  }

  List<Item> getLowStockItems() {
    final counts = getInventoryCounts();
    return _items.where((item) {
      final currentCount = counts[item.id] ?? 0;
      return currentCount <= item.reorderMin;
    }).toList();
  }
}