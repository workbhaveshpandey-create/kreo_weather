import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kreo_weather/app/theme/app_colors.dart';
import 'package:kreo_weather/app/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        title: Text(
          'SETTINGS',
          style: AppTextStyles.label(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Appearance Section
          Text(
            'APPEARANCE',
            style: AppTextStyles.labelSmall(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Theme Toggle
          _buildSettingsTile(
            context,
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: 'Light Mode',
            subtitle: isDark
                ? 'Currently using dark theme'
                : 'Currently using light theme',
            trailing: Switch(
              value: !isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              activeColor: AppColors.accent,
            ),
          ),

          const SizedBox(height: 32),

          // Location Section
          Text(
            'LOCATION',
            style: AppTextStyles.labelSmall(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingsTile(
            context,
            icon: Icons.my_location,
            title: 'Use Current Location',
            subtitle: 'Automatically detect your location',
            trailing: Icon(
              Icons.check_circle,
              color: AppColors.accent,
              size: 20,
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingsTile(
            context,
            icon: Icons.search,
            title: 'Search Location',
            subtitle: 'Find weather for any city',
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              // Will implement location search
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 32),

          // Notifications Section
          Text(
            'NOTIFICATIONS',
            style: AppTextStyles.labelSmall(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Weather Alerts',
            subtitle: 'Get notified about severe weather',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: AppColors.accent,
            ),
          ),

          const SizedBox(height: 32),

          // About Section
          Text(
            'ABOUT',
            style: AppTextStyles.labelSmall(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0',
          ),

          const SizedBox(height: 12),

          _buildSettingsTile(
            context,
            icon: Icons.auto_awesome,
            title: 'Powered by',
            subtitle: 'Open-Meteo API • Pollinations AI',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariant : AppColors.lightSurface,
          border: Border.all(
            color: isDark ? AppColors.divider : AppColors.lightDivider,
          ),
          borderRadius: BorderRadius.circular(12),
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
              child: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
