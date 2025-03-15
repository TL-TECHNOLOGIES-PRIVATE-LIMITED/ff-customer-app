import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/screens/authenticationScreen/widget/socialMediaLoginButtonWidget.dart';

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
  String phoneNumber = "";
  int? forceResendingToken;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ["profile", "email"]);

  AuthProviders? authProvider;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('widget.from------------------> ${widget.from}');
    return Scaffold(
      body: Stack(
        children: [
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            top: 25,
            // child: Image.asset(
            //   Constant.getAssetsPath(0, "bg.jpg"),
            //   fit: BoxFit.fill,
            // ),
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
          // PositionedDirectional(
          //   bottom: 0,
          //   start: 0,
          //   end: 0,
          //   top: 0,
          //   child: Image.asset(
          //     Constant.getAssetsPath(0, "bg_overlay.png"),
          //     fit: BoxFit.fill,
          //   ),
          // ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: loginWidgets(),
          ),
          if (isLoading && authProvider != AuthProviders.phone)
            PositionedDirectional(
              top: 0,
              end: 0,
              bottom: 0,
              start: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            top: 40,
            end: 10,
            child: skipLoginText(),
          ),
        ],
      ),
    );
  }

  Widget proceedBtn() {
    return (isLoading && authProvider == AuthProviders.phone)
        ? Container(
            height: 55,
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          )
        : gradientBtnWidget(context, 10,
            title: getTranslatedValue(
              context,
              "login",
            ).toUpperCase(), callback: () {
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
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
                        text: getTranslatedValue(context, "terms_of_service"),
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

        onChanged: (number) {
          print('number is ${number}');
          fullNumber = number;
        },
        initialCountryCode: Constant.initialCountryCode,
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

        // backgroundColor: Theme.of(context).cardColor,
        // textStyle: TextStyle(color: ColorsRes.mainTextColor),
        // dialogBackgroundColor: Theme.of(context).cardColor,
        // dialogSize: Size(context.width, context.height),
        // barrierColor: ColorsRes.subTitleMainTextColor,
        // padding: EdgeInsets.zero,

        // searchStyle: TextStyle(
        //   color: ColorsRes.subTitleMainTextColor,
        // ),
      ),
    );
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
  if (edtPhoneNumber.text.isNotEmpty) {

 List<dynamic> firebaseArguments = [
                firebaseAuth,
               // otpVerificationId,
                edtPhoneNumber.text,
                fullNumber!.countryCode,
                widget.from ?? null
              ];
              Navigator.pushNamed(context, otpScreen,
                  arguments: firebaseArguments);



    // Navigator.pushNamed(
    //   context,
    //   otpScreen,
    //   arguments: {
    //     'firebaseAuth': FirebaseAuth.instance,
    //    // 'otpVerificationId': verificationId, // Make sure this exists
    //     'phoneNumber': edtPhoneNumber.text,
    //     'selectedCountryCode': fullNumber!,
    //     'from': widget.from,
    //   },
    // );
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
  }

  backendApiProcess(User? user) async {
    if (user != null) {
      Map<String, String> params = {
        ApiAndParams.id: authProvider == AuthProviders.phone
            ? edtPhoneNumber.text
            : user.email.toString(),
        ApiAndParams.type: authProvider == AuthProviders.phone
            ? "phone"
            : authProvider == AuthProviders.google
                ? "google"
                : "apple",
        ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
        ApiAndParams.fcmToken:
            Constant.session.getData(SessionManager.keyFCMToken),
      };

      await context
          .read<UserProfileProvider>()
          .loginApi(context: context, params: params)
          .then(
        (value) async {
          if (value == "1") {
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
            setState(() {
              isLoading = false;
            });
            Constant.session.setData(SessionManager.keyUserImage,
                firebaseAuth.currentUser!.photoURL.toString(), false);

            Navigator.of(context).pushNamed(
              editProfileScreen,
              arguments: [
                widget.from ?? "register",
                {
                  ApiAndParams.id: authProvider == AuthProviders.phone
                      ? edtPhoneNumber.text
                      : user.email.toString(),
                  ApiAndParams.type: authProvider == AuthProviders.phone
                      ? "phone"
                      : authProvider == AuthProviders.google
                          ? "google"
                          : "apple",
                  ApiAndParams.name:
                      firebaseAuth.currentUser!.displayName ?? "",
                  ApiAndParams.email: firebaseAuth.currentUser!.email ?? "",
                  ApiAndParams.countryCode: "",
                  ApiAndParams.mobile:
                      firebaseAuth.currentUser!.phoneNumber ?? "",
                  ApiAndParams.platform: Platform.isAndroid ? "android" : "ios",
                  ApiAndParams.fcmToken:
                      Constant.session.getData(SessionManager.keyFCMToken),
                }
              ],
            );
          }
        },
      );
    }
  }
}
