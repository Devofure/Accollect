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
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Create Item', style: TextStyle(color: Colors.white)),
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
                  Step(
                    title: const Text('Images',
                        style: TextStyle(color: Colors.white)),
                    isActive: _currentStep >= 0,
                    state: _stepState(0),
                    content: const StepImagesWidget(),
                  ),
                  Step(
                    title: const Text('Details',
                        style: TextStyle(color: Colors.white)),
                    isActive: _currentStep >= 1,
                    state: _stepState(1),
                    content: const StepDetailsWidget(),
                  ),
                  Step(
                    title: const Text('Category',
                        style: TextStyle(color: Colors.white)),
                    isActive: _currentStep >= 2,
                    state: _stepState(2),
                    content: const StepCategoryWidget(),
                  ),
                ],
                controlsBuilder: (context, details) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
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
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back'),
                ),
              if (_currentStep < 2)
                ElevatedButton(
                  onPressed: () => setState(() => _currentStep++),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Next'),
                )
              else
                ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final formState = viewModel.formKey.currentState;
                          if (formState == null || !formState.validate()) {
                            debugPrint("🚨 Form validation failed!");
                            return;
                          }
                          formState.save();
                          setState(() => _isSaving = true);
                          try {
                            await viewModel.saveItemCommand.executeWithFuture();
                            if (!mounted) return;
                            Navigator.pop(context);
                          } finally {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Finish'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  StepState _stepState(int stepIndex) {
    if (_currentStep == stepIndex) return StepState.editing;
    if (_currentStep > stepIndex) return StepState.complete;
    return StepState.indexed;
  }
}
