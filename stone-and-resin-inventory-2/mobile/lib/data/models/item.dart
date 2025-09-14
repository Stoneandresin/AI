/// Represents a single inventory item such as a tool or material.
///
/// An [Item] encapsulates the properties used throughout the app to
/// identify and categorise stock. Additional fields like `imageRef`
/// can be used to fetch images from cloud storage to assist with
/// recognition and display.
class Item {
  final String id;
  final String name;
  final String category;
  final String sku;
  final String brand;
  final String variant;
  final int reorderMin;
  final String imageRef;

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.brand,
    required this.variant,
    required this.reorderMin,
    required this.imageRef,
  });
}