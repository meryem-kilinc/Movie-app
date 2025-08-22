import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/auth/login.dart';
import 'package:movie_app/components/category_button.dart';
import 'package:movie_app/pages/genre_movies_page.dart';
import 'package:movie_app/pages/movie_detail_page.dart';
import 'package:movie_app/service/api_service.dart';
import 'package:movie_app/pages/search_page.dart';
import 'package:movie_app/pages/profile_page.dart';
import 'package:movie_app/components/movie_favorites.dart'; // <- bunu ekle

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
List<Map<String, dynamic>> featuredMovies = [];
List<Map<String, dynamic>> newMovies = [];
List<Map<String, dynamic>> popularMovies = [];

  List<String> favoriteMovieIds = []; // <- favori film ID'leri
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllMovies();
  }

Future<void> loadAllMovies() async {
  try {
    final List<Map<String, dynamic>> fMovies =
        List<Map<String, dynamic>>.from(await ApiService.fetchFeaturedMovies());

    final List<Map<String, dynamic>> nMovies =
        List<Map<String, dynamic>>.from(await ApiService.fetchNewMovies());

    final List<Map<String, dynamic>> pMovies =
        List<Map<String, dynamic>>.from(await ApiService.fetchPopularMovies());

    setState(() {
      featuredMovies = fMovies;
      newMovies = nMovies;
      popularMovies = pMovies;
      isLoading = false;
    });
  } catch (e) {
    print("Veri çekme hatası: $e");
  }
}


  void toggleFavorite(String movieId) {
    setState(() {
      if (favoriteMovieIds.contains(movieId)) {
        favoriteMovieIds.remove(movieId);
      } else {
        favoriteMovieIds.add(movieId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 34, 106),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 34, 106),
        title: Text(
          "Movie App",
          style: GoogleFonts.orbitron(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: const Color.fromARGB(255, 213, 156, 224),
          ),
        ),
      ),
      body: getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 43, 24, 77),
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.black,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Anasayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Arama"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoriler"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget getCurrentPage() {
  switch (currentIndex) {
    case 1:
      return const SearchPage();
    case 2:
    return MovieFavorites(
        favoriteMovieIds: favoriteMovieIds,
        allMovies: [
          ...featuredMovies,
          ...newMovies,
          ...popularMovies,
      ]
    );
    case 3:
      return const ProfilePage();
    default:
      return _buildHomeContent();
  }
}


  Widget _buildHomeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildCategoryButtons(),
          const SizedBox(height: 20),
          _buildSection("🎯 Öne Çıkanlar", featuredMovies),
          const SizedBox(height: 20),
          _buildSection("🆕 Yeni Çıkanlar", newMovies),
          const SizedBox(height: 20),
          _buildSection("🔥 Popülerler", popularMovies),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            title,
            style: GoogleFonts.bebasNeue(fontSize: 25, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        _buildMovieRow(movies),
      ],
    );
  }

  Widget _buildMovieRow(List<dynamic> movies) {
    if (movies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          final image = movie['primaryImage'];
          final movieId = movie['id'];
          String imageUrl = '';

          if (image is String && image.isNotEmpty) {
            imageUrl = image;
          } else if (image is Map && image['url'] is String && image['url'].isNotEmpty) {
            imageUrl = image['url'];
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailPage(movie: movie),
                  ),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: 120,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image, size: 50),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: Icon(
                        favoriteMovieIds.contains(movieId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => toggleFavorite(movieId),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryButtons() {
    final Map<String, String> genres = {
      'Aksiyon': 'Action',
      'Gerilim': 'Thriller',
      'Korku': 'Horror',
      'Dram': 'Drama',
      'Komedi': 'Comedy',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: genres.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: CategoryButton(
              title: entry.key,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenreMoviesPage(
                      genreTitle: entry.key,
                      genreParam: entry.value,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
