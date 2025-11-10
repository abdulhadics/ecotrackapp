import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Power Mode Theme with clean, professional colors
class PowerModeTheme {
  // Professional Color Palette for Power Mode
  static const Color powerPrimary = Color(0xFF1A365D); // Deep Blue
  static const Color powerSecondary = Color(0xFF2D3748); // Dark Gray
  static const Color powerAccent = Color(0xFF3182CE); // Blue Accent
  static const Color powerSuccess = Color(0xFF38A169); // Success Green
  static const Color powerWarning = Color(0xFFD69E2E); // Warning Yellow
  static const Color powerError = Color(0xFFE53E3E); // Error Red
  static const Color powerInfo = Color(0xFF3182CE); // Info Blue
  
  // Neutral Colors
  static const Color powerBackground = Color(0xFFF7FAFC); // Light Gray
  static const Color powerSurface = Color(0xFFFFFFFF); // White
  static const Color powerOnSurface = Color(0xFF2D3748); // Dark Text
  static const Color powerOnBackground = Color(0xFF4A5568); // Medium Text

  /// Get Power Mode theme data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: powerPrimary,
        secondary: powerSecondary,
        tertiary: powerAccent,
        surface: powerSurface,
        background: powerBackground,
        error: powerError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: powerOnSurface,
        onBackground: powerOnBackground,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: powerPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: powerPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: powerPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: powerOnSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: powerOnSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: powerOnBackground,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: powerOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: powerPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: powerSurface,
      ),
    );
  }
}

/// Power Mode Data Card with detailed statistics
class PowerDataCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PowerDataCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: color ?? PowerModeTheme.powerPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color ?? PowerModeTheme.powerPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Power Mode Chart Widget for detailed analytics
class PowerChart extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final ChartType type;
  final String? xAxisLabel;
  final String? yAxisLabel;

  const PowerChart({
    super.key,
    required this.title,
    required this.data,
    required this.type,
    this.xAxisLabel,
    this.yAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
            if (xAxisLabel != null || yAxisLabel != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (xAxisLabel != null)
                    Text(
                      xAxisLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (yAxisLabel != null)
                    Text(
                      yAxisLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (type) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Text(
                    data[value.toInt()].label,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: PowerModeTheme.powerPrimary,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: PowerModeTheme.powerPrimary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Text(
                    data[value.toInt()].label,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                color: PowerModeTheme.powerPrimary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: data.map((item) {
          return PieChartSectionData(
            value: item.value,
            title: item.label,
            color: _getColorForIndex(data.indexOf(item)),
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      PowerModeTheme.powerPrimary,
      PowerModeTheme.powerAccent,
      PowerModeTheme.powerSuccess,
      PowerModeTheme.powerWarning,
      PowerModeTheme.powerError,
      PowerModeTheme.powerInfo,
    ];
    return colors[index % colors.length];
  }
}

/// Power Mode Data Table for detailed information
class PowerDataTable extends StatelessWidget {
  final String title;
  final List<TableColumn> columns;
  final List<Map<String, dynamic>> rows;
  final bool isSortable;
  final Function(String column, bool ascending)? onSort;

  const PowerDataTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.isSortable = false,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: columns.map((column) {
                  return DataColumn(
                    label: Text(
                      column.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onSort: isSortable ? (columnIndex, ascending) {
                      if (onSort != null) {
                        onSort!(column.key, ascending);
                      }
                    } : null,
                  );
                }).toList(),
                rows: rows.map((row) {
                  return DataRow(
                    cells: columns.map((column) {
                      return DataCell(
                        Text(
                          row[column.key]?.toString() ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Power Mode Filter Widget
class PowerFilter extends StatefulWidget {
  final List<FilterOption> options;
  final List<String> selectedValues;
  final Function(List<String>) onChanged;
  final String title;

  const PowerFilter({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.title,
  });

  @override
  State<PowerFilter> createState() => _PowerFilterState();
}

class _PowerFilterState extends State<PowerFilter> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.options.map((option) {
                final isSelected = widget.selectedValues.contains(option.value);
                return FilterChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        widget.selectedValues.add(option.value);
                      } else {
                        widget.selectedValues.remove(option.value);
                      }
                      widget.onChanged(List.from(widget.selectedValues));
                    });
                  },
                  selectedColor: PowerModeTheme.powerPrimary.withOpacity(0.2),
                  checkmarkColor: PowerModeTheme.powerPrimary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Power Mode Export Button
class PowerExportButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final ExportFormat format;

  const PowerExportButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.format = ExportFormat.csv,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: PowerModeTheme.powerPrimary,
        side: const BorderSide(color: PowerModeTheme.powerPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Power Mode Settings Toggle
class PowerSettingsToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const PowerSettingsToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: PowerModeTheme.powerPrimary)
            : null,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: PowerModeTheme.powerPrimary,
        ),
      ),
    );
  }
}

// ==================== DATA MODELS ====================

/// Chart data model
class ChartData {
  final String label;
  final double value;
  final Color? color;

  ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

/// Table column model
class TableColumn {
  final String key;
  final String label;
  final bool isNumeric;

  TableColumn({
    required this.key,
    required this.label,
    this.isNumeric = false,
  });
}

/// Filter option model
class FilterOption {
  final String value;
  final String label;

  FilterOption({
    required this.value,
    required this.label,
  });
}

/// Chart type enum
enum ChartType {
  line,
  bar,
  pie,
}

/// Export format enum
enum ExportFormat {
  csv,
  json,
  pdf,
  excel,
}
