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
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: title != null
          ? Text(title!, style: const TextStyle(color: Colors.white))
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
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

  const CustomTextInput(
      {super.key,
      required this.label,
      required this.hint,
      required this.onSaved,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
}

class CategoryDropdownField extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const CategoryDropdownField(
      {super.key,
      required this.categories,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selected,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
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

  const ImageUploadField(
      {super.key, required this.image, required this.onTap, this.label = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null
                  ? const Icon(Icons.photo_camera,
                      color: Colors.white, size: 36)
                  : null,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ]
          ],
        ),
      ),
    );
  }
}

class BottomActionButton extends StatelessWidget {
  final String title;
  final Color color;
  final ValueListenable<bool> isExecuting;
  final Future<void> Function() onPressed;

  const BottomActionButton({
    super.key,
    required this.title,
    required this.color,
    required this.isExecuting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LoadingBorderButton(
          title: title,
          color: color,
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
