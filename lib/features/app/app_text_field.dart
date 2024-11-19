import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    this.controller,
    this.onTap,
    this.onEditingComplete,
    this.onChange,
    this.onFieldSubmitted,
    this.onSaved,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.enabled,
    this.textInputType,
    this.textInputAction,
    this.textDirection,
    this.validator,
    this.maxLengthEnforcement,
    this.focusNode,
    this.autoValidateMode,
    this.scrollPhysics,
    this.scrollController,
    this.initialValue,
    this.keyboardAppearance,
    this.textAlignVertical,
    this.toolbarOptions,
    this.obscuringCharacter = "•",
    this.expands = false,
    this.readOnly = false,
    this.autocorrect = true,
    this.showLength = false,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.titleField,
    this.obscure = false,
    this.disableBorders = false,
    this.prefixIcon,
    this.icon,
    this.hintTextStyle,
    this.textStyle,
    this.suffixIcon,
    this.suffix,
    this.hintText,
    this.labelText,
    this.inputFormatters,
    this.contentPadding,
    this.filledColor,
    this.bordersColor,
  }) : super(key: key);

  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final void Function(String val)? onChange;
  final void Function(String val)? onFieldSubmitted;
  final void Function(String? val)? onSaved;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool? enabled;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final FormFieldValidator<String?>? validator;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final FocusNode? focusNode;
  final AutovalidateMode? autoValidateMode;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final String? initialValue;
  final Brightness? keyboardAppearance;
  final TextAlignVertical? textAlignVertical;
  final ToolbarOptions? toolbarOptions;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final EdgeInsets scrollPadding;
  final bool expands;
  final bool readOnly;
  final bool autocorrect;
  final String obscuringCharacter;
  final String? titleField;
  final bool showLength;
  final bool obscure;
  final Widget? prefixIcon;
  final Widget? icon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final String? labelText;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final Color? filledColor;
  final Color? bordersColor;
  final bool disableBorders;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      onChanged: onChange,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: showLength ? maxLength : null,
      textAlign: textAlign,
      enabled: enabled,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      textDirection: textDirection,
      scrollPadding: scrollPadding,
      expands: expands,
      maxLengthEnforcement: maxLengthEnforcement,
      focusNode: focusNode,
      obscureText: obscure,
      obscuringCharacter: obscuringCharacter,
      autovalidateMode: autoValidateMode,
      readOnly: readOnly,
      scrollPhysics: scrollPhysics,
      scrollController: scrollController,
      autocorrect: false,
      cursorColor: Colors.deepOrange,
      initialValue: initialValue,
      keyboardAppearance: keyboardAppearance,
      textAlignVertical: textAlignVertical,
      textCapitalization: textCapitalization,
      toolbarOptions: toolbarOptions,
      inputFormatters: [
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        if (textInputType == TextInputType.phone || textInputType == TextInputType.number)
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ...?inputFormatters
      ],
      style:textStyle ??  TextStyle(
        fontSize: 16,
        color: const Color(0xff404040),
        decoration: TextDecoration.none,
        decorationColor: Colors.grey.shade400,
      ),
      decoration: InputDecoration(
        border: disableBorders ? InputBorder.none  : OutlineInputBorder(
          borderSide: BorderSide(color: bordersColor ?? Colors.grey.shade400,width: 0.4),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: disableBorders ? InputBorder.none  :OutlineInputBorder(
          borderSide: BorderSide(color: bordersColor ?? Colors.grey.shade400,width: 0.4),
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: disableBorders ? InputBorder.none  :OutlineInputBorder(
          borderSide: BorderSide(color: bordersColor ?? Colors.grey.shade400,width: 0.4),
          borderRadius: BorderRadius.circular(15),
        ),
        disabledBorder:  disableBorders ? InputBorder.none  :OutlineInputBorder(
          borderSide: BorderSide(color: bordersColor ?? Colors.grey.shade400,width: 0.4),
          borderRadius: BorderRadius.circular(15),
        ),
        errorBorder: disableBorders ? InputBorder.none  :OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 0.4),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedErrorBorder: disableBorders ? InputBorder.none  :OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 0.4),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: filledColor ?? Colors.white,
        contentPadding: contentPadding ?? EdgeInsetsDirectional.only(start: 20, end: 10,bottom: 12,top: 12),
        prefixIcon: prefixIcon,
        icon: icon,
        suffixIcon: suffixIcon,
        suffix: suffix,
        hintText: hintText,
        hintStyle: hintTextStyle ?? TextStyle(color: Colors.grey.shade300 , fontSize: 16),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade50 , fontSize: 14),
      ),
    );
  }
}
