import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/progress_tracking_service.dart';
import 'package:fitzee_new/core/services/user_profile_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/health_score_service.dart';
import 'package:fitzee_new/features/onboard/domain/entities/user_profile.dart';

class ProgressReportScreen extends StatefulWidget {
  const ProgressReportScreen({super.key});

  @override
  State<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> with SingleTickerProviderStateMixin {
  UserProfile? _userProfile;
  List<Map<String, dynamic>> _progressData = [];
  List<Map<String, dynamic>> _healthScoreData = [];
  Map<String, dynamic>? _trends;
  List<String> _suggestions = [];
  bool _isLoading = true;
  int _selectedDays = 7; // 7, 14, 30
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await LocalStorageService.getUserId();
      final profile = await UserProfileService.getUserProfile(userId);

      final progressData = await ProgressTrackingService.getProgressData(_selectedDays);
      final healthScoreData = await ProgressTrackingService.getHealthScoreProgress(profile, _selectedDays);
      final trends = await ProgressTrackingService.calculateTrends(_selectedDays);
      final suggestions = await ProgressTrackingService.generateSuggestions(profile, _selectedDays);

      setState(() {
        _userProfile = profile;
        _progressData = progressData;
        _healthScoreData = healthScoreData;
        _trends = trends;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      print('Progress Report: Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDarkBlueGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Progress Report',
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Days selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildDayButton(7, '7D'),
                const SizedBox(width: 4),
                _buildDayButton(14, '14D'),
                const SizedBox(width: 4),
                _buildDayButton(30, '30D'),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Charts'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildChartsTab(),
                _buildInsightsTab(),
              ],
            ),
    );
  }

  Widget _buildDayButton(int days, String label) {
    final isSelected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.textGray,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textBlack : AppColors.textWhite,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_trends == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Steps',
                  '${_trends!['stepsAverage']}',
                  'avg/day',
                  Icons.directions_walk,
                  _trends!['stepsTrend'] > 0 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Calories',
                  '${_trends!['caloriesAverage']}',
                  'avg/day',
                  Icons.local_fire_department,
                  _trends!['caloriesTrend'] > 0 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Sleep',
                  '${_trends!['sleepAverage'].toStringAsFixed(1)}h',
                  'avg/night',
                  Icons.bedtime,
                  _trends!['sleepTrend'] > 0 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Consistency',
                  '${_trends!['consistency'].toStringAsFixed(0)}%',
                  'logged',
                  Icons.check_circle,
                  _trends!['consistency'] >= 80 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Health Score Summary
          if (_healthScoreData.isNotEmpty)
            _buildHealthScoreSummary(),
          const SizedBox(height: 24),
          // Best/Worst Days
          _buildBestWorstSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color trendColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 24),
              if (trendColor == Colors.green)
                const Icon(Icons.trending_up, color: Colors.green, size: 16)
              else
                const Icon(Icons.trending_down, color: Colors.orange, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreSummary() {
    final validScores = _healthScoreData.where((s) => s['score'] != null).toList();
    if (validScores.isEmpty) return const SizedBox.shrink();

    final avgScore = (validScores.fold<int>(0, (sum, s) => sum + (s['score'] as int)) / validScores.length).round();
    final label = HealthScoreService.getScoreLabel(avgScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Score Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '$avgScore',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getScoreLabelColor(avgScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Average',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.textGray.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    '${validScores.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Days',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tracked',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
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

  Widget _buildBestWorstSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best & Worst Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBestWorstCard(
                  'Best Steps',
                  '${_trends!['stepsBest']}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBestWorstCard(
                  'Worst Steps',
                  '${_trends!['stepsWorst']}',
                  Icons.trending_down,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBestWorstCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Steps Chart
          _buildChartCard(
            'Steps Progress',
            Icons.directions_walk,
            _buildStepsChart(),
          ),
          const SizedBox(height: 16),
          // Calories Chart
          _buildChartCard(
            'Calories Progress',
            Icons.local_fire_department,
            _buildCaloriesChart(),
          ),
          const SizedBox(height: 16),
          // Sleep Chart
          _buildChartCard(
            'Sleep Progress',
            Icons.bedtime,
            _buildSleepChart(),
          ),
          const SizedBox(height: 16),
          // Health Score Chart
          if (_healthScoreData.isNotEmpty)
            _buildChartCard(
              'Health Score Trend',
              Icons.favorite,
              _buildHealthScoreChart(),
            ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, IconData icon, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildStepsChart() {
    final spots = _progressData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final steps = (entry.value['steps'] as int).toDouble();
      return FlSpot(index, steps);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textGray.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % (_selectedDays ~/ 3) == 0 && value.toInt() < _progressData.length) {
                  final date = _progressData[value.toInt()]['date'] as DateTime;
                  return Text(
                    DateFormat('MMM d').format(date),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(1)}k',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryGreen.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2,
      ),
    );
  }

  Widget _buildCaloriesChart() {
    final spots = _progressData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final calories = (entry.value['calories'] as int).toDouble();
      return FlSpot(index, calories);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 200,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textGray.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % (_selectedDays ~/ 3) == 0 && value.toInt() < _progressData.length) {
                  final date = _progressData[value.toInt()]['date'] as DateTime;
                  return Text(
                    DateFormat('MMM d').format(date),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2,
      ),
    );
  }

  Widget _buildSleepChart() {
    final spots = _progressData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final sleep = (entry.value['sleepHours'] as double);
      return FlSpot(index, sleep);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textGray.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % (_selectedDays ~/ 3) == 0 && value.toInt() < _progressData.length) {
                  final date = _progressData[value.toInt()]['date'] as DateTime;
                  return Text(
                    DateFormat('MMM d').format(date),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 12,
      ),
    );
  }

  Widget _buildHealthScoreChart() {
    final validScores = _healthScoreData.where((s) => s['score'] != null).toList();
    if (validScores.isEmpty) {
      return const Center(
        child: Text(
          'No health score data available',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    final spots = validScores.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final score = (entry.value['score'] as int).toDouble();
      return FlSpot(index, score);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textGray.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < validScores.length && value.toInt() % (_selectedDays ~/ 3) == 0) {
                  final date = validScores[value.toInt()]['date'] as DateTime;
                  return Text(
                    DateFormat('MMM d').format(date),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryGreen.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 100,
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggestions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundDarkLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Personalized Suggestions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._suggestions.map((suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textWhite,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Trends Analysis
          if (_trends != null) _buildTrendsAnalysis(),
        ],
      ),
    );
  }

  Widget _buildTrendsAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trend Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 16),
          _buildTrendItem(
            'Steps',
            _trends!['stepsTrend'] as int,
            _trends!['stepsAverage'] as int,
          ),
          const SizedBox(height: 12),
          _buildTrendItem(
            'Calories',
            _trends!['caloriesTrend'] as int,
            _trends!['caloriesAverage'] as int,
          ),
          const SizedBox(height: 12),
          _buildTrendItem(
            'Sleep',
            ((_trends!['sleepTrend'] as double) * 10).round() / 10,
            _trends!['sleepAverage'] as double,
            isSleep: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String label, num trend, num average, {bool isSleep = false}) {
    final isPositive = trend > 0;
    final trendText = isPositive ? '+${trend.toStringAsFixed(isSleep ? 1 : 0)}' : trend.toStringAsFixed(isSleep ? 1 : 0);
    final unit = isSleep ? 'h' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textWhite,
          ),
        ),
        Row(
          children: [
            Text(
              'Avg: ${average.toStringAsFixed(isSleep ? 1 : 0)}$unit',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: isPositive ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendText + unit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreLabelColor(int score) {
    if (score >= 90) {
      return AppColors.primaryGreen;
    } else if (score >= 75) {
      return Colors.lightGreen;
    } else if (score >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
