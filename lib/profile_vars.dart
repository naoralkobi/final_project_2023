class ProfileVars {
  static late int languageNum;
  static late int numOfLvls;
  static late int minAge;
  static late int maxAge;
  static late int userNameLength;

  void init() {
    languageNum = 0;
    numOfLvls = 0;
    minAge = 1;
    maxAge = 1;
    userNameLength = 0;
  }

  bool validate() {
    if (languageNum > 0 &&
        numOfLvls == languageNum &&
        minAge != 1 &&
        maxAge != 1 &&
        userNameLength < 16) {
      return true;
    }
    return false;
  }
}
