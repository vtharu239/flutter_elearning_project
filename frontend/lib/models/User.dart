class User {
  final int id;
  final String? email;
  final String? username;
  final String? fullName;
  final String? gender;
  final String? dateOfBirth;
  final String? phoneNo;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? googleId;
  final String? facebookId;

  User({
    required this.id,
    this.email,
    this.username,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.phoneNo,
    this.avatarUrl,
    this.coverImageUrl,
    this.googleId,
    this.facebookId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      phoneNo: json['phoneNo'],
      avatarUrl: json['avatarUrl'],
      coverImageUrl: json['coverImageUrl'],
      googleId: json['googleId'],
      facebookId: json['facebookId'],
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'phoneNo': phoneNo,
      'avatarUrl': avatarUrl,
      'coverImageUrl': coverImageUrl,
      'googleId': googleId,
      'facebookId': facebookId,
    };
  }
}
