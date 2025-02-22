import 'dart:io';

import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CloseableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const CloseableAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: title != null
          ? Text(title!, style: TextStyle(color: theme.colorScheme.onSurface))
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HeaderText extends StatelessWidget {
  final String title;
  final String? subtitle;

  const HeaderText({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}

class CustomTextInput extends StatelessWidget {
  final String label;
  final String hint;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String>? validator;

  const CustomTextInput({
    super.key,
    required this.label,
    required this.hint,
    required this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }
}

class CategoryDropdownField extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const CategoryDropdownField({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category',
            style: theme.textTheme.labelMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selected,
          dropdownColor: theme.colorScheme.surfaceContainerHighest,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: categories
              .map((cat) => DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class ImageUploadField extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  final String label;

  const ImageUploadField({
    super.key,
    required this.image,
    required this.onTap,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: image != null ? FileImage(image!) : null,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: image == null
                  ? Icon(Icons.photo_camera,
                      color: theme.colorScheme.onSurfaceVariant, size: 36)
                  : null,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]
          ],
        ),
      ),
    );
  }
}

class BottomActionButton extends StatelessWidget {
  final String title;
  final ValueListenable<bool> isExecuting;
  final Future<void> Function() onPressed;

  const BottomActionButton({
    super.key,
    required this.title,
    required this.isExecuting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LoadingBorderButton(
          title: title,
          color: theme.colorScheme.primary,
          isExecuting: isExecuting,
          onPressed: () async {
            await onPressed();
            if (context.mounted) context.pop();
          },
        ),
      ),
    );
  }
}
