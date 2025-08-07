import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/crypto_model.dart';
import '../utils/formatters.dart';

class CryptoDetailScreen extends StatelessWidget {
  final CryptoModel crypto;

  const CryptoDetailScreen({
    super.key,
    required this.crypto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = Formatters.isPositiveChange(crypto.priceChangePercentage24h);

    return Scaffold(
      appBar: AppBar(
        title: Text(crypto.name),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon and Name
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: crypto.image,
                          width: 50,
                          height: 50,
                                                     placeholder: (context, url) => Container(
                             width: 50,
                             height: 50,
                             decoration: BoxDecoration(
                               color: theme.colorScheme.surfaceContainerHighest,
                               borderRadius: BorderRadius.circular(25),
                             ),
                            child: Icon(
                              Icons.currency_bitcoin,
                              size: 25,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                                                     errorWidget: (context, url, error) => Container(
                             width: 50,
                             height: 50,
                             decoration: BoxDecoration(
                               color: theme.colorScheme.surfaceContainerHighest,
                               borderRadius: BorderRadius.circular(25),
                             ),
                            child: Icon(
                              Icons.currency_bitcoin,
                              size: 25,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crypto.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              crypto.symbol,
                                                           style: theme.textTheme.titleMedium?.copyWith(
                               color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.6),
                             ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          Formatters.formatRank(crypto.marketCapRank),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Current Price
                  Text(
                    Formatters.formatCurrency(crypto.currentPrice),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price Change
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatPriceChange(crypto.priceChange24h),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                 decoration: BoxDecoration(
                           color: isPositive 
                               ? Colors.green.withValues(alpha: 0.1)
                               : Colors.red.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(12),
                         ),
                        child: Text(
                          Formatters.formatPercentageChange(crypto.priceChangePercentage24h),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Market Data Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Data',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildDataGrid(context),
                  
                  const SizedBox(height: 30),
                  
                  // Price Range Section
                  Text(
                    '24h Price Range',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildPriceRange(context),
                  
                  const SizedBox(height: 30),
                  
                  // Supply Information
                  Text(
                    'Supply Information',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildSupplyInfo(context),
                  
                  const SizedBox(height: 30),
                  
                  // All Time High/Low
                  Text(
                    'All Time Statistics',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildAllTimeStats(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDataGrid(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: [
        _buildDataCard(context, 'Market Cap', Formatters.formatCompact(crypto.marketCap), Icons.account_balance_wallet),
        _buildDataCard(context, 'Volume (24h)', Formatters.formatCompact(crypto.totalVolume), Icons.trending_up),
        _buildDataCard(context, 'Market Cap Change', Formatters.formatPercentageChange(crypto.marketCapChangePercentage24h), Icons.analytics, isPercentage: true),
        _buildDataCard(context, 'Circulating Supply', Formatters.formatSupply(crypto.circulatingSupply), Icons.all_inbox),
      ].map((child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 30,
          child: child,
        );
      }).toList(),
    );
  }


  Widget _buildDataCard(BuildContext context, String title, String value, IconData icon, {bool isPercentage = false}) {
    final theme = Theme.of(context);
    final isPositive = isPercentage && value.contains('+');
    final isNegative = isPercentage && value.contains('-');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isPositive 
                  ? Colors.green 
                  : isNegative 
                      ? Colors.red 
                      : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

     Widget _buildPriceRange(BuildContext context) {
     final theme = Theme.of(context);
     
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: theme.colorScheme.surface,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(
           color: theme.colorScheme.outline.withValues(alpha: 0.2),
         ),
       ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'High (24h)',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                Formatters.formatCurrency(crypto.high24h),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low (24h)',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                Formatters.formatCurrency(crypto.low24h),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

     Widget _buildSupplyInfo(BuildContext context) {
     final theme = Theme.of(context);
     
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: theme.colorScheme.surface,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(
           color: theme.colorScheme.outline.withValues(alpha: 0.2),
         ),
       ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Circulating Supply',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                Formatters.formatSupply(crypto.circulatingSupply),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Supply',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                Formatters.formatSupply(crypto.totalSupply),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (crypto.maxSupply > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Max Supply',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  Formatters.formatSupply(crypto.maxSupply),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

     Widget _buildAllTimeStats(BuildContext context) {
     final theme = Theme.of(context);
     
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: theme.colorScheme.surface,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(
           color: theme.colorScheme.outline.withValues(alpha: 0.2),
         ),
       ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Time High',
                style: theme.textTheme.bodyMedium,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(crypto.ath),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                                     Text(
                     Formatters.formatDate(crypto.athDate),
                     style: theme.textTheme.bodySmall?.copyWith(
                       color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                     ),
                   ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Time Low',
                style: theme.textTheme.bodyMedium,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(crypto.atl),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                                     Text(
                     Formatters.formatDate(crypto.atlDate),
                     style: theme.textTheme.bodySmall?.copyWith(
                       color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                     ),
                   ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 