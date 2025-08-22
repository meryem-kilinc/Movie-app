import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiService {
  static final Map<String, String> headers = {
    'x-rapidapi-key': dotenv.env['RAPID_API_KEY'] ?? '',
    'x-rapidapi-host': 'imdb236.p.rapidapi.com',
  };

  // JSON'u cache’e yaz
  static Future<void> _cacheMovies(String key, List<dynamic> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(movies);
    await prefs.setString(key, jsonData);
  }

  // Cache'den oku
  static Future<List<dynamic>?> _getCachedMovies(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(key);
    if (jsonData != null) {
      return jsonDecode(jsonData);
    }
    return null;
  }

  static Future<List<dynamic>> _fetchMovies({bool useCache = true}) async {
    const cacheKey = 'all_movies_cache';

    if (useCache) {
      final cached = await _getCachedMovies(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    final url = Uri.parse(
        'https://imdb236.p.rapidapi.com/api/imdb/search?type=movie&genre=Drama&rows=25&sortOrder=ASC&sortField=id');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = (data['results'] ?? []).where((movie) {
        final image = movie['primaryImage'];
        return image != null &&
            ((image is String && image.isNotEmpty) ||
                (image is Map && image['url'] != null && image['url'].toString().isNotEmpty));
      }).toList();

      await _cacheMovies(cacheKey, results); // cache’e yaz
      return results;
    } else {
      throw Exception('Failed to fetch movies');
    }
  }

  static Future<List<dynamic>> fetchFeaturedMovies() async {
    final movies = await _fetchMovies();
    return movies.where((movie) {
      final rating = movie['averageRating'];
      return rating is num && rating > 6.0;
    }).take(10).toList();
  }

  static Future<List<dynamic>> fetchNewMovies() async {
    final movies = await _fetchMovies();
    movies.sort((a, b) {
      final dateA = DateTime.tryParse(a['releaseDate'] ?? '') ?? DateTime(1900);
      final dateB = DateTime.tryParse(b['releaseDate'] ?? '') ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });
    return movies.take(10).toList();
  }

  static Future<List<dynamic>> fetchPopularMovies() async {
    final movies = await _fetchMovies();
    movies.sort((a, b) {
      final votesA = a['numVotes'];
      final votesB = b['numVotes'];
      final safeA = (votesA is int) ? votesA : 0;
      final safeB = (votesB is int) ? votesB : 0;
      return safeB.compareTo(safeA);
    });
    return movies.take(10).toList();
  }

  static Future<List<dynamic>> fetchMoviesByGenre(String genre) async {
    final cacheKey = 'genre_$genre';
    final cached = await _getCachedMovies(cacheKey);

    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final url = Uri.parse(
        'https://imdb236.p.rapidapi.com/api/imdb/search?type=movie&genre=$genre&rows=50');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = (data['results'] ?? []).where((movie) {
        final image = movie['primaryImage'];
        return image != null &&
            ((image is String && image.isNotEmpty) ||
                (image is Map && image['url'] != null && image['url'].toString().isNotEmpty));
      }).toList();

      await _cacheMovies(cacheKey, results);
      return results;
    } else {
      throw Exception('Failed to fetch movies by genre');
    }
  }
}
