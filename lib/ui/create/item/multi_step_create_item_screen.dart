import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/create/item/step_category_widget.dart';
import 'package:accollect/ui/create/item/step_details_widget.dart';
import 'package:accollect/ui/create/item/step_images_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiStepCreateItemScreen extends StatefulWidget {
  const MultiStepCreateItemScreen({super.key});

  @override
  State<MultiStepCreateItemScreen> createState() =>
      _MultiStepCreateItemScreenState();
}

class _MultiStepCreateItemScreenState extends State<MultiStepCreateItemScreen> {
  int _currentStep = 0;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Create Item',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                steps: [
                  _buildStep(theme, 'Images', 0, const StepImagesWidget()),
                  _buildStep(theme, 'Details', 1, const StepDetailsWidget()),
                  _buildStep(theme, 'Category', 2, const StepCategoryWidget()),
                ],
                controlsBuilder: (context, details) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, viewModel, theme),
    );
  }

  Step _buildStep(
      ThemeData theme, String title, int stepIndex, Widget content) {
    return Step(
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
      isActive: _currentStep >= stepIndex,
      state: _stepState(stepIndex),
      content: content,
    );
  }

  Widget _buildBottomBar(BuildContext context,
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    return BottomAppBar(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0)
              ElevatedButton(
                onPressed: () => setState(() => _currentStep--),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
                child: const Text('Back'),
              ),
            if (_currentStep < 2)
              ElevatedButton(
                onPressed: () => setState(() => _currentStep++),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Next'),
              )
            else
              ElevatedButton(
                onPressed: _isSaving ? null : () => _saveItem(viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Finish'),
              ),
          ],
        ),
      ),
    );
  }

  void _saveItem(MultiStepCreateItemViewModel viewModel) async {
    final formState = viewModel.formKey.currentState;
    if (formState == null || !formState.validate()) {
      debugPrint("🚨 Form validation failed!");
      return;
    }
    formState.save();
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);
    try {
      await viewModel.saveItemCommand.executeWithFuture();
      if (mounted) {
        setState(() => _isSaving = false);
      }
      if (mounted) {
        navigator.pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  StepState _stepState(int stepIndex) {
    if (_currentStep == stepIndex) return StepState.editing;
    if (_currentStep > stepIndex) return StepState.complete;
    return StepState.indexed;
  }
}
