import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../providers/crypto_provider.dart';
import '../widgets/crypto_list_item.dart';
import '../screens/crypto_detail_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final RefreshController _topCoinsRefreshController = RefreshController();
  final RefreshController _trendingRefreshController = RefreshController();
  final RefreshController _searchRefreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CryptoProvider>(context, listen: false);
      provider.loadTopCryptocurrencies();
      provider.loadTrendingCryptocurrencies();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topCoinsRefreshController.dispose();
    _trendingRefreshController.dispose();
    _searchRefreshController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crypto Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
                     unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Top Coins'),
            Tab(text: 'Trending'),
            Tab(text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTopCoinsTab(),
          _buildTrendingTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildTopCoinsTab() {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.cryptocurrencies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty && provider.cryptocurrencies.isEmpty) {
          return _buildErrorWidget(provider.error, () {
            provider.loadTopCryptocurrencies();
          });
        }

        return SmartRefresher(
          controller: _topCoinsRefreshController,
          onRefresh: () async {
            await provider.loadTopCryptocurrencies();
            _topCoinsRefreshController.refreshCompleted();
          },
          child: ListView.builder(
            itemCount: provider.cryptocurrencies.length,
            itemBuilder: (context, index) {
              final crypto = provider.cryptocurrencies[index];
              return CryptoListItem(
                crypto: crypto,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CryptoDetailScreen(crypto: crypto),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        // Show loading if we're loading trending and have no data
        if (provider.isLoadingTrending && provider.trendingCryptocurrencies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error if we have an error and no data
        if (provider.error.isNotEmpty && provider.trendingCryptocurrencies.isEmpty) {
          return _buildErrorWidget(provider.error, () {
            provider.loadTrendingCryptocurrencies();
          });
        }

        // Show empty state if we have no data and no error
        if (provider.trendingCryptocurrencies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No trending data available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadTrendingCryptocurrencies(),
                  child: const Text('Load Trending'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Show fallback message if there's an error but we have data
            if (provider.error.isNotEmpty && provider.trendingCryptocurrencies.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Trending list
            Expanded(
              child: SmartRefresher(
                controller: _trendingRefreshController,
                onRefresh: () async {
                  await provider.loadTrendingCryptocurrencies();
                  _trendingRefreshController.refreshCompleted();
                },
                child: ListView.builder(
                  itemCount: provider.trendingCryptocurrencies.length,
                  itemBuilder: (context, index) {
                    final crypto = provider.trendingCryptocurrencies[index];
                    return CryptoListItem(
                      crypto: crypto,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CryptoDetailScreen(crypto: crypto),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search cryptocurrencies...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.clearSearch();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onChanged: (value) {
                  // Cancel previous timer
                  _searchDebounceTimer?.cancel();
                  
                  if (value.trim().isEmpty) {
                    provider.clearSearch();
                  } else if (value.trim().length >= 2) {
                    // Debounce search to avoid too many API calls
                    _searchDebounceTimer = Timer(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        provider.searchCryptocurrencies(value.trim());
                      }
                    });
                  } else {
                    provider.clearSearch();
                  }
                },
              ),
            ),
            
            // Search Results
            Expanded(
              child: _buildSearchResults(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(CryptoProvider provider) {
    if (provider.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    if (provider.searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for cryptocurrencies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a cryptocurrency name or symbol',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Show fallback message if there's an error but we have results
        if (provider.error.isNotEmpty && provider.searchResults.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Search results
        Expanded(
          child: provider.error.isNotEmpty && provider.searchResults.isEmpty
              ? _buildErrorWidget(provider.error, () {
                  provider.searchCryptocurrencies(provider.searchQuery);
                })
              : provider.searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching with a different term',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.searchResults.length,
                      itemBuilder: (context, index) {
                        final crypto = provider.searchResults[index];
                        return CryptoListItem(
                          crypto: crypto,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CryptoDetailScreen(crypto: crypto),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
                         color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                 color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
               ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
} 