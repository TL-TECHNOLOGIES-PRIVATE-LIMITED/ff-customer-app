import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/userProfile.dart' as userProf;

class OtpVerificationScreen extends StatefulWidget {
  final String otpVerificationId;
  final String phoneNumber;
  final FirebaseAuth firebaseAuth;
  final PhoneNumber selectedCountryCode;
  final String? from;

  const OtpVerificationScreen({
    Key? key,
    required this.otpVerificationId,
    required this.phoneNumber,
    required this.firebaseAuth,
    required this.selectedCountryCode,
    this.from,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<OtpVerificationScreen> {
  int otpLength = 6;
  bool isLoading = false;
  String resendOtpVerificationId = "";
  int? forceResendingToken;

  late PinTheme defaultPinTheme;

  late PinTheme focusedPinTheme;

  late PinTheme submittedPinTheme;

  /// Create Controller
  final pinController = TextEditingController();

  static const _duration = Duration(seconds: 45);
  Timer? _timer;
  Duration _remaining = _duration;

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

  @override
  void initState() {
    startTimer();
    // TODO REMOVE DEMO OTP FROM HERE
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('widget.from ---------> ${widget.from}');
    defaultPinTheme = PinTheme(
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
    return Scaffold(
      body: Stack(
        children: [
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            top: 25,
            child: Column(
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
                )
              ],
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: otpWidgets(),
          ),
        ],
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
        autofocus: true,
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
                isLoading = false;
              });
              if (Constant.firebaseAuthentication == "1") {
                verifyOtp();
              } else if (Constant.customSmsGatewayOtpBased == "1") {
                context.read<UserProfileProvider>().verifyUserProvider(
                  context: context,
                  params: {
                    ApiAndParams.phone: widget.phoneNumber,
                    ApiAndParams.countryCode:
                        widget.selectedCountryCode.countryCode.toString(),
                    ApiAndParams.otp: pinController.text,
                  },
                ).then(
                  (mainData) async {
                    if (mainData["status"].toString() == "1") {
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
                        Map<String, String> params = {
                          ApiAndParams.id: widget.phoneNumber,
                          ApiAndParams.type: "phone",
                          ApiAndParams.name: "",
                          ApiAndParams.email: "",
                          ApiAndParams.countryCode:
                              widget.selectedCountryCode.countryCode.toString(),
                          ApiAndParams.mobile: widget.phoneNumber,
                          ApiAndParams.type: "phone",
                          ApiAndParams.platform:
                              Platform.isAndroid ? "android" : "ios",
                          ApiAndParams.fcmToken: Constant.session
                              .getData(SessionManager.keyFCMToken),
                        };

                        Navigator.of(context).pushReplacementNamed(
                            editProfileScreen,
                            arguments: [widget.from ?? "register", params]);
                      }
                    } else {
                      Map<String, String> params = {
                        ApiAndParams.id: widget.phoneNumber,
                        ApiAndParams.type: "phone",
                        ApiAndParams.name: "",
                        ApiAndParams.email: "",
                        ApiAndParams.countryCode:
                            widget.selectedCountryCode.countryCode.toString(),
                        ApiAndParams.mobile: widget.phoneNumber,
                        ApiAndParams.type: "phone",
                        ApiAndParams.platform:
                            Platform.isAndroid ? "android" : "ios",
                        ApiAndParams.fcmToken: Constant.session
                            .getData(SessionManager.keyFCMToken),
                      };

                      Navigator.of(context).pushReplacementNamed(
                          editProfileScreen,
                          arguments: [widget.from ?? "register", params]);
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
              : widget.otpVerificationId,
          smsCode: pinController.text);

      widget.firebaseAuth.signInWithCredential(credential).then((value) {
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
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
          CustomTextLabel(
            text:
                "${widget.selectedCountryCode.countryCode}-${widget.phoneNumber}",
          ),
          const SizedBox(height: 60),
          otpPinWidget(),
          const SizedBox(height: 60),
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

  backendApiProcess(User? user) async {
    if (user != null) {
      Map<String, String> params = {
        ApiAndParams.id: widget.phoneNumber,
        ApiAndParams.type: "phone",
        ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
        ApiAndParams.fcmToken:
            Constant.session.getData(SessionManager.keyFCMToken),
      };

      await context
          .read<UserProfileProvider>()
          .loginApi(context: context, params: params)
          .then((value) async {
        if (value == "1") {
          if (widget.from == "add_to_cart_register") {
            addGuestCartBulkToCartWhileLogin(
              context: context,
              params: Constant.setGuestCartParams(
                cartList: context.read<CartListProvider>().cartList,
              ),
            ).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          } else if (Constant.session.getBoolData(SessionManager.isUserLogin)) {
            print('widget.from otp ------------------> ${widget.from}');
            context.read<HomeMainScreenProvider>().selectBottomMenu(0);
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
              print('widget.from otp ------------------> ${widget.from}');
              context.read<HomeMainScreenProvider>().selectBottomMenu(0);
              Navigator.of(context).pushNamedAndRemoveUntil(
                mainHomeScreen,
                (Route<dynamic> route) => false,
              );
            }
          }

          if (Constant.session.isUserLoggedIn()) {
            await context
                .read<CartProvider>()
                .getCartListProvider(context: context);
          } else {
            if (context.read<CartListProvider>().cartList.isNotEmpty) {
              await context
                  .read<CartProvider>()
                  .getGuestCartListProvider(context: context);
            }
          }
        } else {
          Map<String, String> params = {
            ApiAndParams.id: widget.phoneNumber,
            ApiAndParams.type: "phone",
            ApiAndParams.name: user.displayName ?? "",
            ApiAndParams.email: user.email ?? "",
            ApiAndParams.countryCode: widget.selectedCountryCode.countryCode
                    .replaceAll("+", "")
                    .toString() ??
                "",
            ApiAndParams.mobile: user.phoneNumber.toString().replaceAll(
                widget.selectedCountryCode.countryCode.toString(), ""),
            ApiAndParams.type: "phone",
            ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
            ApiAndParams.fcmToken:
                Constant.session.getData(SessionManager.keyFCMToken),
          };

          Navigator.of(context).pushReplacementNamed(editProfileScreen,
              arguments: [widget.from ?? "register", params]);
        }
      });
    }
  }

  Future checkOtpValidation() async {
    print('-----------------checkOtpValidation------------------------------');
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

  firebaseLoginProcess() async {
    print(
        '-----------------firebaseLoginProcess------------------------------');
    if (widget.phoneNumber.isNotEmpty) {
      // Reset the resending token to force a new OTP generation
      forceResendingToken = null;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber:
            '${widget.selectedCountryCode.countryCode}${widget.phoneNumber}', // Remove unnecessary dash
        verificationCompleted: (PhoneAuthCredential credential) {
          pinController.setText(credential.smsCode ?? "");
        },
        verificationFailed: (FirebaseAuthException e) {
          showMessage(context, e.message!, MessageType.warning);
          pinController.clear();
          if (mounted) {
            isLoading = false;
            setState(() {
              pinController.clear();
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          forceResendingToken = resendToken;
          if (mounted) {
            isLoading = false;
            setState(() {
              resendOtpVerificationId = verificationId;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            isLoading = false;
            setState(() {});
          }
        },
        forceResendingToken:
            forceResendingToken, // This remains null to always generate a new OTP
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}
