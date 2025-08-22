import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_app/pages/movie_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> searchResults = [];
  bool isLoading = false;

  // Hatalardan koruyan image url alıcı fonksiyon
  String getImageUrl(dynamic movie) {
    final image = movie['image'];
    final primaryImage = movie['primaryImage'];

    if (image is String && image.isNotEmpty) {
      return image;
    } else if (primaryImage is String && primaryImage.isNotEmpty) {
      return primaryImage;
    } else if (primaryImage is Map && primaryImage['url'] is String) {
      return primaryImage['url'];
    }
    return '';
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final url =
        'https://imdb236.p.rapidapi.com/api/imdb/search?type=movie&query=$query';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-rapidapi-key': 'd843337367msh47df50da62aa8a6p134f99jsnae103889e220',
        'x-rapidapi-host': 'imdb236.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("API response: ${response.body}");

      setState(() {
    
  searchResults = (data['results'] ?? []).where((movie) {
    final title = movie['primaryTitle'] ?? movie['title'] ?? movie['originalTitle'];
    
    // Afiş URL'si alma (farklı yapıda olabilir)
    String? imageUrl;
    final image = movie['image'];
    final primaryImage = movie['primaryImage'];
    
    if (image is String && image.isNotEmpty) {
      imageUrl = image;
    } else if (primaryImage is String && primaryImage.isNotEmpty) {
      imageUrl = primaryImage;
    } else if (primaryImage is Map && primaryImage['url'] is String && primaryImage['url'].toString().isNotEmpty) {
      imageUrl = primaryImage['url'];
    }
    SizedBox(height: 25);
    return title != null &&
           title.toString().trim().isNotEmpty &&
           imageUrl != null &&
           imageUrl.isNotEmpty;
  }).toList();

  isLoading = false;
});

    } else {
      print("API hatası: ${response.statusCode} - ${response.body}");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 34, 106),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 34, 106),
        title: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(
            'Arama',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              onChanged: (value) {
                if (value.length > 2) {
                  searchMovies(value);
                }
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Film Ara",
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.w200,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
              ),
            ),
          ),
          isLoading
              ? const CircularProgressIndicator()
              : searchResults.isEmpty
              ? const Text(
                  "Film bulunamadı",
                  style: TextStyle(color: Colors.white70),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
  final movie = searchResults[index];
  final title = movie['primaryTitle'] ?? 'Başlıksız';
  final imageUrl = getImageUrl(movie);

  return ListTile(
    leading: imageUrl.isNotEmpty
        ? Image.network(imageUrl, width: 50)
        : const Icon(Icons.image_not_supported, color: Colors.white70),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailPage(movie: movie),
        ),
      );
    },
  );
},

                  ),
                ),
        ],
      ),
    );
  }
}
