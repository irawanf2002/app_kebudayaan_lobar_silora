import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart'; // Sesuaikan path folder

class CommentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;
  StreamSubscription? _sub;

  void listenToComments(String cagarId) {
    _sub?.cancel();
    _sub = _firestore
        .collection('comments')
        .where('cagarId', isEqualTo: cagarId) // 🔥 Pengunci ulasan spesifik
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _comments =
          snapshot.docs.map((e) => CommentModel.fromFirestore(e)).toList();
      notifyListeners();
    });
  }

  Future<bool> addComment({
    required String cagarId,
    required String content,
    required int rating,
    required String userId,
    required String userName,
  }) async {
    try {
      await _firestore.collection('comments').add({
        'cagarId': cagarId,
        'userId': userId,
        'userName': userName,
        'content': content,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("ERROR ADD COMMENT: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
