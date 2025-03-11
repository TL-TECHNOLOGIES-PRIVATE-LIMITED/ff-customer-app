import 'package:project/helper/utils/generalImports.dart';

Widget editPhoneBoxBoxWidget(
  BuildContext context,
  TextEditingController edtController,
  FutureOr<String?> Function(PhoneNumber?)? validationFunction,
  String label, {
  bool? isLastField,
  Function(String)? onCountryCodeChanged,
  Function(String)? onNumberChanged,
  String? countryCode,
  bool? isEditable = true,
  TextInputAction? optionalTextInputAction,
  int? minLines,
  int? maxLines,
  int? maxLength,
  FloatingLabelBehavior? floatingLabelBehavior,
  void Function()? onTap,
  bool? readOnly,
}) {
  return IntlPhoneField(
    controller: edtController,
    dropdownTextStyle: TextStyle(color: ColorsRes.mainTextColor),
    style: TextStyle(color: ColorsRes.mainTextColor),
    dropdownIcon: Icon(
      Icons.keyboard_arrow_down_rounded,
      color: ColorsRes.mainTextColor,
    ),
    dropdownIconPosition: IconPosition.trailing,
    readOnly: readOnly ?? false,
    flagsButtonMargin: EdgeInsets.only(left: 10),
    initialCountryCode: countryCode ?? "IN",
    onChanged: (value) {
      onNumberChanged?.call(value.completeNumber);
      onCountryCodeChanged?.call(value.countryISOCode);
    },
    onCountryChanged: (value) {
      onCountryCodeChanged?.call(value.code);
    },
    textInputAction: optionalTextInputAction ?? 
        (isLastField == true ? TextInputAction.done : TextInputAction.next),
    decoration: InputDecoration(
      hintStyle: TextStyle(color: Theme.of(context).hintColor),
      counterText: "",
      alignLabelWithHint: true,
      fillColor: Theme.of(context).cardColor,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: ColorsRes.subTitleMainTextColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: ColorsRes.appColorRed,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: ColorsRes.subTitleMainTextColor,
          width: 1,
        ),
      ),
      labelText: label,
      labelStyle: TextStyle(color: ColorsRes.subTitleMainTextColor),
      isDense: true,
      floatingLabelBehavior: floatingLabelBehavior ?? FloatingLabelBehavior.auto,
    ),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value) {
      if (validationFunction != null) {
        return validationFunction(value);
      }
      return null;
    },
  );
}
