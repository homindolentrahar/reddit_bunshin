import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:reddit_bunshin/core/ui/themes.dart';

class MainTextField extends StatelessWidget {
  final String? initialValue;
  final String name;
  final String hint;
  final int lines;
  final bool isRequired;
  final List<FormFieldValidator>? validators;
  final VoidCallback? onPressed;
  final TextInputAction action;
  final TextInputType type;

  const MainTextField({
    super.key,
    this.initialValue,
    required this.name,
    required this.hint,
    this.lines = 1,
    this.isRequired = true,
    this.validators,
    this.onPressed,
    this.action = TextInputAction.done,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      keyboardType: type,
      textInputAction: action,
      maxLines: lines,
      minLines: lines,
      onTap: onPressed,
      validator: FormBuilderValidators.compose([
        if (isRequired) FormBuilderValidators.required(),
        ...?validators,
      ]),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.drawerColor,
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
