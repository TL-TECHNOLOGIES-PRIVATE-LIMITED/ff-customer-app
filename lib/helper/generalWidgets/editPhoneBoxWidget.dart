import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:project/helper/utils/generalImports.dart';

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

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
      debugPrint("Updated Number: ${value.completeNumber}");
      onNumberChanged?.call(value.completeNumber);
    },
    onCountryChanged: (value) {
      debugPrint("Updated Country Code: ${value.code}");
      onCountryCodeChanged?.call(value.code);
    },
    textInputAction: optionalTextInputAction ??
        (isLastField == true ? TextInputAction.done : TextInputAction.next),
    autovalidateMode: AutovalidateMode.disabled,
    decoration: InputDecoration(
      errorStyle:
          TextStyle(color: ColorsRes.appColorRed), // Explicit error style
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
      floatingLabelBehavior:
          floatingLabelBehavior ?? FloatingLabelBehavior.auto,
    ),
    validator: (value) async {
      // if (validationFunction != null) {
      //   final result =
      //       await validationFunction(value); // Await the async function
      //   debugPrint("Validation Result: $result");
      //   return result; // Return the result after completion
      // }
      // return null;
      if (validationFunction == null) {
        print('here');
        return null;
      } else {
        return validationFunction(value);
      }
    },
  );
}
