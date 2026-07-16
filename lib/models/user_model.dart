class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // Customer, Restaurant, ya Rider

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  // Data ko Map mein convert karne ke liye (Firebase mein bhejne ke liye)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // Firebase se aaye hue data ko Model mein convert karne ke liye
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }
}