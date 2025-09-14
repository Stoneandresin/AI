import '../models/item.dart';

/// Abstract repository for reading and writing [Item] data.
///
/// In the initial version of the app this repository can be backed
/// by a simple in‑memory list or a local database. Later on, an
/// implementation using Firebase (Firestore) can be provided to
/// synchronise data across devices. This abstraction allows the app
/// to remain offline‑first while still offering remote sync when
/// connectivity is available.
abstract class ItemRepository {
  /// Returns all items in the inventory.
  Future<List<Item>> getAllItems();

  /// Retrieves a single item by its [id]. Returns null if no item
  /// with the given id exists.
  Future<Item?> getItem(String id);

  /// Adds or updates an item in the repository.
  Future<void> upsertItem(Item item);

  /// Deletes an item from the repository.
  Future<void> deleteItem(String id);
}