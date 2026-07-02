class UserModel {
  final int? id;
  final String uid; // string id fallback
  final String name;
  final String email;
  final String? photoUrl;
  final String role;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = 'user',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['user_id'] ?? json['uid'];
    return UserModel(
      id: idVal is int ? idVal : int.tryParse(idVal?.toString() ?? ''),
      uid: (json['uid'] ?? json['user_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nama'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      photoUrl:
          (json['photoUrl'] ?? json['photo_url'] ?? json['photo'] ?? '')
              .toString()
              .isEmpty
          ? null
          : (json['photoUrl'] ?? json['photo_url'] ?? json['photo']).toString(),
      role: (json['role'] ?? 'user').toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
