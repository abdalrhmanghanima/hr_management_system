import 'package:shared_preferences/shared_preferences.dart';

import '../../injection.dart';



class Preferences {
  bool isDarkMode() {
    SharedPreferences sharedPreferences = getIt();
    bool? isDarkMode = sharedPreferences.getBool('isDarkMode');
    return isDarkMode ?? true;
  }

  void saveFirebaseToken(String? token) {
    SharedPreferences sharedPreferences = getIt();
    sharedPreferences.setString('firebaseToken', token??'');
  }

  String? getFirebaseToken() {
    SharedPreferences sharedPreferences = getIt();
    return sharedPreferences.getString('firebaseToken');
  }

 /* void saveUserData(UserModel userModel) {
    SharedPreferences sharedPreferences = getIt();
    String encodeString = jsonEncode(userModel.toJson());
    sharedPreferences.setString('user', encodeString);
  }

  UserModel? getUserData() {
    SharedPreferences sharedPreferences = getIt();
    if (sharedPreferences.containsKey('user') &&
        sharedPreferences.getString('user') != null) {
      UserModel userModel =
          UserModel.fromJson(jsonDecode(sharedPreferences.getString('user')!));
      return userModel;
    }
    return null;
  }*/
  void logout() async{
    SharedPreferences sharedPreferences = getIt();
    await sharedPreferences.remove('user');
    await sharedPreferences.remove('firebaseToken');
    await sharedPreferences.remove('chatNotificationData');


  }


  void saveIsDarkMode(bool isDarkMode) async {
    SharedPreferences sharedPreferences = getIt();
    await sharedPreferences.setBool('isDarkMode', isDarkMode);
  }

}
