/// Holds user profile overrides for the current app session.
/// When the user edits profile, values are stored here and the Profile
/// screen displays these instead of auth storage. No backend; session only.
class ProfileSessionStore {
  ProfileSessionStore._();

  static String? _fullName;
  static String? _email;
  static String? _phone;
  static String? _dateOfBirth;
  static String? _gender;

  static String? get fullName => _fullName;
  static String? get email => _email;
  static String? get phone => _phone;
  static String? get dateOfBirth => _dateOfBirth;
  static String? get gender => _gender;

  static void setFullName(String value) {
    _fullName = value.isEmpty ? null : value;
  }

  static void setEmail(String value) {
    _email = value.isEmpty ? null : value;
  }

  static void setPhone(String value) {
    _phone = value.isEmpty ? null : value;
  }

  static void setDateOfBirth(String value) {
    _dateOfBirth = value.isEmpty ? null : value;
  }

  static void setGender(String value) {
    _gender = value.isEmpty ? null : value;
  }
}
