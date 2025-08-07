import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/crypto_model.dart';

class CryptoApiService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  static const int _rateLimitDelay = 2000; // 2 seconds between requests to avoid rate limiting
  
  // Track last request time to avoid rate limiting
  static DateTime? _lastRequestTime;
  
  // Helper method to respect rate limits
  static Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest.inMilliseconds < _rateLimitDelay) {
        final delayNeeded = _rateLimitDelay - timeSinceLastRequest.inMilliseconds;
        await Future.delayed(Duration(milliseconds: delayNeeded));
      }
    }
    _lastRequestTime = DateTime.now();
  }

  // Fetch top cryptocurrencies by market cap
  static Future<List<CryptoModel>> getTopCryptocurrencies({int perPage = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=1&sparkline=false&locale=en'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CryptoModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cryptocurrencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cryptocurrencies: $e');
    }
  }

  // Fetch detailed information for a specific cryptocurrency
  static Future<CryptoModel> getCryptocurrencyDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coins/$id?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CryptoModel.fromDetailedJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load cryptocurrency details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cryptocurrency details: $e');
    }
  }

  // Search cryptocurrencies with retry mechanism
  static Future<List<CryptoModel>> searchCryptocurrencies(String query) async {
    const int maxRetries = 2;
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        // Respect rate limits
        await _respectRateLimit();
        
        final response = await http.get(
          Uri.parse('$baseUrl/search?query=$query'),
          headers: {'Accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> coins = data['coins'] ?? [];
          
          if (coins.isEmpty) {
            return [];
          }
          
          // Extract coin IDs from search results
          final List<String> coinIds = coins
              .take(10) // Limit to top 10 results for better performance
              .map((coin) => coin['id'] as String)
              .toList();
          
          // Respect rate limits before second request
          await _respectRateLimit();
          
          // Get market data for searched coins in a single request
          final marketResponse = await http.get(
            Uri.parse('$baseUrl/coins/markets?vs_currency=usd&ids=${coinIds.join(",")}&order=market_cap_desc&per_page=10&page=1&sparkline=false&locale=en'),
            headers: {'Accept': 'application/json'},
          );
          
          if (marketResponse.statusCode == 200) {
            final List<dynamic> marketData = json.decode(marketResponse.body);
            final results = marketData.map((json) => CryptoModel.fromJson(json)).toList();
            
            print('Successfully loaded ${results.length} search results');
            return results;
          } else {
            print('Market API Error for search: ${marketResponse.statusCode} - ${marketResponse.body}');
            // Return empty results if market data fails
            return [];
          }
        } else if (response.statusCode == 429) {
          if (retryCount < maxRetries) {
            retryCount++;
            print('Rate limit hit, retrying in ${_rateLimitDelay * retryCount}ms... (attempt $retryCount)');
            await Future.delayed(Duration(milliseconds: _rateLimitDelay * retryCount));
            continue;
          }
          throw Exception('Rate limit exceeded. Please try again later.');
        } else {
          throw Exception('Failed to search cryptocurrencies: ${response.statusCode}');
        }
      } catch (e) {
        if (retryCount < maxRetries && e.toString().contains('Rate limit')) {
          retryCount++;
          print('Retrying search due to rate limit... (attempt $retryCount)');
          await Future.delayed(Duration(milliseconds: _rateLimitDelay * retryCount));
          continue;
        }
        print('Exception in searchCryptocurrencies: $e');
        throw Exception('Failed to search cryptocurrencies: $e');
      }
    }
    
    throw Exception('Failed to search cryptocurrencies after $maxRetries retries');
  }

  // Get market data for trending cryptocurrencies
  static Future<List<CryptoModel>> getTrendingCryptocurrencies() async {
    try {
      print('Fetching trending cryptocurrencies...');
      
      // First try to get trending coins list
      final response = await http.get(
        Uri.parse('$baseUrl/search/trending'),
        headers: {'Accept': 'application/json'},
      );

      print('Trending API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> trending = data['coins'] ?? [];
        
        print('Found ${trending.length} trending coins');
        
        if (trending.isEmpty) {
          // Fallback to top cryptocurrencies if no trending data
          return await getTopCryptocurrencies(perPage: 10);
        }
        
        // Extract trending coin IDs
        final List<String> trendingIds = trending
            .take(7)
            .map((item) => item['item']['id'] as String)
            .toList();
        
        // Get market data for trending coins in a single request
        final marketResponse = await http.get(
          Uri.parse('$baseUrl/coins/markets?vs_currency=usd&ids=${trendingIds.join(",")}&order=market_cap_desc&per_page=7&page=1&sparkline=false&locale=en'),
          headers: {'Accept': 'application/json'},
        );
        
        if (marketResponse.statusCode == 200) {
          final List<dynamic> marketData = json.decode(marketResponse.body);
          final results = marketData.map((json) => CryptoModel.fromJson(json)).toList();
          
          print('Successfully loaded ${results.length} trending cryptocurrencies');
          return results;
        } else {
          print('Market API Error: ${marketResponse.statusCode} - ${marketResponse.body}');
          // Fallback to top cryptocurrencies
          return await getTopCryptocurrencies(perPage: 10);
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        // Fallback to top cryptocurrencies
        return await getTopCryptocurrencies(perPage: 10);
      }
    } catch (e) {
      print('Exception in getTrendingCryptocurrencies: $e');
      // Fallback to top cryptocurrencies
      try {
        return await getTopCryptocurrencies(perPage: 10);
      } catch (fallbackError) {
        throw Exception('Failed to load trending cryptocurrencies: $e');
      }
    }
  }
} 