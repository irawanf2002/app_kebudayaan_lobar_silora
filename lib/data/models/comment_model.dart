import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String? id;
  final String cagarId;
  final String userId;
  final String userName;
  final String content;
  final int rating;
  final DateTime createdAt;

  CommentModel({
    this.id,
    required this.cagarId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CommentModel(
      id: doc.id,
      cagarId: data['cagarId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString().isNotEmpty == true
          ? data['userName']
          : 'Anonim',
      content: data['content']?.toString() ?? '',
      rating: (data['rating'] is int)
          ? data['rating']
          : int.tryParse(data['rating']?.toString() ?? '5') ?? 5,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cagarId': cagarId,
      'userId': userId,
      'userName': userName.isNotEmpty ? userName : 'Anonim',
      'content': content,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
