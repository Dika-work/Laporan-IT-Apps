class UserModel {
  String username;
  String typeUser;
  String usernameHash;

  UserModel({
    required this.username,
    required this.typeUser,
    required this.usernameHash,
  });

  // Mapping JSON ke Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      typeUser: json['type_user'],
      usernameHash: json['username_hash'],
    );
  }
}
