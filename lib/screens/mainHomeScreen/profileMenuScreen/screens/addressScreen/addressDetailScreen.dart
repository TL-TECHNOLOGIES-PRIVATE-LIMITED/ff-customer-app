import 'package:project/helper/generalWidgets/editPhoneBoxWidget.dart';
import 'package:project/helper/utils/generalImports.dart';

class AddressDetailScreen extends StatefulWidget {
  final UserAddressData? address;
  final BuildContext addressProviderContext;
  final String? from;

  const AddressDetailScreen({
    Key? key,
    this.address,
    required this.addressProviderContext,
    this.from,
  }) : super(key: key);

  @override
  State<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

enum AddressType { home, office, other }

class _AddressDetailScreenState extends State<AddressDetailScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController edtName = TextEditingController();
  final TextEditingController edtMobile = TextEditingController();
  final TextEditingController edtAltMobile = TextEditingController();
  final TextEditingController edtAddress = TextEditingController();
  final TextEditingController edtLandmark = TextEditingController();
  final TextEditingController edtCity = TextEditingController();
  final TextEditingController edtArea = TextEditingController();
  final TextEditingController edtZipcode = TextEditingController();
  final TextEditingController edtCountry = TextEditingController();
  final TextEditingController edtState = TextEditingController();
  String? countryCode;
  String? alternateCountryCode;
  bool isLoading = false;
  bool isDefaultAddress = false;
  String longitude = "";
  String latitude = "";
  AddressType selectedAddressType = AddressType.home;
  String? numberMobile;
  String? numberAlternateMobile;

  //Address types
  static Map addressTypes = {};
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode phoneFocusNodenull = FocusNode();
  bool hasInteracted = false;
  @override
  void initState() {
    super.initState();

    phoneFocusNode.addListener(() {
      if (!phoneFocusNode.hasFocus) {
        setState(() {
          hasInteracted = true;
        });
      }
    });
    // Future.delayed(
    //   Duration.zero,
    //   () {
    addressTypes = {
      "home": getTranslatedValue(
        context,
        "address_type_home",
      ),
      "office": getTranslatedValue(
        context,
        "address_type_office",
      ),
      "other": getTranslatedValue(
        context,
        "address_type_other",
      ),
    };

    edtName.text = widget.address?.name ?? "";
    edtAltMobile.text = widget.address?.alternateMobile == null ||
            widget.address?.alternateMobile == "null"
        ? ""
        : widget.address!.alternateMobile.toString();
    edtMobile.text = widget.address?.mobile ?? "";
    edtAddress.text = widget.address?.address ?? "";
    edtLandmark.text = widget.address?.landmark ?? "";
    edtCity.text = widget.address?.city ?? "";
    edtArea.text = widget.address?.area ?? "";
    edtZipcode.text = widget.address?.pincode ?? "";
    edtCountry.text = widget.address?.country ?? "";
    edtState.text = widget.address?.state ?? "";
    isDefaultAddress = widget.address?.isDefault == "1";
    countryCode = widget.address?.countryCode;
    print('country code sjaksskj is ${countryCode}');
    alternateCountryCode = widget.address?.alternateCountryCode;
    numberMobile = widget.address?.mobile;
    numberAlternateMobile = widget.address?.alternateMobile;
    if (widget.address?.type?.toLowerCase() == "home") {
      selectedAddressType = AddressType.home;
    } else if (widget.address?.type?.toLowerCase() == "office") {
      selectedAddressType = AddressType.office;
    } else if (widget.address?.type?.toLowerCase() == "other") {
      selectedAddressType = AddressType.other;
    } else {
      selectedAddressType = AddressType.home;
    }
    longitude = widget.address?.longitude ?? "";
    latitude = widget.address?.latitude ?? "";

    setState(() {});
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    print('country code pppppp is ${countryCode}');
    return Scaffold(
        appBar: getAppBar(
          context: context,
          title: CustomTextLabel(
            jsonKey: "address_detail",
            style: TextStyle(color: ColorsRes.mainTextColor),
          ),
        ),
        body: Stack(
          children: [
            ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: Constant.size10, vertical: Constant.size10),
                children: [
                  Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          contactWidget(),
                          addressDetailWidget(),
                        ],
                      )),
                  addressTypeWidget()
                ]),
            isLoading == true
                ? PositionedDirectional(
                    top: 0,
                    end: 0,
                    start: 0,
                    bottom: 0,
                    child: Container(
                        color: Colors.black.withOpacity(0.2),
                        child:
                            const Center(child: CircularProgressIndicator())),
                  )
                : const SizedBox.shrink()
          ],
        ));
  }

  contactWidget() {
    return Container(
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsetsDirectional.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              jsonKey: "contact_details",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: ColorsRes.mainTextColor,
              ),
            ),
            getSizedBox(height: Constant.size10),
            editBoxWidget(
              context,
              edtName,
              validateName,
              getTranslatedValue(
                context,
                "name",
              ),
              getTranslatedValue(
                context,
                "enter_name",
              ),
              TextInputType.name,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editPhoneBoxBoxWidget(
              hasInteracted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              phoneFocusNode,
              context,
              edtMobile,
              optionalPhoneValidation,
              getTranslatedValue(
                context,
                "mobile_number",
              ),
              countryCode: countryCode,
              onCountryCodeChanged: (newCode) {
                // Update state when changed
                setState(() {
                  countryCode = newCode;
                });
              },
              onNumberChanged: (newNumber) {
                // Update state when changed
                setState(() {
                  numberMobile = newNumber;
                });
              },
            ),
            getSizedBox(height: Constant.size15),
            editPhoneBoxBoxWidget(
              AutovalidateMode.disabled,
              phoneFocusNodenull,
              context,
              edtAltMobile,
              optionalPhoneValidation,
              getTranslatedValue(
                context,
                "alternate_mobile_number",
              ),
              countryCode: alternateCountryCode,
              onCountryCodeChanged: (newCode) {
                // Update state when changed
                setState(() {
                  alternateCountryCode = newCode;
                });
              },
              onNumberChanged: (newNumber) {
                setState(() {
                  // Update state when changed
                  numberAlternateMobile = newNumber;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  addressDetailWidget() {
    return Container(
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsetsDirectional.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Constant.size10, vertical: Constant.size10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              jsonKey: "address_details",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: ColorsRes.mainTextColor,
              ),
            ),
            getSizedBox(height: Constant.size10),
            editBoxWidget(
                context,
                edtAddress,
                emptyValidation,
                getTranslatedValue(
                  context,
                  "address",
                ),
                getTranslatedValue(
                  context,
                  "please_select_address_from_map",
                ),
                TextInputType.text,
                maxLength: 191, onTap: () {
              Navigator.pushNamed(context, confirmLocationScreen,
                  arguments: [null, null, "address"]).then(
                (value) {
                  setState(
                    () {
                      edtAddress.text = Constant.cityAddressMap["address"];

                      edtCity.text = Constant.cityAddressMap["city"];

                      edtArea.text = Constant.cityAddressMap["area"];

                      edtLandmark.text = edtLandmark.text.toString().isNotEmpty
                          ? edtLandmark.text.toString()
                          : Constant.cityAddressMap["landmark"];

                      edtZipcode.text = edtZipcode.text.isNotEmpty
                          ? edtZipcode.text.toString()
                          : Constant.cityAddressMap["pin_code"];

                      edtCountry.text = Constant.cityAddressMap["country"]
                              .toString()
                              .isNotEmpty
                          ? Constant.cityAddressMap["country"]
                          : "";

                      edtState.text =
                          Constant.cityAddressMap["state"].toString().isNotEmpty
                              ? Constant.cityAddressMap["state"].toString()
                              : "";

                      longitude =
                          Constant.cityAddressMap["longitude"].toString();

                      latitude = Constant.cityAddressMap["latitude"].toString();
                    },
                  );
                  formKey.currentState?.validate();
                },
              );
            },
                readOnly: true,
                tailIcon: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, confirmLocationScreen,
                        arguments: [null, null, "address"]).then(
                      (value) {
                        setState(
                          () {
                            edtAddress.text =
                                Constant.cityAddressMap["address"];

                            edtCity.text = Constant.cityAddressMap["city"];

                            edtArea.text = Constant.cityAddressMap["area"];

                            edtLandmark.text =
                                edtLandmark.text.toString().isNotEmpty
                                    ? edtLandmark.text.toString()
                                    : Constant.cityAddressMap["landmark"];

                            edtZipcode.text = edtZipcode.text.isNotEmpty
                                ? edtZipcode.text.toString()
                                : Constant.cityAddressMap["pin_code"];

                            edtCountry.text = Constant.cityAddressMap["country"]
                                    .toString()
                                    .isNotEmpty
                                ? Constant.cityAddressMap["country"]
                                : "";

                            edtState.text = Constant.cityAddressMap["state"]
                                    .toString()
                                    .isNotEmpty
                                ? Constant.cityAddressMap["state"].toString()
                                : "";

                            longitude =
                                Constant.cityAddressMap["longitude"].toString();

                            latitude =
                                Constant.cityAddressMap["latitude"].toString();
                          },
                        );
                        formKey.currentState?.validate();
                      },
                    );
                  },
                  icon: Icon(
                    Icons.my_location_rounded,
                    color: ColorsRes.appColor,
                  ),
                )),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtLandmark,
              validateLandmark,
              getTranslatedValue(
                context,
                "landmark",
              ),
              getTranslatedValue(
                context,
                "enter_landmark",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtCity,
              validateCity,
              getTranslatedValue(
                context,
                "city",
              ),
              getTranslatedValue(
                context,
                "please_select_address_from_map",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtArea,
              validateArea,
              getTranslatedValue(
                context,
                "area",
              ),
              getTranslatedValue(
                context,
                "enter_area",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtZipcode,
              validatePincode,
              getTranslatedValue(
                context,
                "pin_code",
              ),
              getTranslatedValue(
                context,
                "enter_pin_code",
              ),
              TextInputType.number,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtState,
              validateState,
              getTranslatedValue(
                context,
                "state",
              ),
              isEditable: false,
              getTranslatedValue(
                context,
                "enter_state",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
            getSizedBox(height: Constant.size15),
            editBoxWidget(
              context,
              edtCountry,
              validateCountry,
              getTranslatedValue(
                context,
                "country",
              ),
              isEditable: false,
              getTranslatedValue(
                context,
                "enter_country",
              ),
              TextInputType.text,
              maxLength: 191,
            ),
          ],
        ),
      ),
    );
  }

  addressTypeWidget() {
    return Container(
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsetsDirectional.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constant.size10,
          vertical: Constant.size10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextLabel(
              jsonKey: "address_type",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: ColorsRes.mainTextColor,
              ),
            ),
            getSizedBox(height: Constant.size10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CustomRadio(
                        inactiveColor: ColorsRes.mainTextColor,
                        value: AddressType.home,
                        activeColor: ColorsRes.appColor,
                        groupValue: selectedAddressType,
                        onChanged: (AddressType? value) {
                          setState(() {
                            selectedAddressType = value ?? AddressType.home;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddressType = AddressType.home;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: CustomTextLabel(
                              text: addressTypes["home"],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CustomRadio(
                        inactiveColor: ColorsRes.mainTextColor,
                        value: AddressType.office,
                        groupValue: selectedAddressType,
                        activeColor: ColorsRes.appColor,
                        onChanged: (AddressType? value) {
                          setState(() {
                            selectedAddressType = value ?? AddressType.home;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddressType = AddressType.office;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: CustomTextLabel(
                              text: addressTypes["office"],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CustomRadio(
                        inactiveColor: ColorsRes.mainTextColor,
                        value: AddressType.other,
                        groupValue: selectedAddressType,
                        activeColor: ColorsRes.appColor,
                        onChanged: (AddressType? value) {
                          setState(() {
                            selectedAddressType = value ?? AddressType.home;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddressType = AddressType.other;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: CustomTextLabel(
                              text: addressTypes["other"],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            getSizedBox(height: Constant.size10),
            Row(
              children: [
                CustomCheckbox(
                  value: isDefaultAddress,
                  onChanged: (value) {
                    isDefaultAddress = !isDefaultAddress;
                    setState(
                      () {},
                    );
                  },
                ),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    isDefaultAddress = !isDefaultAddress;
                    setState(
                      () {},
                    );
                  },
                  child: CustomTextLabel(
                    jsonKey: "set_as_default_address",
                  ),
                ))
              ],
            ),
            getSizedBox(height: Constant.size10),
            gradientBtnWidget(
              context,
              8,
              title: (widget.address?.id.toString() ?? "").isNotEmpty
                  ? getTranslatedValue(
                      context,
                      "update",
                    )
                  : getTranslatedValue(
                      context,
                      "add_new_address",
                    ),
              callback: ()async {
  print('Country code is $countryCode');
  print('Alternate country code is $alternateCountryCode');
  print('Mobile number is $numberMobile');
  print('Alternate mobile number is $numberAlternateMobile');

  formKey.currentState!.save();

  if (formKey.currentState!.validate()) {
    if (longitude.isEmpty && latitude.isEmpty) {
      setState(() {
        isLoading = false;
      });
      showMessage(
        context,
        getTranslatedValue(context, "please_select_address_from_map"),
        MessageType.warning,
      );
    } else if (edtMobile.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      showMessage(
        context,
        getTranslatedValue(context, "mobile_number_cannot_be_empty"),
        MessageType.warning,
      );
    } else if (edtAltMobile.text.isNotEmpty) {
      // Ensure alternate mobile is not the same as the primary mobile
      if (numberMobile == numberAlternateMobile) {
        setState(() {
          isLoading = false;
        });
        showMessage(
          context,
          getTranslatedValue(context, "mobile_number_and_alternate_mobile_number_cannot_be_same"),
          MessageType.warning,
        );
        return;
      }

      // Ensure alternate country code matches the primary country code
      if (alternateCountryCode != countryCode) {
        setState(() {
          isLoading = false;
        });
        showMessage(
          context,
          getTranslatedValue(context, "alternate_mobile_must_have_same_country_code"),
          MessageType.warning,
        );
        return;
      }
    }

    print('Country code is $countryCode');
    print('Alternate country code is $alternateCountryCode');

    Map<String, String> params = {};
    String id = widget.address?.id.toString() ?? "";

    if (id.isNotEmpty) {
      params[ApiAndParams.id] = id;
    }

    params[ApiAndParams.countryCode] = countryCode ?? "IN";
    params[ApiAndParams.altCountryCode] = alternateCountryCode ?? "IN";
    params[ApiAndParams.name] = edtName.text.trim();
    params[ApiAndParams.mobile] = edtMobile.text.trim();

    if (selectedAddressType == AddressType.home) {
      params[ApiAndParams.type] = "home";
    } else if (selectedAddressType == AddressType.office) {
      params[ApiAndParams.type] = "office";
    } else if (selectedAddressType == AddressType.other) {
      params[ApiAndParams.type] = "other";
    } else {
      params[ApiAndParams.type] = "home";
    }

    params[ApiAndParams.address] = edtAddress.text.trim();
    params[ApiAndParams.landmark] = edtLandmark.text.trim();
    params[ApiAndParams.area] = edtArea.text.trim();
    params[ApiAndParams.pinCode] = edtZipcode.text.trim();
    params[ApiAndParams.city] = edtCity.text.trim();
    params[ApiAndParams.state] = edtState.text.trim();
    params[ApiAndParams.country] = edtCountry.text.trim();
    params[ApiAndParams.alternateMobile] = edtAltMobile.text.trim();
    params[ApiAndParams.latitude] = latitude;
    params[ApiAndParams.longitude] = longitude;
    params[ApiAndParams.isDefault] = isDefaultAddress == true ? "1" : "0";

    widget.addressProviderContext
        .read<AddressProvider>()
        .addOrUpdateAddress(
            context: context,
            address: widget.address ?? "",
            params: params,
            function: () {
              final addresses = widget.addressProviderContext
                  .read<AddressProvider>();

              if ((widget.address?.id.toString() ?? "").isEmpty &&
                  addresses.addresses.isNotEmpty) {
                print('New Address');
                if (widget.from == "checkout") {
                  addresses.setSelectedAddress(int.parse(
                      addresses.addresses.last.id.toString()));

                  print('kkkkkk here');
                  Navigator.pop(context, addresses.addresses.last);
                } else {
                  print('jjjjjj here');
                  Navigator.pop(context);
                }
              } else {
                print('hai its here');
                Navigator.pop(context);
              }
            });

    setState(() {
      isLoading = true;
    });
  } else {
    showMessage(context, "Please fill in all required fields!", MessageType.error);
  }
}


            ),
            getSizedBox(height: Constant.size10),
          ],
        ),
      ),
    );
  }
}
