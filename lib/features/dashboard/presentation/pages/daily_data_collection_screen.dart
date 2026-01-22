import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';

class DailyDataCollectionScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const DailyDataCollectionScreen({
    super.key,
    this.onComplete,
  });

  @override
  State<DailyDataCollectionScreen> createState() =>
      _DailyDataCollectionScreenState();
}

class _DailyDataCollectionScreenState
    extends State<DailyDataCollectionScreen> {
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadYesterdayData();
  }

  Future<void> _loadYesterdayData() async {
    final yesterdayData = await DailyDataService.getYesterdayData();
    if (yesterdayData != null) {
      _stepsController.text = (yesterdayData['steps'] ?? 0).toString();
      _caloriesController.text = (yesterdayData['calories'] ?? 0).toString();
      _sleepController.text = (yesterdayData['sleepHours'] ?? 0.0).toString();
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDarkBlueGreen,
              AppColors.backgroundDarkBlueGreen.withOpacity(0.98),
              AppColors.backgroundDarkBlueGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 360 ? 24 : 32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Daily Check-in',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Help us track your progress by sharing yesterday\'s data.',
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 14 : 16,
                      color: AppColors.textGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Steps Input
                  TextFormField(
                    controller: _stepsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Steps (yesterday)',
                      labelStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      hintText: '8000',
                      hintStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      prefixIcon: const Icon(
                        Icons.directions_walk,
                        color: AppColors.primaryGreen,
                      ),
                      suffixText: 'steps',
                      suffixStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundDarkLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGreen,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGreen,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter steps';
                      }
                      final steps = int.tryParse(value);
                      if (steps == null || steps < 0 || steps > 100000) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Calories Input
                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Calories Consumed (yesterday)',
                      labelStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      hintText: '2000',
                      hintStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      prefixIcon: const Icon(
                        Icons.local_fire_department,
                        color: AppColors.primaryGreen,
                      ),
                      suffixText: 'kcal',
                      suffixStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundDarkLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGreen,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGreen,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter calories';
                      }
                      final calories = int.tryParse(value);
                      if (calories == null || calories < 0 || calories > 10000) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Sleep Hours Input
                  TextFormField(
                    controller: _sleepController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Sleep Hours (yesterday)',
                      labelStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      hintText: '7.5',
                      hintStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      prefixIcon: const Icon(
                        Icons.bedtime,
                        color: AppColors.primaryGreen,
                      ),
                      suffixText: 'hours',
                      suffixStyle: const TextStyle(
                        color: AppColors.textGray,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundDarkLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGreen,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGreen,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter sleep hours';
                      }
                      final sleep = double.tryParse(value);
                      if (sleep == null || sleep < 0 || sleep > 24) {
                        return 'Please enter a valid number (0-24)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final yesterday = DateTime.now()
                              .subtract(const Duration(days: 1));
                          
                          final userId = await LocalStorageService.getUserId();
                          await DailyDataService.saveDailyData(
                            steps: int.parse(_stepsController.text),
                            calories: int.parse(_caloriesController.text),
                            sleepHours: double.parse(_sleepController.text),
                            date: yesterday,
                            userId: userId,
                          );

                          if (widget.onComplete != null) {
                            widget.onComplete!();
                          }
                          
                          if (mounted) {
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.textBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save & Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
