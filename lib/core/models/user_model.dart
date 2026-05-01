class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'client' or 'vendor'
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? address;

  // Vendor specific fields (can be null if the user is a client)
  final String? storeName;
  final String? storeDescription;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    this.address,
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
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      address: map['address'],
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
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'storeName': storeName,
      'storeDescription': storeDescription,
    };
  }
}
