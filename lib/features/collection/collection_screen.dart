import 'package:accollect/core/models/item_ui_model.dart';
import 'package:accollect/core/widgets/item_tile.dart';
import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  final String collectionName;
  final String? collectionImageUrl;
  final String collectionKey;
  final List<ItemUIModel> items;

  const CollectionScreen({
    super.key,
    required this.collectionName,
    required this.collectionKey,
    required this.collectionImageUrl,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isCollectionEmpty = items.isEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCollectionHeader(),
              const SizedBox(height: 16),
              if (isCollectionEmpty)
                _buildEmptyState()
              else ...{
                ..._buildSearchAndFilters(),
                _buildItemList(),
              }
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Text(
        'Collection',
        style: TextStyle(color: Colors.white),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // TODO: Implement menu options
          },
        ),
      ],
    );
  }

  Widget _buildCollectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          collectionName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        CircleAvatar(
          radius: 20,
          backgroundImage: collectionImageUrl != null
              ? NetworkImage(collectionImageUrl!)
              : null,
          child: collectionImageUrl == null
              ? const Icon(Icons.image, color: Colors.white)
              : null,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'No items in your collection.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchAndFilters() {
    return [
      TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: Implement filter functionality
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
            label: const Text(
              'Filter',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: Implement sorting functionality
            },
            icon: const Icon(Icons.sort, color: Colors.white),
            label: const Text(
              'Year',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildItemList() {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemTile(
            item: item,
            onTap: () {
              // TODO: Navigate to item details
            },
          );
        },
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () {
        // TODO: Navigate to Add New Item screen
      },
      child: const Icon(Icons.add, color: Colors.black),
    );
  }
}
