import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/userProfile.dart';

enum ProfileState { initial, loading, loaded }

class UserProfileProvider extends ChangeNotifier {
  ProfileState profileState = ProfileState.initial;

  Future updateUserProfile(
      {required BuildContext context,
      required String selectedImagePath,
      required Map<String, String> params}) async {
    print('-------------------updateUserProfile-------------------------');
    var returnValue;
    try {
      profileState = ProfileState.loading;
      notifyListeners();

      List<String> fileParamsNames = [];
      List<String> fileParamsFilesPath = [];
      print(
          '--------------------${fileParamsFilesPath}-----------------------');
      print(
          '--------image path------------${selectedImagePath}-----------------------');
      if (selectedImagePath.isNotEmpty) {
        fileParamsNames.add(ApiAndParams.profile);
        fileParamsFilesPath.add(selectedImagePath);

        print('--------------------$fileParamsNames--------------------------');
        print(
            '--------------------${fileParamsFilesPath}-----------------------');

        print('--------------$params------------------');
      }

      await getUpdateProfileApi(
              apiName: ApiAndParams.apiUpdateProfile,
              params: params,
              fileParamsNames: fileParamsNames,
              fileParamsFilesPath: fileParamsFilesPath,
              context: context)
          .then(
        (value) async {
          if (value != {}) {
            if (value.isNotEmpty) {
              if (value[ApiAndParams.status].toString() == "1") {
                await getUserDetail(context: context).then(
                  (value) {
                    if (value[ApiAndParams.status].toString() == "1") {
                      context
                          .read<UserProfileProvider>()
                          .updateUserDataInSession(value, context);
                    }
                  },
                ).then(
                  (value) {
                    returnValue = true;
                  },
                );
              } else {
                showMessage(
                  context,
                  value[ApiAndParams.message],
                  MessageType.warning,
                );
                profileState = ProfileState.loaded;
                notifyListeners();

                returnValue = value[ApiAndParams.message];
              }
            }
          } else {
            showMessage(
              context,
              value[ApiAndParams.message],
              MessageType.warning,
            );
            profileState = ProfileState.loaded;
            notifyListeners();

            returnValue = value;
          }
        },
      );
    } catch (e) {
      showMessage(context, e.toString(), MessageType.warning);
      profileState = ProfileState.loaded;
      notifyListeners();
      returnValue = "";
    }
    return returnValue;
  }

  Future loginApi(
      {required BuildContext context,
      required Map<String, String> params}) async {
    try {
      print('-------------------loginApi-----2----$params----------------');
      UserProfile? userProfile;
      await getLoginApi(context: context, params: params)
          .then((mainData) async {
        userProfile = UserProfile.fromJson(mainData);
        if (userProfile?.status == "1") {
          await setUserDataInSession(mainData, context);
        }
      });
      print(
          '-------------------${userProfile?.status}-------------------------');
      return userProfile!.data?.user?.status ?? "0";
    } catch (e) {
      return "0";
    }
  }

  Future sendCustomOTPSmsProvider(
      {required BuildContext context,
      required Map<String, String> params}) async {
    try {
      Map<String, dynamic> data =
          await sendCustomOTPSmsApi(context: context, params: params);

      return data[ApiAndParams.status].toString();
    } catch (e) {
      return "0";
    }
  }

  Future verifyUserProvider(
      {required BuildContext context,
      required Map<String, String> params}) async {
    try {
      Map<String, dynamic> data =
          await getUserVerifyApi(context: context, params: params);

      return data;
    } catch (e) {
      return "0";
    }
  }

  Future registerAccountApi(
      {required BuildContext context,
      required Map<String, String> params}) async {
    try {
      UserProfile? userProfile;
      await getRegisterApi(context: context, params: params)
          .then((mainData) async {
        userProfile = UserProfile.fromJson(mainData);
        if (userProfile?.status == "1") {
          await setUserDataInSession(mainData, context);
        } else {
          showMessage(
            context,
            mainData[ApiAndParams.message],
            MessageType.warning,
          );
        }
      });
      return userProfile!.data?.user?.status ?? "0";
    } catch (e) {
      return "0";
    }
  }

  Future setUserDataInSession(
      Map<String, dynamic> mainData, BuildContext context) async {
    Map<String, dynamic> data =
        await mainData[ApiAndParams.data] as Map<String, dynamic>;
    Map<String, dynamic> userData =
        await data[ApiAndParams.user] as Map<String, dynamic>;

    Constant.session.setBoolData(SessionManager.isUserLogin, true, false);

    Constant.session.setUserData(
      context: context,
      name: userData[ApiAndParams.name],
      email: userData[ApiAndParams.email],
      profile: userData[ApiAndParams.profile].toString(),
      countryCode: userData[ApiAndParams.countryCode],
      mobile: userData[ApiAndParams.mobile].toString().isNotEmpty
          ? userData[ApiAndParams.mobile]
          : Constant.session.getData(SessionManager.keyPhone),
      referralCode: userData[ApiAndParams.referralCode],
      status: int.parse(userData[ApiAndParams.status].toString()),
      token: data[ApiAndParams.accessToken],
      balance: userData[ApiAndParams.balance].toString(),
      type: userData[ApiAndParams.type].toString(),
    );
    profileState = ProfileState.loaded;
    notifyListeners();
  }

  Future updateUserDataInSession(
      Map<String, dynamic> mainData, BuildContext context) async {
    Map<String, dynamic> userData =
        await mainData[ApiAndParams.user] as Map<String, dynamic>;

    Constant.session.setUserData(
      context: context,
      name: userData[ApiAndParams.name],
      email: userData[ApiAndParams.email],
      profile: userData[ApiAndParams.profile].toString(),
      countryCode: userData[ApiAndParams.countryCode],
      mobile: userData[ApiAndParams.mobile],
      referralCode: userData[ApiAndParams.referralCode],
      status: int.parse(userData[ApiAndParams.status].toString()),
      token: Constant.session.getData(SessionManager.keyToken),
      balance: userData[ApiAndParams.balance].toString(),
      type: Constant.session.getData(SessionManager.keyLoginType),
    );

    profileState = ProfileState.loaded;
    notifyListeners();
  }

  getUserDetailBySessionKey({required bool isBool, required String key}) {
    return isBool == true
        ? Constant.session.getBoolData(key)
        : Constant.session.getData(key);
  }

  changeState() {
    profileState = ProfileState.initial;
    notifyListeners();
  }
}
