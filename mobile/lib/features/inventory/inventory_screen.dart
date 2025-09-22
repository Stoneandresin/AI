import 'package:flutter/material.dart';
import '../../data/models/item.dart';
import '../../data/services/inventory_service.dart';
import 'add_item_screen.dart';

/// A screen that displays the inventory of items with search and filtering.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<Item> _filteredItems = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _filteredItems = _inventoryService.items;
    });
  }

  void _filterItems() {
    setState(() {
      var items = _inventoryService.items;
      
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        items = _inventoryService.searchItems(_searchQuery);
      }
      
      // Apply category filter
      if (_selectedCategory != 'All') {
        items = items.where((item) => item.category == _selectedCategory).toList();
      }
      
      _filteredItems = items;
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterItems();
  }

  void _onCategoryChanged(String category) {
    _selectedCategory = category;
    _filterItems();
  }

  List<String> get _categories => _inventoryService.categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddItemScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search items...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _onCategoryChanged(category),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Items list
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items found.\nTry adjusting your search or add new items.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(item.category),
                            child: Text(
                              item.category.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.brand} - ${item.variant}'),
                              Text('SKU: ${item.sku}'),
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_outlined,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Min: ${item.reorderMin}',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Chip(
                                label: Text(item.category),
                                backgroundColor: _getCategoryColor(item.category).withOpacity(0.2),
                              ),
                            ],
                          ),
                          onTap: () => _showItemDetails(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
      default:
        return Colors.grey;
    }
  }

  void _showItemDetails(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brand: ${item.brand}'),
            Text('Variant: ${item.variant}'),
            Text('SKU: ${item.sku}'),
            Text('Category: ${item.category}'),
            Text('Reorder Minimum: ${item.reorderMin}'),
            const SizedBox(height: 16),
            const Text(
              'Last Seen Information:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('No location data available yet'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}