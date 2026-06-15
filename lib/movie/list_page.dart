import 'package:flutter/material.dart';
import 'package:movie/data/data.dart';
import 'package:movie/data/movie_model.dart';
import 'package:movie/movie/detail_page.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with SingleTickerProviderStateMixin {
  // ── Color tokens ────────────────────────────────────────────────
  static const Color _bg = Color(0xFF0F1116);
  static const Color _primBlue = Color(0xFF00A8E1);
  static const Color _accentRed = Color(0xFFE50914);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFB3B3B3);

  late final List<Movie> _movies;
  late AnimationController _fadeCtrl;

  String _searchQuery = '';
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _movies = (Data.movieList['results'] as List)
        .map((m) => Movie.fromMap(m as Map<dynamic, dynamic>))
        .toList();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Movie> get _filteredMovies {
    if (_searchQuery.isEmpty) return _movies;
    return _movies
        .where(
          (m) =>
              m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.genreNames.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 110,
            backgroundColor: _bg,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_bg, _bg.withValues(alpha: 0.0)],
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              title: _showSearch
                  ? _buildSearchField()
                  : Row(
                      children: [
                        // logo cine prime
                        Container(
                          width: 35,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [_accentRed, _primBlue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.local_movies,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'CinePrime',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _showSearch ? Icons.close_rounded : Icons.search_rounded,
                    key: ValueKey(_showSearch),
                    color: _textPrimary,
                    size: 24,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchQuery = '';
                      _searchCtrl.clear();
                    }
                  });
                },
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Section header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _searchQuery.isEmpty
                            ? 'Trending Now'
                            : 'Search Results',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_filteredMovies.length} movies',
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // Blue pill tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _primBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _primBlue.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      '2026',
                      style: TextStyle(
                        color: _primBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Movie List ────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final movie = _filteredMovies[index];
              return _MovieCard(
                movie: movie,
                index: index,
                onTap: () => _openDetail(movie),
              );
            }, childCount: _filteredMovies.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchCtrl,
      autofocus: true,
      style: const TextStyle(color: _textPrimary, fontSize: 15),
      cursorColor: _primBlue,
      decoration: InputDecoration(
        hintText: 'Search movies or genres…',
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _primBlue,
          size: 20,
        ),
      ),
      onChanged: (v) => setState(() => _searchQuery = v),
    );
  }

  void _openDetail(Movie movie) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, x) => DetailPage(movie: movie),
        transitionsBuilder: (_, animation, x, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Movie Card Widget
// ═══════════════════════════════════════════════════════════════════
class _MovieCard extends StatefulWidget {
  final Movie movie;
  final int index;
  final VoidCallback onTap;

  const _MovieCard({
    required this.movie,
    required this.index,
    required this.onTap,
  });

  @override
  State<_MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<_MovieCard>
    with SingleTickerProviderStateMixin {
  static const Color _bgSecondary = Color(0xFF1A1D24);
  static const Color _primBlue = Color(0xFF00A8E1);
  static const Color _accentRed = Color(0xFFE50914);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFB3B3B3);

  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.reverse(),
        onTapUp: (_) {
          _scaleCtrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _scaleCtrl.forward(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: _bgSecondary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Poster ──────────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: 105,
                      height: 155,
                      child: Image.network(
                        movie.posterUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF252830),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: _primBlue,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, e, s) => Container(
                          color: const Color(0xFF252830),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_outlined,
                                color: _textSecondary.withValues(alpha: 0.4),
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No Image',
                                style: TextStyle(
                                  color: _textSecondary.withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Rank badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _accentRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${widget.index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Genre tags
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: movie.genreIds
                            .take(2)
                            .map(
                              (id) =>
                                  _GenrePill(label: genreMap[id] ?? 'Unknown'),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),

                      // Year • Language
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.year,
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.language_rounded,
                            size: 11,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.originalLanguage.toUpperCase(),
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Rating bar
                      Row(
                        children: [
                          // Star fill
                          _StarRating(rating: movie.starRating),
                          const SizedBox(width: 6),
                          Text(
                            movie.ratingDisplay,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_formatCount(movie.voteCount)})',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Overview snippet
                      Text(
                        movie.overview,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Chevron ──────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(right: 12, top: 70),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF444750),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════
// Star Rating Widget
// ═══════════════════════════════════════════════════════════════════
class _StarRating extends StatelessWidget {
  final double rating; // 0..5
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFC107),
            size: 14,
          );
        } else if (i < rating) {
          return const Icon(
            Icons.star_half_rounded,
            color: Color(0xFFFFC107),
            size: 14,
          );
        } else {
          return const Icon(
            Icons.star_outline_rounded,
            color: Color(0xFF444750),
            size: 14,
          );
        }
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Genre Pill Widget
// ═══════════════════════════════════════════════════════════════════
class _GenrePill extends StatelessWidget {
  final String label;
  const _GenrePill({required this.label});

  static const _primBlue = Color(0xFF00A8E1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _primBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _primBlue.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _primBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
