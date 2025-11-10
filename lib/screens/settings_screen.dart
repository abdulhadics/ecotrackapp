import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../widgets/magic_mode_widgets.dart';
import '../widgets/power_mode_widgets.dart';
import '../services/animation_sound_service.dart';

/// Settings Screen with Mode Toggle and Configuration Options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              settingsService.isMagicMode ? '🎨 Magic Settings' : '⚙️ Power Settings',
              style: TextStyle(
                color: settingsService.isMagicMode 
                    ? MagicModeTheme.magicPrimary 
                    : PowerModeTheme.powerPrimary,
              ),
            ),
            backgroundColor: settingsService.isMagicMode 
                ? MagicModeTheme.magicBackground.colors.first
                : PowerModeTheme.powerBackground,
            elevation: 0,
          ),
          body: settingsService.isMagicMode 
              ? _buildMagicModeSettings(settingsService)
              : _buildPowerModeSettings(settingsService),
        );
      },
    );
  }

  /// Build Magic Mode Settings UI
  Widget _buildMagicModeSettings(SettingsService settingsService) {
    return Container(
      decoration: const BoxDecoration(
        gradient: MagicModeTheme.magicBackground,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Toggle Section
            _buildModeToggleSection(settingsService),
            
            const SizedBox(height: 24),
            
            // Magic Mode Specific Settings
            _buildMagicModeSpecificSettings(settingsService),
            
            const SizedBox(height: 24),
            
            // General Settings
            _buildGeneralSettings(settingsService),
            
            const SizedBox(height: 24),
            
            // Reset Settings
            _buildResetSection(settingsService),
          ],
        ),
      ),
    );
  }

  /// Build Power Mode Settings UI
  Widget _buildPowerModeSettings(SettingsService settingsService) {
    return Container(
      color: PowerModeTheme.powerBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Toggle Section
            _buildModeToggleSection(settingsService),
            
            const SizedBox(height: 24),
            
            // Power Mode Specific Settings
            _buildPowerModeSpecificSettings(settingsService),
            
            const SizedBox(height: 24),
            
            // General Settings
            _buildGeneralSettings(settingsService),
            
            const SizedBox(height: 24),
            
            // Data Export Section
            _buildDataExportSection(settingsService),
            
            const SizedBox(height: 24),
            
            // Reset Settings
            _buildResetSection(settingsService),
          ],
        ),
      ),
    );
  }

  /// Build Mode Toggle Section
  Widget _buildModeToggleSection(SettingsService settingsService) {
    return MagicCard(
      glowColor: settingsService.isMagicMode 
          ? MagicModeTheme.magicPrimary 
          : PowerModeTheme.powerPrimary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  settingsService.isMagicMode ? '🎨' : '⚙️',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'App Mode',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              settingsService.isMagicMode 
                  ? 'Magic Mode: Fun, colorful, and perfect for kids! 🌈'
                  : 'Power Mode: Clean, detailed, and perfect for adults! 📊',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildModeOption(
                    'Magic Mode',
                    '🎨',
                    'magic',
                    settingsService.isMagicMode,
                    () => _switchMode(settingsService, 'magic'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModeOption(
                    'Power Mode',
                    '⚙️',
                    'power',
                    settingsService.isPowerMode,
                    () => _switchMode(settingsService, 'power'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build Mode Option Button
  Widget _buildModeOption(
    String title,
    String emoji,
    String mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        SoundService().playButtonTap();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? (mode == 'magic' ? MagicModeTheme.magicPrimary : PowerModeTheme.powerPrimary)
                : Colors.grey.shade300,
            width: 2,
          ),
          color: isSelected 
              ? (mode == 'magic' 
                  ? MagicModeTheme.magicPrimary.withOpacity(0.1)
                  : PowerModeTheme.powerPrimary.withOpacity(0.1))
              : Colors.white,
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? (mode == 'magic' ? MagicModeTheme.magicPrimary : PowerModeTheme.powerPrimary)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Magic Mode Specific Settings
  Widget _buildMagicModeSpecificSettings(SettingsService settingsService) {
    return MagicCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌈', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Magic Mode Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Color Scheme
            _buildMagicSetting(
              'Color Scheme',
              settingsService.magicModeSettings.colorScheme,
              ['nature', 'rainbow', 'ocean', 'sunset'],
              (value) => _updateMagicSetting(
                settingsService,
                settingsService.magicModeSettings.copyWith(colorScheme: value),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Animation Intensity
            _buildSliderSetting(
              'Animation Intensity',
              settingsService.magicModeSettings.animationIntensity,
              (value) => _updateMagicSetting(
                settingsService,
                settingsService.magicModeSettings.copyWith(animationIntensity: value),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Animation Toggles
            _buildToggleSetting(
              'Show Sparkles',
              settingsService.magicModeSettings.showSparkles,
              (value) => _updateMagicSetting(
                settingsService,
                settingsService.magicModeSettings.copyWith(showSparkles: value),
              ),
            ),
            
            _buildToggleSetting(
              'Show Bouncing',
              settingsService.magicModeSettings.showBouncing,
              (value) => _updateMagicSetting(
                settingsService,
                settingsService.magicModeSettings.copyWith(showBouncing: value),
              ),
            ),
            
            _buildToggleSetting(
              'Show Pulsing',
              settingsService.magicModeSettings.showPulsing,
              (value) => _updateMagicSetting(
                settingsService,
                settingsService.magicModeSettings.copyWith(showPulsing: value),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sticker Theme
            _buildMagicSetting(
              'Sticker Theme',
              settingsService.magicModeSettings.stickerTheme,
              ['nature', 'animals', 'fantasy', 'space'],
              (value) => _updateMagicSetting(
                settingsService,
                settingsService.magicModeSettings.copyWith(stickerTheme: value),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Background Music
            _buildMagicSetting(
              'Background Music',
              settingsService.magicModeSettings.backgroundMusic,
              ['nature', 'ambient', 'none'],
              (value) => _updateMagicSetting(
                settingsService,
                settingsService.magicModeSettings.copyWith(backgroundMusic: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Power Mode Specific Settings
  Widget _buildPowerModeSpecificSettings(SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Power Mode Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Color Scheme
            _buildPowerSetting(
              'Color Scheme',
              settingsService.powerModeSettings.colorScheme,
              ['minimal', 'dark', 'light', 'high_contrast'],
              (value) => _updatePowerSetting(
                settingsService,
                settingsService.powerModeSettings.copyWith(colorScheme: value),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Display Options
            PowerSettingsToggle(
              title: 'Show Detailed Stats',
              subtitle: 'Display comprehensive analytics and metrics',
              value: settingsService.powerModeSettings.showDetailedStats,
              onChanged: (value) => _updatePowerSetting(
                settingsService,
                settingsService.powerModeSettings.copyWith(showDetailedStats: value),
              ),
            ),
            
            PowerSettingsToggle(
              title: 'Show Advanced Charts',
              subtitle: 'Enable detailed chart visualizations',
              value: settingsService.powerModeSettings.showAdvancedCharts,
              onChanged: (value) => _updatePowerSetting(
                settingsService,
                settingsService.powerModeSettings.copyWith(showAdvancedCharts: value),
              ),
            ),
            
            PowerSettingsToggle(
              title: 'Show Points Breakdown',
              subtitle: 'Display detailed points analysis',
              value: settingsService.powerModeSettings.showPointsBreakdown,
              onChanged: (value) => _updatePowerSetting(
                settingsService,
                settingsService.powerModeSettings.copyWith(showPointsBreakdown: value),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Goal Settings
            _buildSliderSetting(
              'Weekly Goal',
              settingsService.powerModeSettings.weeklyGoal.toDouble(),
              (value) => _updatePowerSetting(
                settingsService,
                settingsService.powerModeSettings.copyWith(weeklyGoal: value.round()),
              ),
              min: 50,
              max: 500,
              divisions: 45,
            ),
            
            _buildSliderSetting(
              'Monthly Goal',
              settingsService.powerModeSettings.monthlyGoal.toDouble(),
              (value) => _updatePowerSetting(
                settingsService,
                settingsService.powerModeSettings.copyWith(monthlyGoal: value.round()),
              ),
              min: 200,
              max: 2000,
              divisions: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Build General Settings
  Widget _buildGeneralSettings(SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⚙️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'General Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            PowerSettingsToggle(
              title: 'Sound Effects',
              subtitle: 'Play sounds for interactions and notifications',
              value: settingsService.soundEnabled,
              onChanged: (value) {
                SoundService().playButtonTap();
                settingsService.updateSoundEnabled(value);
              },
            ),
            
            PowerSettingsToggle(
              title: 'Animations',
              subtitle: 'Enable visual animations and transitions',
              value: settingsService.animationsEnabled,
              onChanged: (value) {
                SoundService().playButtonTap();
                settingsService.updateAnimationsEnabled(value);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Language Selection
            _buildLanguageSelection(settingsService),
            
            const SizedBox(height: 16),
            
            // Reminder Hours
            _buildReminderHours(settingsService),
          ],
        ),
      ),
    );
  }

  /// Build Data Export Section (Power Mode only)
  Widget _buildDataExportSection(SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📤', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Data Export',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: PowerExportButton(
                    text: 'Export CSV',
                    icon: Icons.table_chart,
                    format: ExportFormat.csv,
                    onPressed: () => _exportData('csv'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PowerExportButton(
                    text: 'Export JSON',
                    icon: Icons.code,
                    format: ExportFormat.json,
                    onPressed: () => _exportData('json'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: PowerExportButton(
                    text: 'Export PDF',
                    icon: Icons.picture_as_pdf,
                    format: ExportFormat.pdf,
                    onPressed: () => _exportData('pdf'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PowerExportButton(
                    text: 'Export Excel',
                    icon: Icons.grid_on,
                    format: ExportFormat.excel,
                    onPressed: () => _exportData('excel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build Reset Section
  Widget _buildResetSection(SettingsService settingsService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔄', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Reset Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Reset all settings to their default values. This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showResetConfirmation(settingsService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset to Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Magic Setting Dropdown
  Widget _buildMagicSetting(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              SoundService().playButtonTap();
              onChanged(value);
            }
          },
        ),
      ],
    );
  }

  /// Build Power Setting Dropdown
  Widget _buildPowerSetting(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              SoundService().playButtonTap();
              onChanged(value);
            }
          },
        ),
      ],
    );
  }

  /// Build Slider Setting
  Widget _buildSliderSetting(
    String title,
    double value,
    Function(double) onChanged, {
    double min = 0.0,
    double max = 1.0,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              divisions != null ? value.round().toString() : value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Build Toggle Setting
  Widget _buildToggleSetting(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            SoundService().playButtonTap();
            onChanged(newValue);
          },
        ),
      ],
    );
  }

  /// Build Language Selection
  Widget _buildLanguageSelection(SettingsService settingsService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: settingsService.language,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Español')),
            DropdownMenuItem(value: 'fr', child: Text('Français')),
            DropdownMenuItem(value: 'de', child: Text('Deutsch')),
          ],
          onChanged: (value) {
            if (value != null) {
              SoundService().playButtonTap();
              settingsService.updateLanguage(value);
            }
          },
        ),
      ],
    );
  }

  /// Build Reminder Hours
  Widget _buildReminderHours(SettingsService settingsService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Hours',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(24, (hour) {
            final isSelected = settingsService.reminderHours.contains(hour);
            return FilterChip(
              label: Text('${hour}:00'),
              selected: isSelected,
              onSelected: (selected) {
                SoundService().playButtonTap();
                final newHours = List<int>.from(settingsService.reminderHours);
                if (selected) {
                  newHours.add(hour);
                } else {
                  newHours.remove(hour);
                }
                settingsService.updateReminderHours(newHours);
              },
            );
          }),
        ),
      ],
    );
  }

  /// Switch Mode
  void _switchMode(SettingsService settingsService, String mode) {
    settingsService.switchMode(mode);
    
    // Show mode switch animation
    if (mode == 'magic') {
      SoundService().playCelebration();
    } else {
      SoundService().playSuccess();
    }
  }

  /// Update Magic Setting
  void _updateMagicSetting(SettingsService settingsService, MagicModeSettings newSettings) {
    settingsService.updateMagicModeSettings(newSettings);
  }

  /// Update Power Setting
  void _updatePowerSetting(SettingsService settingsService, PowerModeSettings newSettings) {
    settingsService.updatePowerModeSettings(newSettings);
  }

  /// Export Data
  void _exportData(String format) {
    SoundService().playSuccess();
    // TODO: Implement actual data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data as $format...'),
        backgroundColor: PowerModeTheme.powerSuccess,
      ),
    );
  }

  /// Show Reset Confirmation
  void _showResetConfirmation(SettingsService settingsService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              settingsService.resetToDefaults();
              SoundService().playSuccess();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
