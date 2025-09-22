import 'package:flutter/material.dart';
import '../../data/models/item.dart';

/// A screen for adding or editing inventory items.
class AddItemScreen extends StatefulWidget {
  final Item? item;
  
  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _brandController = TextEditingController();
  final _variantController = TextEditingController();
  final _reorderMinController = TextEditingController();
  
  String _selectedCategory = 'Tools';
  final List<String> _categories = ['Tools', 'PPE', 'Materials', 'Equipment', 'Consumables'];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _populateFields(widget.item!);
    }
  }

  void _populateFields(Item item) {
    _nameController.text = item.name;
    _skuController.text = item.sku;
    _brandController.text = item.brand;
    _variantController.text = item.variant;
    _reorderMinController.text = item.reorderMin.toString();
    _selectedCategory = item.category;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add New Item'),
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Item Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText: 'e.g. Cordless Drill',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU/Part Number *',
                        hintText: 'e.g. CD-001',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a SKU';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand/Manufacturer',
                        hintText: 'e.g. DeWalt',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _variantController,
                      decoration: const InputDecoration(
                        labelText: 'Variant/Specification',
                        hintText: 'e.g. 18V, Red, Large',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reorderMinController,
                      decoration: const InputDecoration(
                        labelText: 'Reorder Minimum *',
                        hintText: '5',
                        border: OutlineInputBorder(),
                        suffixText: 'units',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a reorder minimum';
                        }
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed < 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Image',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                          Text('Tap to add image'),
                          Text('(Feature coming soon)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditing ? 'Update Item' : 'Add Item',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = Item(
      id: widget.item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      sku: _skuController.text.trim(),
      brand: _brandController.text.trim(),
      variant: _variantController.text.trim(),
      reorderMin: int.parse(_reorderMinController.text),
      imageRef: '',
    );

    // TODO: Save to database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.item != null ? 'Item updated successfully' : 'Item added successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(item);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _brandController.dispose();
    _variantController.dispose();
    _reorderMinController.dispose();
    super.dispose();
  }
}