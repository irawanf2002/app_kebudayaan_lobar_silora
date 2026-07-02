import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_kebudyaan_lobar/config/api_config.dart';
import 'package:app_kebudyaan_lobar/data/models/rating_model.dart';

class RatingService {
  // 🔥 FIX: cagarId jadi STRING
  Future<List<RatingModel>> getRatings(String cagarId) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.rating}?cagar_id=$cagarId"),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List data = jsonResponse['data'];

        return data.map((e) => RatingModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error service: $e");
    }
    return [];
  }

  // 🔥 FIX: pastikan JSON kirim STRING juga
  Future<bool> addRating(RatingModel rating) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.rating),
        headers: {
          ...ApiConfig.headers,
          "Content-Type": "application/json",
        },
        body: jsonEncode(rating.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error add rating: $e");
      return false;
    }
  }
}
