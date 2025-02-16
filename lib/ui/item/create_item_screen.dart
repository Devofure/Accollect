import 'package:accollect/ui/item/create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateItemScreen extends StatelessWidget {
  const CreateItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddNewItemViewModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CloseableAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderText(title: 'Add New Item'),
                  const SizedBox(height: 24),
                  CustomTextInput(
                    label: 'Item Name',
                    hint: 'Enter item name',
                    onSaved: viewModel.setTitle,
                    validator: viewModel.validateTitle,
                  ),
                  const SizedBox(height: 16),
                  CustomTextInput(
                    label: 'Description',
                    hint: 'Enter item description',
                    onSaved: viewModel.setDescription,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: viewModel.fetchCategoriesCommand,
                    builder: (context, categories, _) {
                      final uniqueCats = categories.toSet().toList();
                      if (!uniqueCats.contains(viewModel.selectedCategory)) {
                        viewModel.setCategory(
                            uniqueCats.isNotEmpty ? uniqueCats.first : null);
                      }
                      return CategoryDropdownField(
                        categories: uniqueCats,
                        selected: viewModel.selectedCategory,
                        onChanged: (selected) {
                          if (selected != null) viewModel.setCategory(selected);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ImageUploadField(
                    image: viewModel.uploadedImage,
                    onTap: viewModel.pickImage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionButton(
        title: 'Save Item',
        color: Colors.blue,
        isExecuting: viewModel.saveItemCommand.isExecuting,
        onPressed: () async {
          await viewModel.saveItemCommand.executeWithFuture();
        },
      ),
    );
  }
}
