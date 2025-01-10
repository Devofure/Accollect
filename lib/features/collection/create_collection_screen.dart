import 'package:flutter/material.dart';

class CreateCollectionScreen extends StatefulWidget {
  const CreateCollectionScreen({super.key});

  @override
  State<CreateCollectionScreen> createState() => _CreateCollectionScreenState();
}

class _CreateCollectionScreenState extends State<CreateCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _collectionName;
  String? _description;
  String _category = 'Wine'; // Default category
  String? _uploadedImage;

  // Categories for the dropdown
  final List<String> _categories = ['Wine', 'LEGO', 'Funko Pop'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(), // Close the screen
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Subtitle
                const Text(
                  'Start collecting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a new collection by filling in the details below.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Collection Name Input
                _buildTextInput(
                  label: 'Collection Name',
                  hint: 'Enter collection name',
                  onSaved: (value) => _collectionName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a collection name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Input
                _buildTextInput(
                  label: 'Description',
                  hint: 'Enter collection description',
                  onSaved: (value) => _description = value,
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                _buildDropdownInput(),

                const SizedBox(height: 24),

                // Upload Image Section
                Center(
                  child: Column(
                    children: [
                      if (_uploadedImage != null)
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(_uploadedImage!),
                        )
                      else
                        GestureDetector(
                          onTap: _uploadImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_camera,
                                color: Colors.white, size: 32),
                          ),
                        ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload Image',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Save Collection Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _saveCollection,
                    child: const Text('Save Collection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required String hint,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdownInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _category,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          items: _categories
              .map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _category = value!;
            });
          },
        ),
      ],
    );
  }

  void _uploadImage() async {
    // TODO: Implement image upload logic
    setState(() {
      _uploadedImage = 'https://via.placeholder.com/150';
    });
  }

  void _saveCollection() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('Collection Name: $_collectionName');
      print('Description: $_description');
      print('Category: $_category');
      print('Uploaded Image: $_uploadedImage');
      Navigator.of(context).pop();
    }
  }
}
