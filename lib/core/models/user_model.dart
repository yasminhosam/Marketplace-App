class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'client' or 'vendor'

  // Vendor specific fields (can be null if the user is a client)
  final String? storeName;
  final String? storeDescription;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.storeName,
    this.storeDescription,
  });

  // Read data from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      storeName: map['storeName'],
      storeDescription: map['storeDescription'],
    );
  }

  // Save data to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'storeName': storeName,
      'storeDescription': storeDescription,
    };
  }
}