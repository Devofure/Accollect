import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/create/item/step_category_widget.dart';
import 'package:accollect/ui/create/item/step_details_widget.dart';
import 'package:accollect/ui/create/item/step_extra_info_widget.dart';
import 'package:accollect/ui/create/item/step_images_widget.dart';
import 'package:accollect/ui/create/item/step_online_images_widget.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
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

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Details', 'widget': StepDetailsWidget()},
    {'title': 'Online Images', 'widget': const StepOnlineImagesWidget()},
    {'title': 'Images', 'widget': const StepImagesWidget()},
    {'title': 'Category', 'widget': const StepCategoryWidget()},
    {'title': 'Extra Info', 'widget': const StepExtraInfoWidget()},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CloseableAppBar(title: 'Create Item'),
      body: Form(
        key: viewModel.formKey,
        child: Column(
          children: [
            _buildScrollableStepper(theme),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _steps[_currentStep]
                    ['widget'], // Render current step's content
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, viewModel, theme),
    );
  }

  Widget _buildScrollableStepper(ThemeData theme) {
    const double stepWidth = 120.0; // Base width for each step.
    const double stepSpacing = 16.0; // Spacing between steps.
    final int count = _steps.length;
    final double totalWidth = (count * stepWidth) + ((count - 1) * stepSpacing);

    return SizedBox(
      height: 90,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: List.generate(count, (index) => _buildStep(theme, index)),
              controlsBuilder: (context, details) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  /// Each step's title now has right padding except for the last step.
  Step _buildStep(ThemeData theme, int index) {
    const double stepSpacing = 16.0;
    return Step(
      title: Padding(
        padding: EdgeInsets.only(
            right: index == _steps.length - 1 ? 0 : stepSpacing),
        child: Text(
          _steps[index]['title'],
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
      isActive: _currentStep >= index,
      state: _stepState(index),
      content: const SizedBox.shrink(), // No content rendered here.
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
            if (_currentStep < _steps.length - 1)
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
