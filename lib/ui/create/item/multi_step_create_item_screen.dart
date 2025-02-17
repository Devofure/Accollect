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
      body: Column(
        children: [
          // Stepper Header (with defined height)
          SizedBox(
            height: 100, // Prevents height constraint issues
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              steps: [
                Step(
                  title: const Text('Category',
                      style: TextStyle(color: Colors.white)),
                  isActive: _currentStep >= 0,
                  state: _stepState(0),
                  content: const SizedBox.shrink(),
                ),
                Step(
                  title: const Text('Images',
                      style: TextStyle(color: Colors.white)),
                  isActive: _currentStep >= 1,
                  state: _stepState(1),
                  content: const SizedBox.shrink(),
                ),
                Step(
                  title: const Text('Details',
                      style: TextStyle(color: Colors.white)),
                  isActive: _currentStep >= 2,
                  state: _stepState(2),
                  content: const SizedBox.shrink(),
                ),
              ],
              controlsBuilder: (context, details) =>
                  const SizedBox.shrink(), // No default buttons
            ),
          ),

          // Step Content (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _getStepContent(),
            ),
          ),
        ],
      ),

      // Bottom Navigation (Static)
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
                          final form = viewModel.formKey.currentState!;
                          if (form.validate()) {
                            form.save();
                            setState(() => _isSaving = true);
                            try {
                              await viewModel.saveItemCommand
                                  .executeWithFuture();
                              if (!mounted) return;
                              Navigator.pop(context);
                            } finally {
                              if (mounted) setState(() => _isSaving = false);
                            }
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text('Finish'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return const StepCategoryWidget();
      case 1:
        return const StepImagesWidget();
      case 2:
        return const StepDetailsWidget();
      default:
        return Container();
    }
  }

  StepState _stepState(int stepIndex) {
    if (_currentStep == stepIndex) return StepState.editing;
    if (_currentStep > stepIndex) return StepState.complete;
    return StepState.indexed;
  }
}
