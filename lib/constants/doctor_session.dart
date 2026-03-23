/// Frontend stand-in for the logged-in doctor until auth/API provides ids.
class DoctorSession {
  DoctorSession._();

  /// Must match [SelectSpecialty1Screen] default `doctorId` for bookings to appear here.
  static const String currentDoctorId = 'default';

  static const String displayName = 'Doctor';
}
