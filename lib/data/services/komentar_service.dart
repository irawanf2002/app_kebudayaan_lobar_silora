import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final CollectionReference _commentsRef =
      FirebaseFirestore.instance.collection('comments');

  // -------------------------
  // 🔥 OPTIONAL: FETCH (NON REALTIME)
  // -------------------------
  Future<List<CommentModel>> fetchComments(String cagarId) async {
    try {
      final snapshot = await _commentsRef
          .where('cagarId', isEqualTo: cagarId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  // -------------------------
  // 🔥 CREATE COMMENT
  // -------------------------
  Future<bool> createComment(CommentModel comment) async {
    try {
      await _commentsRef.add(comment.toFirestore());
      return true;
    } catch (e) {
      print("Error create comment: $e");
      return false;
    }
  }

  // -------------------------
  // 🔥 UPDATE COMMENT (FIXED)
  // -------------------------
  Future<bool> updateComment(
      String commentId, String newContent, int newRating) async {
    try {
      await _commentsRef.doc(commentId).update({
        'content': newContent,
        'rating': newRating,

        // 🔥 gunakan updatedAt, bukan createdAt
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Error update comment: $e");
      return false;
    }
  }

  // -------------------------
  // 🔥 DELETE COMMENT
  // -------------------------
  Future<bool> deleteComment(String commentId) async {
    try {
      await _commentsRef.doc(commentId).delete();
      return true;
    } catch (e) {
      print("Error delete comment: $e");
      return false;
    }
  }
}
