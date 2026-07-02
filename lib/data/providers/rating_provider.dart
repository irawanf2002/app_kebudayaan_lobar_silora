import 'package:app_kebudyaan_lobar/data/models/rating_model.dart';
import 'package:app_kebudyaan_lobar/data/services/rating_service.dart';
import 'package:flutter/material.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _ratingService = RatingService();

  List<RatingModel> _ratings = [];
  List<RatingModel> get ratings => _ratings;

  bool isLoading = false;

  // 🔥 FIX 1: cagarId jadi STRING
  Future<void> fetchRatings(String cagarId) async {
    try {
      isLoading = true;
      notifyListeners();

      _ratings = await _ratingService.getRatings(cagarId);
    } catch (e) {
      debugPrint("Error fetch ratings: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 FIX 2: SEMUA JADI STRING
  Future<bool> addRating({
    required String cagarId,
    required String userId,
    required int nilai,
    String komentar = "",
  }) async {
    try {
      final ratingBaru = RatingModel(
        cagarId: cagarId, // ✅ STRING
        userId: userId, // ✅ STRING
        nilai: nilai,
        komentar: komentar,
      );

      final success = await _ratingService.addRating(ratingBaru);

      if (success) {
        await fetchRatings(cagarId); // ✅ STRING
      }

      return success;
    } catch (e) {
      debugPrint("Error add rating: $e");
      return false;
    }
  }
}
