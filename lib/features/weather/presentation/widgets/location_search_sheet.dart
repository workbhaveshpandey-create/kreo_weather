import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kreo_weather/app/theme/app_colors.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';

class LocationSearchSheet extends StatefulWidget {
  const LocationSearchSheet({super.key});

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<LocationResult> _results = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Popular cities for quick access
  final List<LocationResult> _popularCities = [
    LocationResult(
      name: 'New Delhi',
      country: 'India',
      lat: 28.6139,
      lon: 77.2090,
    ),
    LocationResult(
      name: 'Mumbai',
      country: 'India',
      lat: 19.0760,
      lon: 72.8777,
    ),
    LocationResult(
      name: 'Bangalore',
      country: 'India',
      lat: 12.9716,
      lon: 77.5946,
    ),
    LocationResult(
      name: 'London',
      country: 'United Kingdom',
      lat: 51.5074,
      lon: -0.1278,
    ),
    LocationResult(
      name: 'New York',
      country: 'United States',
      lat: 40.7128,
      lon: -74.0060,
    ),
    LocationResult(
      name: 'Tokyo',
      country: 'Japan',
      lat: 35.6762,
      lon: 139.6503,
    ),
    LocationResult(name: 'Dubai', country: 'UAE', lat: 25.2048, lon: 55.2708),
    LocationResult(
      name: 'Singapore',
      country: 'Singapore',
      lat: 1.3521,
      lon: 103.8198,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto focus search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchCities(query);
    });
  }

  Future<void> _searchCities(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Using Open-Meteo Geocoding API (free, no API key)
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=en&format=json',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;

        if (results != null) {
          setState(() {
            _results = results
                .map(
                  (r) => LocationResult(
                    name: r['name'] ?? '',
                    country: r['country'] ?? '',
                    admin: r['admin1'] ?? '',
                    lat: (r['latitude'] as num).toDouble(),
                    lon: (r['longitude'] as num).toDouble(),
                  ),
                )
                .toList();
            _isSearching = false;
          });
        } else {
          setState(() {
            _results = [];
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
    }
  }

  void _selectLocation(LocationResult location) {
    context.read<WeatherBloc>().add(
      LoadWeatherForLocation(location.lat, location.lon, location.name),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Location',
                  style: AppTextStyles.title(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariant
                          : AppColors.lightSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: AppTextStyles.body(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search city or place...',
                  hintStyle: AppTextStyles.body(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() => _results = []);
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                  _onSearchChanged(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results / Loading / Popular
          Expanded(
            child: _isSearching
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  )
                : _results.isNotEmpty
                ? _buildSearchResults(theme, isDark)
                : _buildPopularCities(theme, isDark),
          ),

          // Current Location Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                context.read<WeatherBloc>().add(LoadWeather());
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      color: theme.scaffoldBackgroundColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Use Current Location',
                      style: AppTextStyles.titleSmall(
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final location = _results[index];
        return _buildLocationTile(theme, isDark, location);
      },
    );
  }

  Widget _buildPopularCities(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'POPULAR CITIES',
            style: AppTextStyles.labelSmall(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _popularCities.length,
            itemBuilder: (context, index) {
              final city = _popularCities[index];
              return _buildLocationTile(theme, isDark, city);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTile(
    ThemeData theme,
    bool isDark,
    LocationResult location,
  ) {
    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariant : AppColors.lightSurface,
          border: Border.all(
            color: isDark ? AppColors.divider : AppColors.lightDivider,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: AppTextStyles.titleSmall(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.admin.isNotEmpty
                        ? '${location.admin}, ${location.country}'
                        : location.country,
                    style: AppTextStyles.bodySmall(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class LocationResult {
  final String name;
  final String country;
  final String admin;
  final double lat;
  final double lon;

  LocationResult({
    required this.name,
    required this.country,
    this.admin = '',
    required this.lat,
    required this.lon,
  });
}
