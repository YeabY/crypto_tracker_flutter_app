import 'package:flutter/foundation.dart';
import '../models/crypto_model.dart';
import '../services/crypto_api_service.dart';

class CryptoProvider with ChangeNotifier {
  List<CryptoModel> _cryptocurrencies = [];
  List<CryptoModel> _trendingCryptocurrencies = [];
  List<CryptoModel> _searchResults = [];
  bool _isLoading = false;
  bool _isLoadingTrending = false;
  bool _isSearching = false;
  String _error = '';
  String _searchQuery = '';
  
  // Cache for search results to avoid repeated API calls
  final Map<String, List<CryptoModel>> _searchCache = {};
  final Map<String, DateTime> _searchCacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5); // Cache for 5 minutes

  // Getters
  List<CryptoModel> get cryptocurrencies => _cryptocurrencies;
  List<CryptoModel> get trendingCryptocurrencies => _trendingCryptocurrencies;
  List<CryptoModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isSearching => _isSearching;
  String get error => _error;
  String get searchQuery => _searchQuery;

  // Load top cryptocurrencies
  Future<void> loadTopCryptocurrencies({int perPage = 50}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final data = await CryptoApiService.getTopCryptocurrencies(perPage: perPage);
      _cryptocurrencies = data;
      
      // Clear old cache entries when new data is loaded
      _clearOldCache();
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load trending cryptocurrencies
  Future<void> loadTrendingCryptocurrencies() async {
    _setLoadingTrending(true);
    _clearError();
    _trendingCryptocurrencies = []; // Clear previous data
    notifyListeners();
    
    try {
      final data = await CryptoApiService.getTrendingCryptocurrencies();
      _trendingCryptocurrencies = data;
      
      // Check if we got trending data or fallback data
      if (data.isNotEmpty && data.length <= 10) {
        // This might be fallback data, but we don't show it as an error
        // since the user still gets useful data
        _clearError();
      }
      
      notifyListeners();
    } catch (e) {
      String errorMessage = e.toString();
      
      // Provide more user-friendly error messages
      if (errorMessage.contains('Rate limit exceeded')) {
        errorMessage = 'API rate limit exceeded. Please wait a moment and try again.';
      } else if (errorMessage.contains('429')) {
        errorMessage = 'Too many requests. Please wait a moment and try again.';
      } else if (errorMessage.contains('Failed to load trending')) {
        errorMessage = 'Unable to load trending cryptocurrencies. Please check your internet connection and try again.';
      }
      
      // If trending fails and we have top cryptocurrencies, use them as fallback
      if (_cryptocurrencies.isNotEmpty) {
        _trendingCryptocurrencies = _cryptocurrencies.take(10).toList();
        errorMessage = 'Showing top cryptocurrencies instead of trending (API limit reached).';
      }
      
      _setError(errorMessage);
    } finally {
      _setLoadingTrending(false);
    }
  }

  // Search cryptocurrencies
  Future<void> searchCryptocurrencies(String query) async {
    final trimmedQuery = query.trim().toLowerCase();
    
    if (trimmedQuery.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      _clearError();
      notifyListeners();
      return;
    }

    _setSearching(true);
    _searchQuery = query;
    _clearError();
    
    // Check cache first
    if (_searchCache.containsKey(trimmedQuery)) {
      final cacheTime = _searchCacheTimestamps[trimmedQuery];
      if (cacheTime != null && DateTime.now().difference(cacheTime) < _cacheExpiry) {
        _searchResults = _searchCache[trimmedQuery]!;
        _setSearching(false);
        notifyListeners();
        return;
      }
    }
    
    try {
      // First try to search within existing top cryptocurrencies (faster and no API limits)
      final localResults = _searchLocally(trimmedQuery);
      
      if (localResults.isNotEmpty) {
        _searchResults = localResults;
        _searchCache[trimmedQuery] = localResults;
        _searchCacheTimestamps[trimmedQuery] = DateTime.now();
        notifyListeners();
        return;
      }
      
      // If no local results, try API search
      final data = await CryptoApiService.searchCryptocurrencies(query);
      _searchResults = data;
      
      // Cache the API results
      if (data.isNotEmpty) {
        _searchCache[trimmedQuery] = data;
        _searchCacheTimestamps[trimmedQuery] = DateTime.now();
      }
      
      notifyListeners();
    } catch (e) {
      String errorMessage = e.toString();
      
      // Provide more user-friendly error messages
      if (errorMessage.contains('Rate limit exceeded')) {
        errorMessage = 'API rate limit exceeded. Please wait a moment and try again.';
      } else if (errorMessage.contains('429')) {
        errorMessage = 'Too many requests. Please wait a moment and try again.';
      } else if (errorMessage.contains('Failed to search')) {
        errorMessage = 'Unable to search cryptocurrencies. Please check your internet connection and try again.';
      }
      
      // If API search fails, try to search within existing top cryptocurrencies
      final fallbackResults = _searchLocally(trimmedQuery);
      if (fallbackResults.isNotEmpty) {
        _searchResults = fallbackResults;
        errorMessage = 'Showing results from top cryptocurrencies (API limit reached).';
      }
      
      _setError(errorMessage);
    } finally {
      _setSearching(false);
    }
  }
  
  // Search within existing top cryptocurrencies
  List<CryptoModel> _searchLocally(String query) {
    if (_cryptocurrencies.isEmpty) return [];
    
    return _cryptocurrencies.where((crypto) {
      final nameLower = crypto.name.toLowerCase();
      final symbolLower = crypto.symbol.toLowerCase();
      
      // Check for exact matches first
      if (nameLower == query || symbolLower == query) {
        return true;
      }
      
      // Check for partial matches
      if (nameLower.contains(query) || symbolLower.contains(query)) {
        return true;
      }
      
      // Check for word boundaries (e.g., "bitcoin" matches "bitcoin cash")
      final nameWords = nameLower.split(' ');
      final symbolWords = symbolLower.split(' ');
      
      return nameWords.any((word) => word.startsWith(query)) ||
             symbolWords.any((word) => word.startsWith(query));
    }).take(10).toList();
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _clearError();
    notifyListeners();
  }
  
  // Clear old cache entries
  void _clearOldCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _searchCacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheExpiry) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _searchCache.remove(key);
      _searchCacheTimestamps.remove(key);
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([
      loadTopCryptocurrencies(),
      loadTrendingCryptocurrencies(),
    ]);
  }

  // Get cryptocurrency by ID
  CryptoModel? getCryptocurrencyById(String id) {
    try {
      return _cryptocurrencies.firstWhere((crypto) => crypto.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get cryptocurrency by symbol
  CryptoModel? getCryptocurrencyBySymbol(String symbol) {
    try {
      return _cryptocurrencies.firstWhere(
        (crypto) => crypto.symbol.toLowerCase() == symbol.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setLoadingTrending(bool loading) {
    _isLoadingTrending = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }
} 