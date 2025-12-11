import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();
  List<String> _recentSearches = [];
  List<String> _favoriteCities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final recent = await _storageService.getRecentSearches();
    final favorites = await _storageService.getFavoriteCities();
    
    setState(() {
      _recentSearches = recent;
      _favoriteCities = favorites;
    });
  }

  Future<void> _searchCity(String cityName) async {
    if (cityName.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    
    final provider = context.read<WeatherProvider>();
    await provider.fetchWeatherByCity(cityName.trim());
    
    setState(() => _isLoading = false);
    
    if (provider.state == WeatherState.loaded) {
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(String city) async {
    final favorites = List<String>.from(_favoriteCities);
    
    if (favorites.contains(city)) {
      favorites.remove(city);
    } else {
      if (favorites.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 favorite cities allowed'),
          ),
        );
        return;
      }
      favorites.add(city);
    }
    
    await _storageService.saveFavoriteCities(favorites);
    setState(() => _favoriteCities = favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter city name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: _searchCity,
              textInputAction: TextInputAction.search,
            ),
          ),
          
          // Loading Indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Favorite Cities
                if (_favoriteCities.isNotEmpty) ...[
                  const Text(
                    'Favorite Cities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._favoriteCities.map((city) => _buildCityTile(
                        city,
                        isFavorite: true,
                      )),
                  const SizedBox(height: 24),
                ],
                
                // Recent Searches
                if (_recentSearches.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _storageService.clearRecentSearches();
                          setState(() => _recentSearches = []);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._recentSearches.map((city) => _buildCityTile(city)),
                  const SizedBox(height: 24),
                ],
                
                // Popular Cities
                const Text(
                  'Popular Cities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._popularCities.map((city) => _buildCityTile(city)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityTile(String city, {bool isFavorite = false}) {
    final isInFavorites = _favoriteCities.contains(city);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.location_city),
        title: Text(city),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isInFavorites ? Icons.star : Icons.star_border,
                color: isInFavorites ? Colors.amber : null,
              ),
              onPressed: () => _toggleFavorite(city),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _searchCity(city),
      ),
    );
  }

  static const List<String> _popularCities = [
    'Ho Chi Minh City',
    'Hanoi',
    'Da Nang',
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Singapore',
    'Bangkok',
    'Seoul',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}