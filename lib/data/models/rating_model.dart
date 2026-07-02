class RatingModel {
  final String? id;
  final String cagarId; // ✅ STRING
  final String userId; // ✅ STRING
  final int nilai;
  final String komentar;

  RatingModel({
    this.id,
    required this.cagarId,
    required this.userId,
    required this.nilai,
    required this.komentar,
  });

  // 🔥 DARI FIRESTORE / JSON
  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id']?.toString(),

      // 🔥 FIX: jangan parse ke int
      cagarId: json['cagarId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',

      nilai: (json['nilai'] ?? 0) is int
          ? json['nilai']
          : int.tryParse(json['nilai'].toString()) ?? 0,

      komentar: json['komentar'] ?? '',
    );
  }

  // 🔥 KE FIRESTORE
  Map<String, dynamic> toJson() {
    return {
      'cagarId': cagarId, // ✅ camelCase & STRING
      'userId': userId,
      'nilai': nilai,
      'komentar': komentar,
    };
  }
}
