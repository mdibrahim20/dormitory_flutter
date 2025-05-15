import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDormitoriesScreen extends StatefulWidget {
  const AdminDormitoriesScreen({Key? key}) : super(key: key);

  @override
  _AdminDormitoriesScreenState createState() => _AdminDormitoriesScreenState();
}

class _AdminDormitoriesScreenState extends State<AdminDormitoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  DocumentReference? _editingDoc;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceForDaysController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _sleepInfoController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();
  final TextEditingController _houseRulesController = TextEditingController();
  final TextEditingController _safetyController = TextEditingController();
  final TextEditingController _locationMapUrlController = TextEditingController();
  final TextEditingController _additionalImagesController = TextEditingController();

  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _apartments = [];
  String? _selectedBranchId;
  String? _selectedApartmentId;
  List<String> _roomNumbers = [];
  String? _selectedRoomNumber;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchBranches();
    _fetchApartments();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  Future<void> _fetchBranches() async {
    final snapshot = await FirebaseFirestore.instance.collection('branches').get();
    setState(() {
      _branches = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }
  Future<void> _fetchApartments() async {
    final snapshot = await FirebaseFirestore.instance.collection('apartments').get();
    setState(() {
      _apartments = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'apartment_name': data['apartment_name'] ?? 'Unnamed Apartment',
          'room_numbers': (data['room_numbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
        };
      }).toList();
    });
  }


  Future<void> _saveDormitory() async {
    if (_formKey.currentState!.validate()) {
      // ✅ get the values from controllers
      String mainImageUrl = _imageUrlController.text.trim();
      List<String> additionalImageUrls = _additionalImagesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final dormitoryData = {
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'image_url': mainImageUrl ?? '',
        'additional_images': additionalImageUrls,
        'available': true,
        'price': int.tryParse(_priceController.text.trim()) ?? 0,
        'price_for_days': int.tryParse(_priceForDaysController.text.trim()) ?? 0,
        'host_name': 'Admin',
        'host_duration': 'Updated Listing',
        'rating': 5.0,
        'available_dates': '',
        'category_id': _selectedCategoryId ?? '',
        'branch_id': _selectedBranchId ?? '',
        'apartment_id': _selectedApartmentId ?? '',
        'room_number': _selectedRoomNumber ?? '',
        'about': _aboutController.text.trim(),
        'sleep_info': _sleepInfoController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'amenities': _amenitiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'house_rules': _houseRulesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'safety': _safetyController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'location_map_url': _locationMapUrlController.text.trim(),
      };

      if (_editingDoc != null) {
        await _editingDoc!.update(dormitoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dormitory updated')),
        );
      } else {
        await FirebaseFirestore.instance.collection('dormitories').add(dormitoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dormitory added')),
        );
      }

      _clearForm();
      if (mounted) Navigator.pop(context);
    }
  }


  void _clearForm() {
    _editingDoc = null;
    _nameController.clear();
    _locationController.clear();
    _imageUrlController.clear();
    _priceController.clear();
    _priceForDaysController.clear();
    _aboutController.clear();
    _sleepInfoController.clear();
    _amenitiesController.clear();
    _houseRulesController.clear();
    _safetyController.clear();
    _locationMapUrlController.clear();
    _selectedCategoryId = null;
    _selectedBranchId = null;
    _selectedApartmentId= null;
    _selectedRoomNumber = null;
    _additionalImagesController.clear();

  }

  void _showDormitoryDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _editingDoc = doc.reference;
      _nameController.text = data['name'] ?? '';
      _locationController.text = data['location'] ?? '';
      _imageUrlController.text = data['image_url'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _priceForDaysController.text = data['price_for_days']?.toString() ?? '';
      _selectedCategoryId = data['category_id'] ?? '';
      _selectedBranchId = data['branch_id'] ?? '';
      _selectedApartmentId = data['apartment_id'] ?? '';
      _selectedRoomNumber = data['room_number'] ?? '';
      _aboutController.text = data['about'] ?? '';
      _sleepInfoController.text = (data['sleep_info'] as List<dynamic>?)?.join(', ') ?? '';
      _amenitiesController.text = (data['amenities'] as List<dynamic>?)?.join(', ') ?? '';
      _houseRulesController.text = (data['house_rules'] as List<dynamic>?)?.join(', ') ?? '';
      _safetyController.text = (data['safety'] as List<dynamic>?)?.join(', ') ?? '';
      _locationMapUrlController.text = data['location_map_url'] ?? '';
      _imageUrlController.text = data['image_url'] ?? '';
      _additionalImagesController.text = (data['additional_images'] as List<dynamic>?)?.join(', ') ?? '';
      if (_selectedApartmentId != null) {
        final selectedApartment = _apartments.firstWhere(
              (apt) => apt['id'] == _selectedApartmentId,
          orElse: () => {'room_numbers': []}, // fallback if not found
        );
        _roomNumbers = List<String>.from(selectedApartment['room_numbers'] ?? []);
      }

      if ((data['additional_images'] as List<dynamic>?) != null) {
        // optional: you can load network image urls if you want, OR leave empty as safe option
      }
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  doc != null ? 'Edit Dormitory' : 'Add New Dormitory',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter name' : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter location' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter image URL' : null,
                ),
                TextFormField(
                  controller: _additionalImagesController,
                  decoration: const InputDecoration(labelText: 'Additional Image URLs (comma separated)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter price' : null,
                ),
                TextFormField(
                  controller: _priceForDaysController,
                  decoration: const InputDecoration(labelText: 'Price for Days'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter price for days' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem<String>(
                      value: category['id'],
                      child: Text(category['name']),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Please select category' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedBranchId,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: _branches
                      .map(
                        (branch) => DropdownMenuItem<String>(
                      value: branch['id'],
                      child: Text(branch['name']),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBranchId = value;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Please select Branch' : null,
                ),
                // Apartment Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedApartmentId,
                  decoration: const InputDecoration(labelText: 'Apartment'),
                  items: _apartments
                      .map((apt) => DropdownMenuItem<String>(
                    value: apt['id'],
                    child: Text(apt['apartment_name']),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedApartmentId = value;
                      // Find and load room numbers from selected apartment
                      final selectedApartment = _apartments.firstWhere(
                            (apt) => apt['id'] == value,
                        orElse: () => {'room_numbers': []},
                      );

                      _roomNumbers = List<String>.from(selectedApartment['room_numbers'] ?? []);
                      _selectedRoomNumber = null;
                    });
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please select Apartment' : null,
                ),

                const SizedBox(height: 12),

// Conditionally show Room Number Dropdown
                if (_roomNumbers.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedRoomNumber,
                    decoration: const InputDecoration(labelText: 'Room Number'),
                    items: _roomNumbers
                        .map((room) => DropdownMenuItem<String>(
                      value: room,
                      child: Text(room),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRoomNumber = value;
                      });
                    },
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please select Room Number' : null,
                  ),

                TextFormField(
                  controller: _aboutController,
                  decoration: const InputDecoration(labelText: 'About'),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter about' : null,
                ),
                TextFormField(
                  controller: _sleepInfoController,
                  decoration: const InputDecoration(labelText: 'Sleep Info (comma separated)'),
                ),
                TextFormField(
                  controller: _amenitiesController,
                  decoration: const InputDecoration(labelText: 'Amenities (comma separated)'),
                ),
                TextFormField(
                  controller: _houseRulesController,
                  decoration: const InputDecoration(labelText: 'House Rules (comma separated)'),
                ),
                TextFormField(
                  controller: _safetyController,
                  decoration: const InputDecoration(labelText: 'Safety (comma separated)'),
                ),
                TextFormField(
                  controller: _locationMapUrlController,
                  decoration: const InputDecoration(labelText: 'Location Map URL'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveDormitory,
                  child: Text(doc != null ? 'Update' : 'Save'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _deleteDormitory(String docId) async {
    await FirebaseFirestore.instance.collection('dormitories').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dormitory deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Dormitories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('dormitories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final dorms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: dorms.length,
            itemBuilder: (context, index) {
              final dorm = dorms[index];
              final data = dorm.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: data['image_url'] != null
                      ? Image.network(
                    data['image_url'],
                    width: 60,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image, size: 60),
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(
                      'Location: ${data['location'] ?? ''}\nPrice: \$${data['price'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showDormitoryDialog(doc: dorm),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDormitory(dorm.id),
                      ),
                    ],
                  ),

                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDormitoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
