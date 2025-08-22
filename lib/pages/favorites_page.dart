import 'package:flutter/material.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import '../components/movie_favorites.dart';
import '../data/movies.dart'; 

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteMovies = allMovies
        .where((movie) => favoriteMovieIds.contains(movie['id']))
        .toList();

        MovieFavorites(
  favoriteMovieIds: favoriteMovieIds,
  allMovies: allMovies,
  );

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Favoriler',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 34, 106),
      ),
      body: favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                'Favori film bulunamadı',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                return ListTile(
                  leading: movie['primaryImage'] != null
                      ? Image.network(
                          movie['primaryImage'],
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.movie),
                  title: Text(
                    movie['primaryTitle'] ?? 'Başlık yok',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Puan: ${movie['averageRating']?.toString() ?? 'Yok'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MovieDetailPage(movie: movie),
                    ));
                  },
                );
              },
            ),
      backgroundColor: const Color.fromARGB(255, 60, 34, 106),
      
    );
  }
}
