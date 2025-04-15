import 'package:project/helper/utils/generalImports.dart';

Widget editBoxWidget(
  BuildContext context,
  TextEditingController edtController,
  Function validationFunction,
  String label,
  String errorLabel,
  TextInputType inputType, {
  TextCapitalization? textCapitalization,
  Widget? tailIcon,
  Widget? leadingIcon,
  bool? isLastField,
  bool? isEditable = true,
  List<TextInputFormatter>? inputFormatters,
  TextInputAction? optionalTextInputAction,
  int? minLines,
  int? maxLines,
  int? maxLength,
  FloatingLabelBehavior? floatingLabelBehavior,
  void Function()? onTap,
  bool? readOnly,
}) {
  return TextFormField(
    onTap: onTap ?? null,
    enabled: isEditable,
    textCapitalization: textCapitalization ?? TextCapitalization.none,
    readOnly: readOnly ?? false,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    style: TextStyle(
      color: ColorsRes.mainTextColor,
    ),
    maxLength: maxLength,
    buildCounter: (context,
            {required currentLength, required isFocused, required maxLength}) =>
        Container(),
    maxLines: maxLines,
    minLines: minLines,
    controller: edtController,
    textInputAction: optionalTextInputAction ??
        (isLastField == true ? TextInputAction.done : TextInputAction.next),
    decoration: InputDecoration(
      prefix: leadingIcon,
      suffixIcon: tailIcon,
      alignLabelWithHint: true,
      fillColor: Theme.of(context).cardColor,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
          style: BorderStyle.solid,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(
          color: ColorsRes.subTitleMainTextColor.withOpacity(0.5),
          width: 1,
          style: BorderStyle.solid,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(
          color: ColorsRes.appColorRed,
          width: 1,
          style: BorderStyle.solid,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(
          color: ColorsRes.subTitleMainTextColor,
          width: 1,
          style: BorderStyle.solid,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(
          color: ColorsRes.subTitleMainTextColor.withOpacity(0.5),
          width: 1,
          style: BorderStyle.solid,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      counterText: "",
      labelText: label,
      labelStyle: TextStyle(color: ColorsRes.subTitleMainTextColor),
      isDense: true,
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (Set<WidgetState> states) {
          final Color color = states.contains(WidgetState.error)
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).primaryColor;
          return TextStyle(color: color, letterSpacing: 1.3);
        },
      ),
      floatingLabelBehavior:
          floatingLabelBehavior ?? FloatingLabelBehavior.auto,
    ),
    keyboardType: inputType,
    inputFormatters: inputFormatters ?? [],
    validator: (String? value) {
      if (validationFunction(value ?? "") == null) {
        return null;
      } else {
        return validationFunction(value);
      }
    },
  );
}
