class CryptoModel {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final double marketCapRank;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double marketCapChange24h;
  final double marketCapChangePercentage24h;
  final double circulatingSupply;
  final double totalSupply;
  final double maxSupply;
  final double ath;
  final double athChangePercentage;
  final String athDate;
  final double atl;
  final double atlChangePercentage;
  final String atlDate;
  final String lastUpdated;

  CryptoModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCapChange24h,
    required this.marketCapChangePercentage24h,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    required this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    required this.atlDate,
    required this.lastUpdated,
  });

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(
      id: json['id'] ?? '',
      symbol: json['symbol']?.toUpperCase() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      marketCap: (json['market_cap'] ?? 0.0).toDouble(),
      marketCapRank: (json['market_cap_rank'] ?? 0.0).toDouble(),
      totalVolume: (json['total_volume'] ?? 0.0).toDouble(),
      high24h: (json['high_24h'] ?? 0.0).toDouble(),
      low24h: (json['low_24h'] ?? 0.0).toDouble(),
      priceChange24h: (json['price_change_24h'] ?? 0.0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0.0).toDouble(),
      marketCapChange24h: (json['market_cap_change_24h'] ?? 0.0).toDouble(),
      marketCapChangePercentage24h: (json['market_cap_change_percentage_24h'] ?? 0.0).toDouble(),
      circulatingSupply: (json['circulating_supply'] ?? 0.0).toDouble(),
      totalSupply: (json['total_supply'] ?? 0.0).toDouble(),
      maxSupply: (json['max_supply'] ?? 0.0).toDouble(),
      ath: (json['ath'] ?? 0.0).toDouble(),
      athChangePercentage: (json['ath_change_percentage'] ?? 0.0).toDouble(),
      athDate: json['ath_date'] ?? '',
      atl: (json['atl'] ?? 0.0).toDouble(),
      atlChangePercentage: (json['atl_change_percentage'] ?? 0.0).toDouble(),
      atlDate: json['atl_date'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
    );
  }

  // Factory method for detailed JSON from /coins/{id} endpoint
  factory CryptoModel.fromDetailedJson(Map<String, dynamic> json) {
    // Extract market data from the nested structure
    final marketData = json['market_data'] ?? {};
    final currentPrice = marketData['current_price']?['usd'] ?? 0.0;
    final marketCap = marketData['market_cap']?['usd'] ?? 0.0;
    final totalVolume = marketData['total_volume']?['usd'] ?? 0.0;
    final high24h = marketData['high_24h']?['usd'] ?? 0.0;
    final low24h = marketData['low_24h']?['usd'] ?? 0.0;
    final priceChange24h = marketData['price_change_24h'] ?? 0.0;
    final priceChangePercentage24h = marketData['price_change_percentage_24h'] ?? 0.0;
    final marketCapChange24h = marketData['market_cap_change_24h'] ?? 0.0;
    final marketCapChangePercentage24h = marketData['market_cap_change_percentage_24h'] ?? 0.0;
    final circulatingSupply = marketData['circulating_supply'] ?? 0.0;
    final totalSupply = marketData['total_supply'] ?? 0.0;
    final maxSupply = marketData['max_supply'] ?? 0.0;
    final ath = marketData['ath']?['usd'] ?? 0.0;
    final athChangePercentage = marketData['ath_change_percentage']?['usd'] ?? 0.0;
    final athDate = marketData['ath_date']?['usd'] ?? '';
    final atl = marketData['atl']?['usd'] ?? 0.0;
    final atlChangePercentage = marketData['atl_change_percentage']?['usd'] ?? 0.0;
    final atlDate = marketData['atl_date']?['usd'] ?? '';

    return CryptoModel(
      id: json['id'] ?? '',
      symbol: json['symbol']?.toUpperCase() ?? '',
      name: json['name'] ?? '',
      image: json['image']?['large'] ?? json['image']?['small'] ?? json['image']?['thumb'] ?? '',
      currentPrice: (currentPrice is num) ? currentPrice.toDouble() : 0.0,
      marketCap: (marketCap is num) ? marketCap.toDouble() : 0.0,
      marketCapRank: (json['market_cap_rank'] ?? 0.0).toDouble(),
      totalVolume: (totalVolume is num) ? totalVolume.toDouble() : 0.0,
      high24h: (high24h is num) ? high24h.toDouble() : 0.0,
      low24h: (low24h is num) ? low24h.toDouble() : 0.0,
      priceChange24h: (priceChange24h is num) ? priceChange24h.toDouble() : 0.0,
      priceChangePercentage24h: (priceChangePercentage24h is num) ? priceChangePercentage24h.toDouble() : 0.0,
      marketCapChange24h: (marketCapChange24h is num) ? marketCapChange24h.toDouble() : 0.0,
      marketCapChangePercentage24h: (marketCapChangePercentage24h is num) ? marketCapChangePercentage24h.toDouble() : 0.0,
      circulatingSupply: (circulatingSupply is num) ? circulatingSupply.toDouble() : 0.0,
      totalSupply: (totalSupply is num) ? totalSupply.toDouble() : 0.0,
      maxSupply: (maxSupply is num) ? maxSupply.toDouble() : 0.0,
      ath: (ath is num) ? ath.toDouble() : 0.0,
      athChangePercentage: (athChangePercentage is num) ? athChangePercentage.toDouble() : 0.0,
      athDate: (athDate is String) ? athDate : '',
      atl: (atl is num) ? atl.toDouble() : 0.0,
      atlChangePercentage: (atlChangePercentage is num) ? atlChangePercentage.toDouble() : 0.0,
      atlDate: (atlDate is String) ? atlDate : '',
      lastUpdated: json['last_updated'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
      'price_change_24h': priceChange24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'market_cap_change_24h': marketCapChange24h,
      'market_cap_change_percentage_24h': marketCapChangePercentage24h,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'max_supply': maxSupply,
      'ath': ath,
      'ath_change_percentage': athChangePercentage,
      'ath_date': athDate,
      'atl': atl,
      'atl_change_percentage': atlChangePercentage,
      'atl_date': atlDate,
      'last_updated': lastUpdated,
    };
  }
} 