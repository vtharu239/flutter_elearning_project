class User {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String gender;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      gender: json['gender'],
    );
  }
}