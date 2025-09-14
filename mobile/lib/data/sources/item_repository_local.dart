import 'dart:collection';
import '../models/item.dart';
import 'item_repository.dart';

/// Simple in‑memory implementation of [ItemRepository]. This is
/// suitable for development and testing before integrating a
/// persistent store. Items are held in a map keyed by their id.
class LocalItemRepository implements ItemRepository {
  final Map<String, Item> _items = HashMap();

  @override
  Future<void> deleteItem(String id) async {
    _items.remove(id);
  }

  @override
  Future<List<Item>> getAllItems() async {
    return _items.values.toList(growable: false);
  }

  @override
  Future<Item?> getItem(String id) async {
    return _items[id];
  }

  @override
  Future<void> upsertItem(Item item) async {
    _items[item.id] = item;
  }
}