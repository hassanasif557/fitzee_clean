import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';
import 'package:fitzee_new/core/models/medical_entry.dart';
import 'package:fitzee_new/core/services/connectivity_service.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/daily_nutrition_service.dart';
import 'package:fitzee_new/core/services/firestore_workout_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/medical_entry_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textGray,
          tabs: const [
            Tab(text: 'Nutrition'),
            Tab(text: 'Medical'),
            Tab(text: 'Workout'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NutritionHistoryTab(),
          _MedicalHistoryTab(),
          _WorkoutHistoryTab(),
        ],
      ),
    );
  }
}

class _NutritionHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FoodEntry>>(
      future: DailyNutritionService.getAllFoodEntries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }
        final entries = snapshot.data!;
        if (entries.isEmpty) {
          return const Center(
            child: Text(
              'No nutrition entries yet.\nAdd meals from the dashboard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }
        final byDate = <String, List<FoodEntry>>{};
        for (final e in entries) {
          final key = _formatDate(e.date);
          byDate.putIfAbsent(key, () => []).add(e);
        }
        final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dates.length,
          itemBuilder: (context, i) {
            final dateKey = dates[i];
            final dayEntries = byDate[dateKey]!;
            final date = DateTime.parse(dateKey);
            final total = FoodNutrition.sum(dayEntries.map((e) => e.nutrition).toList());
            return _DayCard(
              title: DateFormat('EEE, MMM d, yyyy').format(date),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...dayEntries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${e.mealType[0].toUpperCase()}${e.mealType.substring(1)}: ${e.foodName}',
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${e.nutrition.calories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const Divider(color: AppColors.textGray, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Day total', style: TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w600)),
                      Text(
                        '${total.calories.toStringAsFixed(0)} kcal • P ${total.protein.toStringAsFixed(0)}g C ${total.carbs.toStringAsFixed(0)}g F ${total.fat.toStringAsFixed(0)}g',
                        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _MedicalHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadMedicalData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }
        final data = snapshot.data!;
        final dateKeys = data['dateKeys'] as List<String>;
        final dailyByDate = data['dailyByDate'] as Map<String, Map<String, dynamic>>;
        final entriesByDate = data['entriesByDate'] as Map<String, List<MedicalEntry>>;
        if (dateKeys.isEmpty) {
          return const Center(
            child: Text(
              'No medical data yet.\nAdd medical info from Today\'s Medical Info or Daily Check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dateKeys.length,
          itemBuilder: (context, i) {
            final dateKey = dateKeys[i];
            final date = DateTime.parse(dateKey);
            final daily = dailyByDate[dateKey];
            final entries = entriesByDate[dateKey] ?? [];
            final children = <Widget>[];
            if (daily != null) {
              if (daily['bloodSugar'] != null) {
                children.add(Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Blood sugar: ${(daily['bloodSugar'] as num).toStringAsFixed(0)} mg/dL (Daily check-in)',
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                  ),
                ));
              }
              if (daily['bloodPressureSystolic'] != null && daily['bloodPressureDiastolic'] != null) {
                children.add(Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'BP: ${daily['bloodPressureSystolic']}/${daily['bloodPressureDiastolic']} mmHg (Daily check-in)',
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                  ),
                ));
              }
            }
            for (final e in entries) {
              children.add(Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('jm').format(e.dateTime)} — ',
                      style: const TextStyle(color: AppColors.textGray, fontSize: 13),
                    ),
                    Expanded(
                      child: Text(
                        '${e.label}: ${e.displayValue}',
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ));
            }
            return _DayCard(
              title: DateFormat('EEE, MMM d, yyyy').format(date),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            );
          },
        );
      },
    );
  }

  static Future<Map<String, dynamic>> _loadMedicalData() async {
    final dailyAll = await DailyDataService.getDailyDataMap();
    final dailyWithMedical = dailyAll.entries.where((e) {
      final d = e.value;
      return d['bloodSugar'] != null ||
          d['bloodPressureSystolic'] != null ||
          d['bloodPressureDiastolic'] != null;
    }).toList();
    final entriesByDate = await MedicalEntryService.getEntriesGroupedByDate();
    final dateSet = <String>{};
    for (final e in dailyWithMedical) dateSet.add(e.key);
    for (final k in entriesByDate.keys) dateSet.add(k);
    final dateKeys = dateSet.toList()..sort((a, b) => b.compareTo(a));
    final dailyByDate = {for (final e in dailyWithMedical) e.key: e.value};
    return {
      'dateKeys': dateKeys,
      'dailyByDate': dailyByDate,
      'entriesByDate': entriesByDate,
    };
  }
}

class _WorkoutHistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: _loadWorkoutData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }
        final all = snapshot.data!;
        final entries = all.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
        if (entries.isEmpty) {
          return const Center(
            child: Text(
              'No workout data yet.\nAdd steps & exercise in Daily Check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final dateKey = entries[i].key;
            final d = entries[i].value;
            final date = DateTime.parse(dateKey);
            final steps = (d['steps'] as num?)?.toInt() ?? 0;
            final exerciseMinutes = (d['exerciseMinutes'] as num?)?.toInt();
            final caloriesBurned = (d['caloriesBurned'] as num?)?.toInt();
            return _DayCard(
              title: DateFormat('EEE, MMM d, yyyy').format(date),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Steps', '$steps'),
                  if (exerciseMinutes != null) _row('Exercise minutes', '$exerciseMinutes min'),
                  if (caloriesBurned != null) _row('Calories burned', '$caloriesBurned kcal'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Load workout data: from Firestore workout collection when online, else from local daily data.
  static Future<Map<String, Map<String, dynamic>>> _loadWorkoutData() async {
    final hasInternet = await ConnectivityService.hasInternetConnection();
    if (hasInternet) {
      try {
        final userId = await LocalStorageService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          final fromFirestore =
              await FirestoreWorkoutService.getAllWorkoutData(userId);
          if (fromFirestore.isNotEmpty) return fromFirestore;
        }
      } catch (e) {
        // ignore
      }
    }
    return DailyDataService.getAllDailyData();
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DayCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkBlueGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreenDark.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
