import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/screens/authenticationScreen/widget/socialMediaLoginButtonWidget.dart';
import 'package:project/models/userProfile.dart' as userProf;

enum AuthProviders {
  phone,
  google,
  apple,
}

class LoginAccount extends StatefulWidget {
  final String? from;

  const LoginAccount({Key? key, this.from}) : super(key: key);

  @override
  State<LoginAccount> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccount> {
  PhoneNumber? fullNumber;
  bool isLoading = false;

  // TODO REMOVE DEMO NUMBER FROM HERE
  TextEditingController edtPhoneNumber = TextEditingController();
  bool isDark = Constant.session.getBoolData(SessionManager.isDarkTheme);
  String otpVerificationId = "";
  int? forceResendingToken;
  bool hasCodeSent = false;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["profile", "email"]);

  AuthProviders? authProvider;

  //otp data's start

  int otpLength = 6;
  // String? verificationId;
  String resendOtpVerificationId = "";

  PinTheme defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(
      fontSize: 20,
      color: ColorsRes.mainTextColor,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(
        color: ColorsRes.mainTextColor,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  late PinTheme focusedPinTheme;

  late PinTheme submittedPinTheme;

  /// Create Controller
  final pinController = TextEditingController();

  static const _duration = Duration(minutes: 1, seconds: 30);
  Timer? _timer;
  Duration _remaining = _duration;
  final FocusNode phoneFocusNode = FocusNode();
  bool hasInteracted = false;

  void startTimer() {
    _remaining = _duration;
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - Duration(seconds: 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  //otp data's end

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      try {
        await LocalAwesomeNotification().init(context);

        await FirebaseMessaging.instance.getToken().then((token) {
          Constant.session.setData(SessionManager.keyFCMToken, token!, false);
        });
      } catch (ignore) {}
    });
    phoneFocusNode.addListener(() {
      if (!phoneFocusNode.hasFocus) {
        setState(() {
          hasInteracted = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: ColorsRes.mainTextColor),
      borderRadius: BorderRadius.circular(10),
    );

    submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
    print('widget.from------------------> ${widget.from}');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          print('true');
        } else {
          if (hasCodeSent) {
            setState(() {
              hasCodeSent = false;
              pinController.clear();
              _timer?.cancel();
            });
          } else {
            print('widget.from------------------> ${widget.from}');
            if (widget.from == "header") {
              context.read<HomeMainScreenProvider>().currentPage = 3;

              Navigator.pop(context);
            } else {
              exitDialog(context);
            }
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  filterQuality: FilterQuality.high,
                  Constant.getAssetsPath(0, "logo.png"),
                  height: 200,
                ),
                CustomTextLabel(
                  text: "Bite into Premium",
                  style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.75,
                  ),
                ),SizedBox(height: 40,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: hasCodeSent ? otpWidgets() : loginWidgets(),
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              top: 40,
              end: 10,
              child: skipLoginText(),
            ),
          ],
        ),
      ),
    );
  }

  Widget proceedBtn() {
    return isLoading
        ? Container(
            height: 45,
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          )
        : gradientBtnWidget(context, 10,
            title: getTranslatedValue(
              context,
              "send_otp",
            ), callback: () {
            loginWithPhoneNumber();
          });
  }

  Widget skipLoginText() {
    return GestureDetector(
      onTap: () async {
        if (isLoading == false) {
          Constant.session
              .setBoolData(SessionManager.keySkipLogin, true, false);
          await getRedirection();
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).cardColor,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: CustomTextLabel(
          jsonKey: "skip_login",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isLoading == false
                    ? ColorsRes.mainTextColor
                    : ColorsRes.grey,
              ),
        ),
      ),
    );
  }

  Widget loginWidgets() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:BorderRadius.circular(30)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          getSizedBox(height: Constant.size20),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 20, end: 20),
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: Theme.of(context).textTheme.titleSmall!.merge(
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 30,
                        color: ColorsRes.mainTextColor,
                      ),
                    ),
                text: "${getTranslatedValue(
                  context,
                  "welcome",
                )} ",
                children: <TextSpan>[
                  TextSpan(
                    text: "\n${getTranslatedValue(context, "app_name")}!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (Constant.authTypePhoneLogin == "1") ...[
            getSizedBox(
              height: Constant.size30,
            ),
            Container(
              margin: EdgeInsetsDirectional.only(start: 20, end: 20),
              decoration: DesignConfig.boxDecoration(
                  Theme.of(context).scaffoldBackgroundColor, 10),
              child: mobileNoWidget(),
            ),
            getSizedBox(
              height: Constant.size20,
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 20, end: 20),
              child: proceedBtn(),
            ),
            if (Platform.isIOS && Constant.authTypeAppleLogin == "1" ||
                Constant.authTypeGoogleLogin == "1") ...[
              getSizedBox(
                height: Constant.size20,
              ),
              buildDottedDivider(),
              getSizedBox(
                height: Constant.size20,
              ),
            ]
          ],
          if (Platform.isIOS && Constant.authTypeAppleLogin == "1") ...[
            Padding(
              padding: EdgeInsetsDirectional.only(start: 20, end: 20),
              child: SocialMediaLoginButtonWidget(
                text: "continue_with_apple",
                logo: "apple_logo",
                logoColor: ColorsRes.mainTextColor,
                onPressed: () async {
                  authProvider = AuthProviders.apple;
                  await signInWithApple(
                    context: context,
                    firebaseAuth: firebaseAuth,
                    googleSignIn: googleSignIn,
                  ).then(
                    (value) {
                      setState(() {
                        isLoading = true;
                      });
                      if (value is UserCredential) {
                        setState(() {
                          isLoading = false;
                        });
                        backendApiProcess(value.user);
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        showMessage(
                            context, value.toString(), MessageType.error);
                      }
                    },
                  );
                },
              ),
            ),
            getSizedBox(height: 10),
          ],
          if (Constant.authTypeGoogleLogin == "1")
            Padding(
              padding: EdgeInsetsDirectional.only(start: 20, end: 20),
              child: SocialMediaLoginButtonWidget(
                text: "continue_with_google",
                logo: "google_logo",
                onPressed: () async {
                  authProvider = AuthProviders.google;
                  await signInWithGoogle(
                    context: context,
                    firebaseAuth: firebaseAuth,
                    googleSignIn: googleSignIn,
                  ).then(
                    (value) {
                      if (value is UserCredential) {
                        backendApiProcess(value.user);
                      } else {
                        showMessage(
                            context, value.toString(), MessageType.error);
                      }
                    },
                  );
                },
              ),
            ),
          getSizedBox(
            height: Constant.size20,
          ),
          Divider(color: ColorsRes.subTitleMainTextColor),
          getSizedBox(
            height: Constant.size20,
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 30, end: 30),
            child: Center(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleSmall!.merge(
                        TextStyle(
                          fontWeight: FontWeight.w400,
                          color: ColorsRes.subTitleMainTextColor,
                        ),
                      ),
                  text: "${getTranslatedValue(
                    context,
                    "agreement_message_1",
                  )}\t",
                  children: <TextSpan>[
                    TextSpan(
                        text: getTranslatedValue(context, "terms_and_conditions"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, webViewScreen,
                                arguments: getTranslatedValue(
                                  context,
                                  "terms_and_conditions",
                                ));
                          }),
                    TextSpan(
                        text: "\t${getTranslatedValue(
                          context,
                          "and",
                        )}\t",
                        style: TextStyle(
                          color: ColorsRes.subTitleMainTextColor,
                        )),
                    TextSpan(
                      text: getTranslatedValue(context, "privacy_policy"),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(
                            context,
                            webViewScreen,
                            arguments: getTranslatedValue(
                              context,
                              "privacy_policy",
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          getSizedBox(
            height: Constant.size20,
          ),
        ],
      ),
    );
  }

  mobileNoWidget() {
    return IgnorePointer(
      ignoring: isLoading,
      child: IntlPhoneField(
        controller: edtPhoneNumber,
        focusNode: phoneFocusNode,
        autovalidateMode: hasInteracted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        onChanged: (number) {
          print('number is ${number}');
          fullNumber = number;
        },
        initialCountryCode:
            fullNumber?.countryISOCode ?? Constant.initialCountryCode,
        dropdownTextStyle: TextStyle(color: ColorsRes.mainTextColor),
        style: TextStyle(color: ColorsRes.mainTextColor),
        dropdownIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: ColorsRes.mainTextColor,
        ),
        dropdownIconPosition: IconPosition.trailing,
        flagsButtonMargin: EdgeInsets.only(left: 10),
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Mobile Number',
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
          contentPadding: EdgeInsets.zero,
          iconColor: ColorsRes.subTitleMainTextColor,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ColorsRes.subTitleMainTextColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ColorsRes.subTitleMainTextColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ColorsRes.subTitleMainTextColor),
          ),
          focusColor: Theme.of(context).scaffoldBackgroundColor,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: ColorsRes.subTitleMainTextColor,
          ),
        ),
      ),
    );
  }

  Widget otpPinWidget() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        autofillHints: const [AutofillHints.oneTimeCode],
        controller: pinController,
        length: 6,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        hapticFeedbackType: HapticFeedbackType.heavyImpact,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          FilteringTextInputFormatter.singleLineFormatter
        ],
        closeKeyboardWhenCompleted: true,
        pinAnimationType: PinAnimationType.slide,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        animationCurve: Curves.bounceInOut,
        enableSuggestions: true,
        pinContentAlignment: AlignmentDirectional.center,
        isCursorAnimationEnabled: true,
        onCompleted: (value) async {
          await checkOtpValidation().then((msg) {
            if (msg != "") {
              setState(() {
                isLoading = false;
              });
              showMessage(context, msg, MessageType.warning);
            } else {
              setState(() {
                isLoading = true;
              });
              if (Constant.firebaseAuthentication == "1") {
                print(
                    '--------------------verifyOtp()----on pinput------------------------');
                verifyOtp();
              } else if (Constant.customSmsGatewayOtpBased == "1") {
                context.read<UserProfileProvider>().verifyUserProvider(
                  context: context,
                  params: {
                    ApiAndParams.phone: edtPhoneNumber.text,
                    ApiAndParams.countryCode:
                        fullNumber!.countryISOCode.toString(),
                    ApiAndParams.otp: pinController.text,
                  },
                ).then(
                  (mainData) async {
                    if (mainData["status"].toString() == "1") {
                      setState(() {
                        isLoading = false;
                      });
                      if (mainData.containsKey(ApiAndParams.data)) {
                        userProf.UserProfile? userProfile;

                        userProfile = userProf.UserProfile.fromJson(mainData);
                        if (userProfile.status == "1") {
                          await context
                              .read<UserProfileProvider>()
                              .setUserDataInSession(mainData, context);
                        }

                        if (widget.from == "add_to_cart_register") {
                          print('add to cart');
                          addGuestCartBulkToCartWhileLogin(
                            context: context,
                            params: Constant.setGuestCartParams(
                              cartList:
                                  context.read<CartListProvider>().cartList,
                            ),
                          ).then((value) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        } else if (Constant.session
                            .getBoolData(SessionManager.isUserLogin)) {
                          print('not add to cart');
                          if (context
                              .read<CartListProvider>()
                              .cartList
                              .isNotEmpty) {
                            addGuestCartBulkToCartWhileLogin(
                              context: context,
                              params: Constant.setGuestCartParams(
                                cartList:
                                    context.read<CartListProvider>().cartList,
                              ),
                            ).then(
                              (value) =>
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                mainHomeScreen,
                                (Route<dynamic> route) => false,
                              ),
                            );
                          } else {
                            print('not add to cart');
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              mainHomeScreen,
                              (Route<dynamic> route) => false,
                            );
                          }
                        }
                      } else {
                        print(
                            '================editProfileScreen==================in else===========1=========');

                        Map<String, String> params = {
                          ApiAndParams.id: edtPhoneNumber.text,
                          ApiAndParams.type: "phone",
                          ApiAndParams.name: "",
                          ApiAndParams.email: "",
                          ApiAndParams.countryCode:
                              fullNumber!.countryISOCode.toString(),
                          ApiAndParams.mobile: edtPhoneNumber.text,
                          ApiAndParams.type: "phone",
                          ApiAndParams.platform:
                              Platform.isAndroid ? "android" : "ios",
                          ApiAndParams.fcmToken: Constant.session
                              .getData(SessionManager.keyFCMToken),
                        };

                        Navigator.of(context).pushReplacementNamed(
                            editProfileScreen,
                            arguments: ["register", params]);
                      }
                    } else {
                      print(
                          '================editProfileScreen==================in else===========2=========');

                      Map<String, String> params = {
                        ApiAndParams.id: edtPhoneNumber.text,
                        ApiAndParams.type: "phone",
                        ApiAndParams.name: "",
                        ApiAndParams.email: "",
                        ApiAndParams.countryCode:
                            fullNumber!.countryISOCode.toString(),
                        ApiAndParams.mobile: edtPhoneNumber.text,
                        ApiAndParams.type: "phone",
                        ApiAndParams.platform:
                            Platform.isAndroid ? "android" : "ios",
                        ApiAndParams.fcmToken: Constant.session
                            .getData(SessionManager.keyFCMToken),
                      };

                      Navigator.of(context).pushReplacementNamed(
                          editProfileScreen,
                          arguments: ["register", params]);
                    }
                  },
                );
              }
            }
          });
        },
      ),
    );
  }

  Widget resendOtpWidget() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.titleSmall!.merge(
                TextStyle(
                  fontWeight: FontWeight.w400,
                  color: ColorsRes.mainTextColor,
                ),
              ),
          text: (_timer != null && _timer!.isActive)
              ? "${getTranslatedValue(
                  context,
                  "resend_otp_in",
                )} "
              : "",
          children: <TextSpan>[
            TextSpan(
                text: _timer != null && _timer!.isActive
                    ? '${_remaining.inMinutes.toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}'
                    : getTranslatedValue(
                        context,
                        "resend_otp",
                      ),
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  verifyOtp() async {
    setState(() {
      isLoading = true;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: resendOtpVerificationId.isNotEmpty
              ? resendOtpVerificationId
              : otpVerificationId,
          smsCode: pinController.text);

      firebaseAuth.signInWithCredential(credential).then((value) {
        User? user = value.user;
        backendApiProcess(user);
      }).catchError((e) {
        showMessage(
          context,
          getTranslatedValue(
            context,
            "enter_valid_otp",
          ),
          MessageType.warning,
        );
        setState(() {
          isLoading = false;
          pinController.clear();
        });
      });
    });
  }

  otpWidgets() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30)
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 20, end: 20, top: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomTextLabel(
            jsonKey: "enter_verification_code",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 30,
              color: ColorsRes.mainTextColor,
            ),
          ),
          CustomTextLabel(
            jsonKey: "otp_send_message",
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isLoading
                    ? null
                    : setState(() {
                        hasCodeSent = false;
                        pinController.clear();
                        _timer?.cancel();
                      });
              });
            },
            child: Row(
              children: [
                CustomTextLabel(
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  text:
                      "${fullNumber!.countryCode.toString()}-${edtPhoneNumber.text}",
                ),
                const SizedBox(width: 10),
                defaultImg(
                    image: "edit_icon",
                    height: 16,
                    iconColor: Theme.of(context).primaryColor),
              ],
            ),
          ),
          // ... other widgets
          const SizedBox(height: 60),
          isLoading
              ? Center(child: CircularProgressIndicator()) // Fixed this line
              : otpPinWidget(),
          const SizedBox(height: 60),
          if (!isLoading)
            GestureDetector(
              onTap: _timer != null && _timer!.isActive
                  ? null
                  : () {
                      setState(() {
                        startTimer();
                      });
                      firebaseLoginProcess();
                    },
              child: resendOtpWidget(),
            ),
          const SizedBox(height: 60),
        ]),
      ),
    );
  }

  Future checkOtpValidation() async {
    bool checkInternet = await checkInternetConnection();
    String? msg;
    if (checkInternet) {
      if (pinController.text.length == 1) {
        msg = getTranslatedValue(
          context,
          "enter_otp",
        );
      } else if (pinController.text.length < otpLength) {
        msg = getTranslatedValue(
          context,
          "enter_valid_otp",
        );
      } else {
        if (isLoading) return;
        setState(() {
          isLoading = true;
        });
        msg = "";
      }
    } else {
      msg = getTranslatedValue(
        context,
        "check_internet",
      );
    }
    return msg;
  }

  getRedirection() async {
    if (Constant.session.getBoolData(SessionManager.keySkipLogin) ||
        Constant.session.getBoolData(SessionManager.isUserLogin)) {
      Navigator.pushReplacementNamed(
        context,
        mainHomeScreen,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        mainHomeScreen,
        (route) => false,
      );
    }
  }

  Future<bool> mobileNumberValidation() async {
    bool checkInternet = await checkInternetConnection();
    String? mobileValidate = await phoneValidation(
      edtPhoneNumber.text,
    );
    if (!checkInternet) {
      showMessage(
        context,
        getTranslatedValue(
          context,
          "check_internet",
        ),
        MessageType.warning,
      );
      return false;
    } else if (mobileValidate == "") {
      showMessage(
        context,
        getTranslatedValue(
          context,
          "enter_valid_mobile",
        ),
        MessageType.warning,
      );
      return false;
    } else if (edtPhoneNumber.text.length > 15) {
      showMessage(
        context,
        getTranslatedValue(
          context,
          "enter_valid_mobile",
        ),
        MessageType.warning,
      );
      return false;
    } else {
      return true;
    }
  }

  loginWithPhoneNumber() async {
    print('--------------------loginWithPhoneNumber-----------------------');
    var validation = await mobileNumberValidation();
    if (validation) {
      if (isLoading) return;
      setState(() {
        isLoading = true;
      });
      firebaseLoginProcess();
    }
  }

  String getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-verification-code':
        return 'The verification code is incorrect. Please try again.';
      case 'invalid-phone-number':
        return 'The phone number is invalid. Please check and try again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'session-expired':
        return 'The verification session has expired. Please request a new code.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  firebaseLoginProcess() async {
    authProvider == AuthProviders.phone;
    setState(() {});
    if (edtPhoneNumber.text.isNotEmpty) {
      if (Constant.firebaseAuthentication == "1") {
        await firebaseAuth.verifyPhoneNumber(
          timeout: Duration(minutes: 1, seconds: 30),
          phoneNumber: fullNumber!.completeNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            pinController.setText(credential.smsCode ?? "");
            print(
                '------------------------init------------${pinController.text}-------------SUCCESS-------------textpincontroller--------------');
          },
          verificationFailed: (FirebaseAuthException e) {
            print('Message is ------------' + e.code);
            String errorMessage = getFriendlyErrorMessage(e.code);

            showMessage(
              context,
              errorMessage,
              MessageType.warning,
            );

            setState(() {
              isLoading = false;
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            forceResendingToken = resendToken;
            isLoading = false;
            setState(() {
              otpVerificationId = verificationId;

              // List<dynamic> firebaseArguments = [
              //   firebaseAuth,
              //   otpVerificationId,
              //   edtPhoneNumber.text,
              //   fullNumber,
              //   widget.from ?? null
              // ];
              // Navigator.pushNamed(context, otpScreen,
              //     arguments: firebaseArguments);
              hasCodeSent = true;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
          forceResendingToken: forceResendingToken,
        );
      } else if (Constant.customSmsGatewayOtpBased == "1") {
        context.read<UserProfileProvider>().sendCustomOTPSmsProvider(
          context: context,
          params: {ApiAndParams.phone: fullNumber!.completeNumber},
        ).then(
          (value) {
            if (value == "1") {
              // List<dynamic> firebaseArguments = [
              //   firebaseAuth,
              //   otpVerificationId,
              //   edtPhoneNumber.text,
              //   fullNumber!.countryCode,
              //   widget.from ?? null
              // ];
              // Navigator.pushNamed(context, otpScreen,
              //     arguments: firebaseArguments);
              hasCodeSent = true;
            } else {
              setState(() {
                isLoading = false;
              });
              showMessage(
                context,
                getTranslatedValue(
                  context,
                  "custom_send_sms_error_message",
                ),
                MessageType.warning,
              );
            }
          },
        );
      }
    }
  }

  Widget buildDottedDivider() {
    return Row(
      children: [
        getSizedBox(
          width: Constant.size20,
        ),
        Expanded(
          child: DashedDivider(height: 1),
        ),
        CircleAvatar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          radius: 15,
          child: CustomTextLabel(
            jsonKey: "or_",
            style:
                TextStyle(color: ColorsRes.subTitleMainTextColor, fontSize: 12),
          ),
        ),
        Expanded(
          child: DashedDivider(height: 1),
        ),
        getSizedBox(
          width: Constant.size20,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  backendApiProcess(User? user) async {
    if (user != null) {
      // Map<String, String> params = {
      //   ApiAndParams.id: authProvider == AuthProviders.phone
      //       ? edtPhoneNumber.text
      //       : user.email.toString(),
      //   ApiAndParams.type: authProvider == AuthProviders.phone
      //       ? "phone"
      //       : authProvider == AuthProviders.google
      //           ? "google"
      //           : "apple",
      //   ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
      //   ApiAndParams.fcmToken:
      //       Constant.session.getData(SessionManager.keyFCMToken),
      // };

      Map<String, String> params = {
        ApiAndParams.id: edtPhoneNumber.text,
        ApiAndParams.type: "phone",
        ApiAndParams.name: "",
        ApiAndParams.email: "",
        ApiAndParams.countryCode: fullNumber!.countryISOCode.toString(),
        ApiAndParams.mobile: edtPhoneNumber.text,
        ApiAndParams.type: "phone",
        ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
        ApiAndParams.fcmToken:
            Constant.session.getData(SessionManager.keyFCMToken),
      };

      await context
          .read<UserProfileProvider>()
          .loginApi(context: context, params: params)
          .then(
        (value) async {
          context.read<HomeMainScreenProvider>().currentPage = 0;
          print('value is $value------------------------------------');
          if (value == "1") {
            print('it gone to if ============================');
            if (widget.from == "add_to_cart") {
              addGuestCartBulkToCartWhileLogin(
                context: context,
                params: Constant.setGuestCartParams(
                  cartList: context.read<CartListProvider>().cartList,
                ),
              ).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
              });
            } else if (Constant.session
                .getBoolData(SessionManager.isUserLogin)) {
              if (context.read<CartListProvider>().cartList.isNotEmpty) {
                addGuestCartBulkToCartWhileLogin(
                  context: context,
                  params: Constant.setGuestCartParams(
                    cartList: context.read<CartListProvider>().cartList,
                  ),
                ).then(
                  (value) => Navigator.of(context).pushNamedAndRemoveUntil(
                    mainHomeScreen,
                    (Route<dynamic> route) => false,
                  ),
                );
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  mainHomeScreen,
                  (Route<dynamic> route) => false,
                );
              }
            }
          } else {
            print(
                '================editProfileScreen==================in else===========3=========');
            setState(() {
              isLoading = false;
            });
            Constant.session.setData(SessionManager.keyUserImage,
                firebaseAuth.currentUser!.photoURL.toString(), false);

            print(
                'phone number is ====================> ${edtPhoneNumber.text}');

            Map<String, String> params = {
              ApiAndParams.id: edtPhoneNumber.text,
              ApiAndParams.type: "phone",
              ApiAndParams.name: "",
              ApiAndParams.email: "",
              ApiAndParams.countryCode: fullNumber!.countryISOCode.toString(),
              ApiAndParams.mobile: edtPhoneNumber.text,
              ApiAndParams.type: "phone",
              ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
              ApiAndParams.fcmToken:
                  Constant.session.getData(SessionManager.keyFCMToken),
            };

            Navigator.of(context).pushNamed(
              editProfileScreen,
              arguments: [
                "register",
                // {
                //   ApiAndParams.id: authProvider == AuthProviders.phone
                //       ? edtPhoneNumber.text
                //       : user.email.toString(),
                //   ApiAndParams.type: authProvider == AuthProviders.phone
                //       ? "phone"
                //       : authProvider == AuthProviders.google
                //           ? "google"
                //           : "apple",
                //   ApiAndParams.name:
                //       firebaseAuth.currentUser!.displayName ?? "",
                //   ApiAndParams.email: firebaseAuth.currentUser!.email ?? "",
                //   ApiAndParams.countryCode: fullNumber!.countryCode.toString(),
                //   ApiAndParams.mobile: edtPhoneNumber.text,
                //   ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
                //   ApiAndParams.fcmToken:
                //       Constant.session.getData(SessionManager.keyFCMToken),
                // }
                params
              ],
            );
            hasCodeSent = false;
            pinController.clear();
            _timer?.cancel();
          }
        },
      );
    }
  }
}
