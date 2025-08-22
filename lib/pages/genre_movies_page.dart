import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/service/api_service.dart';

class GenreMoviesPage extends StatefulWidget {
  final String genreTitle;
  final String genreParam;

  const GenreMoviesPage({
    super.key, 
    required this.genreTitle,
    required this.genreParam,
    });

  @override
  State<GenreMoviesPage> createState() => _GenreMoviesPageState();
}

class _GenreMoviesPageState extends State<GenreMoviesPage> {
  List<dynamic> genreMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGenreMovies();
  }

  Future<void> fetchGenreMovies() async {
    try {
      final movies = await ApiService.fetchMoviesByGenre(widget.genreParam);
      setState(() {
        genreMovies = movies;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Kategori filmleri alınamadı: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 34, 106),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 34, 106),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${widget.genreTitle} Filmleri",
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.purpleAccent,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : genreMovies.isEmpty
              ? const Center(child: Text("Film bulunamadı", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                itemCount: genreMovies.length,
                itemBuilder: (context, index) {
                  final movie = genreMovies[index];
                  final image = movie['primaryImage'];
                  String imageUrl = '';

                  if (image is String) {
                    imageUrl = image;
                  } else if (image is Map && image['url'] is String) {
                    imageUrl = image['url'];
                  }

                  return ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, width: 50, height: 75, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported),
                    title: Text(movie['primaryTitle'] ?? 'Başlık yok',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(movie['releaseDate'] ?? 'Yayın Tarihi Yok',
                        style: const TextStyle(color: Colors.white70)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => MovieDetailPage(movie: movie),
                      ));
                    },
                  );
                },
              ),
    );
  }
}



