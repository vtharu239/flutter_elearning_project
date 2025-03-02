class User {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String gender;
  final String? dateOfBirth;
  final String phoneNo;
  final String? avatarUrl;
  final String? coverImageUrl;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNo,
    this.avatarUrl,
    this.coverImageUrl,
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
    };
  }
}