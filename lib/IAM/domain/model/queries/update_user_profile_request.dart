class EditUserProfileRequest {
  final String? name;
  final String? surname;
  final String? phone;
  final String? email;
  final String? state;
  final int? roleId;
  final String? photoURL;

  EditUserProfileRequest({
    this.name,
    this.surname,
    this.phone,
    this.email,
    this.state,
    this.roleId,
    this.photoURL,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'phone': phone,
      'email': email,
      'state': state,
      'roleId': roleId,
      'photoURL': photoURL,
    };
  }
}
