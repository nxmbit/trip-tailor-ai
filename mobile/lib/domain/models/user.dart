class User {
  final String email;
  final String username;
  final String photoUrl;

  User({required this.email, required this.username, required this.photoUrl});

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {'email': email, 'username': username, 'photoUrl': photoUrl};
  }

  // Create a copy of the user with potential updates
  User copyWith({String? email, String? username, String? photoUrl}) {
    return User(
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
