import 'package:accollect/core/models/item_ui_model.dart';
import 'package:accollect/core/widgets/empty_state.dart';
import 'package:accollect/core/widgets/filters.dart';
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
                EmptyStateWidget(
                  message: 'No items in your collection.',
                  actionMessage: 'Add a new item to get started.',
                  onPressed: () {
                    // TODO: Navigate to add item screen
                  },
                )
              else ...[
                SearchBar(),
                const SizedBox(height: 16),
                FiltersWidget(),
                const SizedBox(height: 16),
                _buildItemList(),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          // TODO: Navigate to Add New Item screen
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
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
}
