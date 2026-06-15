// Genre ID mapping based on TMDB genre list
const Map<int, String> genreMap = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Sci-Fi',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

class Movie {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final double popularity;
  final List<int> genreIds;
  final String originalLanguage;
  final bool adult;

  Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.popularity,
    required this.genreIds,
    required this.originalLanguage,
    required this.adult,
  });

  factory Movie.fromMap(Map<dynamic, dynamic> map) {
    return Movie(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      originalTitle: map['original_title'] ?? '',
      overview: map['overview'] ?? '',
      posterPath: map['poster_path'] ?? '',
      backdropPath: map['backdrop_path'] ?? '',
      releaseDate: map['release_date'] ?? '',
      voteAverage: (map['vote_average'] ?? 0.0).toDouble(),
      voteCount: map['vote_count'] ?? 0,
      popularity: (map['popularity'] ?? 0.0).toDouble(),
      genreIds: List<int>.from(map['genre_ids'] ?? []),
      originalLanguage: map['original_language'] ?? '',
      adult: map['adult'] ?? false,
    );
  }

  /// Full poster image URL (TMDB CDN)
  String get posterUrl =>
      'https://image.tmdb.org/t/p/w500$posterPath';

  /// Full backdrop image URL (TMDB CDN)
  String get backdropUrl =>
      'https://image.tmdb.org/t/p/w1280$backdropPath';

  /// Release year extracted from release_date
  String get year =>
      releaseDate.isNotEmpty ? releaseDate.split('-').first : 'N/A';

  /// Genre names joined by comma
  String get genreNames =>
      genreIds.map((id) => genreMap[id] ?? 'Unknown').join(' • ');

  /// Rounded rating out of 10
  String get ratingDisplay =>
      voteAverage.toStringAsFixed(1);

  /// Rating as fraction of 5 stars
  double get starRating => (voteAverage / 10) * 5;
}
