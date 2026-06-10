import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/search/presentation/search_controller.dart' as search_ctrl;

/// SearchTextField is a custom search text field.
class SearchTextField extends StatelessWidget {
  final search_ctrl.PiliSearchController controller;
  final Function(String) onSubmitted;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.textEditingController,
      focusNode: controller.searchFocusNode,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: (value) => controller.onInputChanged(value),
      decoration: InputDecoration(
        hintText: '搜索',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(() => controller.inputText.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => controller.onClearInput(),
              )
            : const SizedBox.shrink()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
