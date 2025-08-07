# Crypto Tracker App

A modern Flutter application for tracking real-time cryptocurrency prices and market data using the CoinGecko API.

## Features

### 🚀 Core Features
- **Real-time Cryptocurrency Data**: Get live prices, market cap, volume, and price changes
- **Top Cryptocurrencies**: View the top 50 cryptocurrencies by market cap
- **Trending Coins**: Discover trending cryptocurrencies in the market
- **Search Functionality**: Search for any cryptocurrency by name or symbol
- **Detailed Information**: Comprehensive details for each cryptocurrency

### 📊 Data Display
- Current price with 24h price change
- Market cap and volume information
- Price range (24h high/low)
- Supply information (circulating, total, max)
- All-time high and low statistics
- Market cap rank and percentage changes

### 🎨 User Experience
- **Modern Material 3 Design**: Beautiful and intuitive interface
- **Dark/Light Theme Support**: Automatic theme switching based on system preference
- **Pull-to-Refresh**: Refresh data by pulling down the list
- **Responsive Design**: Works on all screen sizes
- **Error Handling**: Graceful error handling with retry options
- **Loading States**: Smooth loading indicators

### 🔧 Technical Features
- **State Management**: Using Provider for efficient state management
- **API Integration**: CoinGecko API for reliable cryptocurrency data
- **Image Caching**: Cached network images for better performance
- **Offline Support**: Basic offline handling with error states

## Screenshots

The app features three main tabs:
1. **Top Coins**: Displays top cryptocurrencies by market cap
2. **Trending**: Shows currently trending cryptocurrencies
3. **Search**: Allows users to search for specific cryptocurrencies

## Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd crypto_tracker_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following key dependencies:

- **http**: For API requests to CoinGecko
- **provider**: For state management
- **shared_preferences**: For local data storage
- **intl**: For number and date formatting
- **cached_network_image**: For efficient image loading
- **pull_to_refresh**: For refresh functionality

## API Usage

This app uses the **CoinGecko API** which is free and doesn't require authentication for basic usage. The API provides:

- Real-time cryptocurrency data
- Market information
- Price history
- Trending data

### API Endpoints Used
- `/coins/markets` - Get top cryptocurrencies
- `/coins/{id}` - Get detailed coin information
- `/search` - Search cryptocurrencies
- `/search/trending` - Get trending coins

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── crypto_model.dart     # Data model for cryptocurrencies
├── providers/
│   └── crypto_provider.dart  # State management
├── screens/
│   ├── home_screen.dart      # Main screen with tabs
│   └── crypto_detail_screen.dart # Detailed crypto view
├── services/
│   └── crypto_api_service.dart # API service
├── utils/
│   └── formatters.dart       # Data formatting utilities
└── widgets/
    └── crypto_list_item.dart # Reusable list item widget
```

## Usage

### Viewing Cryptocurrencies
1. Open the app to see the "Top Coins" tab
2. Swipe between tabs to view different sections
3. Pull down to refresh the data

### Searching
1. Tap the "Search" tab
2. Enter a cryptocurrency name or symbol
3. View search results in real-time

### Viewing Details
1. Tap on any cryptocurrency in the list
2. View comprehensive information including:
   - Current price and changes
   - Market data
   - Supply information
   - All-time statistics

## Features in Detail

### Top Coins Tab
- Displays top 50 cryptocurrencies by market cap
- Shows rank, name, symbol, current price, and 24h change
- Pull-to-refresh functionality
- Error handling with retry option

### Trending Tab
- Shows currently trending cryptocurrencies
- Updated trending data from CoinGecko
- Same interaction patterns as Top Coins

### Search Tab
- Real-time search functionality
- Search by name or symbol
- Clear search option
- No results handling

### Detail Screen
- Comprehensive cryptocurrency information
- Market data in organized cards
- Price range information
- Supply details
- All-time high/low statistics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **CoinGecko API** for providing reliable cryptocurrency data
- **Flutter Team** for the amazing framework
- **Material Design** for the design system

## Support

If you encounter any issues or have questions, please:
1. Check the existing issues
2. Create a new issue with detailed information
3. Include device information and steps to reproduce

---

**Note**: This app is for educational and informational purposes. Cryptocurrency prices are volatile and should not be considered as financial advice.
