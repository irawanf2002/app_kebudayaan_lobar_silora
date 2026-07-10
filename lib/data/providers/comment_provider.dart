// lib/data/providers/comment_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  StreamSubscription<QuerySnapshot>? _subscription;

  // ============================================
  // LISTEN TO COMMENTS BY CAGAR ID (REALTIME)
  // ============================================
  void listenToComments(String cagarId) {
    // ✅ PERBAIKAN: Cek jika cagarId kosong
    if (cagarId.isEmpty) {
      debugPrint("❌ Cagar ID is empty!");
      _comments = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    _subscription?.cancel();
    _subscription = _firestore
        .collection('comments')
        .where('cagarId', isEqualTo: cagarId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _comments = snapshot.docs
                .map((doc) => CommentModel.fromFirestore(doc))
                .toList();
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
            debugPrint("✅ Loaded ${_comments.length} comments for cagar: $cagarId");
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = error.toString();
            notifyListeners();
            debugPrint("❌ Error listening to comments: $error");
          },
        );
  }

  // ============================================
  // LISTEN TO ALL COMMENTS (ADMIN)
  // ============================================
  void listenToAllComments() {
    _isLoading = true;
    notifyListeners();
    
    _subscription?.cancel();
    _subscription = _firestore
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _comments = snapshot.docs
                .map((doc) => CommentModel.fromFirestore(doc))
                .toList();
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = error.toString();
            notifyListeners();
            debugPrint("❌ Error listening to all comments: $error");
          },
        );
  }

  // ============================================
  // ADD COMMENT
  // ============================================
  Future<bool> addComment({
    required String cagarId,
    required String content,
    required int rating,
    required String userId,
    required String userName,
  }) async {
    // ✅ PERBAIKAN: Validasi lengkap
    if (cagarId.isEmpty) {
      _errorMessage = "Cagar ID tidak boleh kosong!";
      notifyListeners();
      return false;
    }
    
    if (content.trim().isEmpty) {
      _errorMessage = "Komentar tidak boleh kosong!";
      notifyListeners();
      return false;
    }
    
    if (userName.trim().isEmpty) {
      _errorMessage = "Nama tidak boleh kosong!";
      notifyListeners();
      return false;
    }

    try {
      await _firestore.collection('comments').add({
        'cagarId': cagarId,
        'userId': userId,
        'userName': userName.trim(),
        'content': content.trim(),
        'rating': rating.clamp(1, 5),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'isReported': false,
        'reportReason': null,
        'reportedAt': null,
      });
      
      _errorMessage = null;
      debugPrint("✅ Comment added successfully!");
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("❌ Error adding comment: $e");
      return false;
    }
  }

  // ============================================
  // UPDATE COMMENT
  // ============================================
  Future<bool> updateComment({
    required String commentId,
    required String content,
    required int rating,
  }) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'content': content.trim(),
        'rating': rating.clamp(1, 5),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint("✅ Comment updated successfully!");
      return true;
    } catch (e) {
      debugPrint("❌ Error updating comment: $e");
      return false;
    }
  }

  // ============================================
  // DELETE COMMENT
  // ============================================
  Future<bool> deleteComment(String commentId) async {
    try {
      await _firestore.collection('comments').doc(commentId).delete();
      debugPrint("✅ Comment deleted successfully!");
      return true;
    } catch (e) {
      debugPrint("❌ Error deleting comment: $e");
      return false;
    }
  }

  // ============================================
  // GET COMMENTS BY CAGAR ID (ONCE)
  // ============================================
  Future<List<CommentModel>> getCommentsByCagarId(String cagarId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('cagarId', isEqualTo: cagarId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("❌ Error getting comments: $e");
      return [];
    }
  }

  // ============================================
  // GET COMMENTS BY USER ID
  // ============================================
  Future<List<CommentModel>> getCommentsByUserId(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("❌ Error getting user comments: $e");
      return [];
    }
  }

  // ============================================
  // GET COMMENT BY ID
  // ============================================
  Future<CommentModel?> getCommentById(String commentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('comments')
          .doc(commentId)
          .get();
      
      if (doc.exists) {
        return CommentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error getting comment: $e");
      return null;
    }
  }

  // ============================================
  // GET AVERAGE RATING BY CAGAR ID
  // ============================================
  Future<double> getAverageRating(String cagarId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('cagarId', isEqualTo: cagarId)
          .get();
      
      if (snapshot.docs.isEmpty) return 0.0;
      
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.get('rating') ?? 5).toDouble();
      }
      
      return total / snapshot.docs.length;
    } catch (e) {
      debugPrint("❌ Error calculating average rating: $e");
      return 0.0;
    }
  }

  // ============================================
  // GET RATING DISTRIBUTION
  // ============================================
  Future<Map<int, int>> getRatingDistribution(String cagarId) async {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('cagarId', isEqualTo: cagarId)
          .get();
      
      for (var doc in snapshot.docs) {
        int rating = (doc.get('rating') ?? 5).toInt().clamp(1, 5);
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
      
      return distribution;
    } catch (e) {
      debugPrint("❌ Error getting rating distribution: $e");
      return distribution;
    }
  }

  // ============================================
  // GET TOTAL COMMENTS COUNT
  // ============================================
  Future<int> getTotalCommentsCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('comments').get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint("❌ Error getting total comments: $e");
      return 0;
    }
  }

  // ============================================
  // GET COMMENTS WITH PAGINATION
  // ============================================
  Future<List<CommentModel>> getCommentsPaginated({
    required String cagarId,
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('comments')
          .where('cagarId', isEqualTo: cagarId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("❌ Error getting paginated comments: $e");
      return [];
    }
  }

  // ============================================
  // REPORT COMMENT (ADMIN)
  // ============================================
  Future<bool> reportComment(String commentId, String reason) async {
    try {
      await _firestore.collection('comments').doc(commentId).update({
        'isReported': true,
        'reportReason': reason,
        'reportedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint("✅ Comment reported successfully!");
      return true;
    } catch (e) {
      debugPrint("❌ Error reporting comment: $e");
      return false;
    }
  }

  // ============================================
  // GET REPORTED COMMENTS (ADMIN)
  // ============================================
  Future<List<CommentModel>> getReportedComments() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('isReported', isEqualTo: true)
          .orderBy('reportedAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("❌ Error getting reported comments: $e");
      return [];
    }
  }

  // ============================================
  // REFRESH COMMENTS
  // ============================================
  void refreshComments(String cagarId) {
    // ✅ PERBAIKAN: Cek jika cagarId kosong
    if (cagarId.isEmpty) {
      debugPrint("⚠️ Cannot refresh comments: Cagar ID is empty!");
      return;
    }
    listenToComments(cagarId);
  }

  // ============================================
  // CLEAR COMMENTS
  // ============================================
  void clearComments() {
    _comments = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // ============================================
  // DISPOSE
  // ============================================
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}