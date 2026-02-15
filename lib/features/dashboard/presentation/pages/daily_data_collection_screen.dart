import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/models/meal_preferences.dart';
import 'package:fitzee_new/core/services/daily_data_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/meal_preferences_service.dart';

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
  final TextEditingController _bloodSugarController = TextEditingController();
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _exerciseMinutesController = TextEditingController();
  final TextEditingController _caloriesBurnedController = TextEditingController();
  final TextEditingController _foodAllergiesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Pakistan-first cuisine options
  static const List<String> _cuisineOptions = [
    'pakistani',
    'desi',
    'general',
    'indian',
    'asian',
    'chinese',
    'arabic',
    'mediterranean',
    'western',
    'latin_american',
  ];
  static const Map<String, String> _cuisineLabels = {
    'pakistani': 'Pakistani',
    'desi': 'Desi (South Asian)',
    'general': 'General',
    'indian': 'Indian',
    'asian': 'Asian',
    'chinese': 'Chinese',
    'arabic': 'Arabic',
    'mediterranean': 'Mediterranean',
    'western': 'Western',
    'latin_american': 'Latin American',
  };

  /// Foods user likes — AI will include these in meal plans (Pakistan-friendly options).
  static const List<String> _likedFoodOptions = [
    'rice',
    'wheat_bread_roti_naan',
    'daal',
    'biryani',
    'karahi',
    'curry',
    'chicken_dishes',
    'beef_mutton',
    'vegetables',
    'salads',
    'fast_food',
    'eggs',
    'yogurt_dahi',
    'paratha',
    'halwa_sweet',
    'kheer',
    'qorma',
    'kebabs',
    'pakora_samosa',
    'desi_breakfast',
  ];
  static const Map<String, String> _likedFoodLabels = {
    'rice': 'Rice',
    'wheat_bread_roti_naan': 'Roti / Naan',
    'daal': 'Daal',
    'biryani': 'Biryani',
    'karahi': 'Karahi',
    'curry': 'Curry',
    'chicken_dishes': 'Chicken dishes',
    'beef_mutton': 'Beef / Mutton',
    'vegetables': 'Vegetables',
    'salads': 'Salads',
    'fast_food': 'Fast food',
    'eggs': 'Eggs',
    'yogurt_dahi': 'Dahi (Yogurt)',
    'paratha': 'Paratha',
    'halwa_sweet': 'Halwa & sweets',
    'kheer': 'Kheer',
    'qorma': 'Qorma',
    'kebabs': 'Kebabs',
    'pakora_samosa': 'Pakora / Samosa',
    'desi_breakfast': 'Desi breakfast',
  };

  String _preferredCuisine = 'pakistani';
  List<String> _likedFoods = [];
  bool _diabetes = false;
  bool _hypertension = false;
  bool _thyroidDisorder = false;
  bool _pcos = false;
  bool _heartDisease = false;
  bool _kidneyProblems = false;
  bool _liverProblems = false;
  bool _cholesterolIssues = false;
  bool _lactoseIntolerant = false;
  bool _glutenAllergy = false;

  @override
  void initState() {
    super.initState();
    _loadYesterdayData();
    _loadMealPreferences();
  }

  Future<void> _loadMealPreferences() async {
    final prefs = await MealPreferencesService.load();
    if (!mounted) return;
    setState(() {
      _preferredCuisine = _cuisineOptions.contains(prefs.preferredCuisine) ? prefs.preferredCuisine : 'pakistani';
      _likedFoods = List<String>.from(prefs.likedFoods);
      _diabetes = prefs.diabetes;
      _hypertension = prefs.hypertension;
      _thyroidDisorder = prefs.thyroidDisorder;
      _pcos = prefs.pcos;
      _heartDisease = prefs.heartDisease;
      _kidneyProblems = prefs.kidneyProblems;
      _liverProblems = prefs.liverProblems;
      _cholesterolIssues = prefs.cholesterolIssues;
      _lactoseIntolerant = prefs.lactoseIntolerant;
      _glutenAllergy = prefs.glutenAllergy;
      _foodAllergiesController.text = prefs.foodAllergies.join(', ');
    });
  }

  Future<void> _loadYesterdayData() async {
    final yesterdayData = await DailyDataService.getYesterdayData();
    if (yesterdayData != null) {
      _stepsController.text = (yesterdayData['steps'] ?? 0).toString();
      _caloriesController.text = (yesterdayData['calories'] ?? 0).toString();
      _sleepController.text = (yesterdayData['sleepHours'] ?? 0.0).toString();
      if (yesterdayData['bloodSugar'] != null) _bloodSugarController.text = (yesterdayData['bloodSugar'] as num).toString();
      if (yesterdayData['bloodPressureSystolic'] != null) _bpSystolicController.text = (yesterdayData['bloodPressureSystolic'] as int).toString();
      if (yesterdayData['bloodPressureDiastolic'] != null) _bpDiastolicController.text = (yesterdayData['bloodPressureDiastolic'] as int).toString();
      if (yesterdayData['exerciseMinutes'] != null) _exerciseMinutesController.text = (yesterdayData['exerciseMinutes'] as int).toString();
      if (yesterdayData['caloriesBurned'] != null) _caloriesBurnedController.text = (yesterdayData['caloriesBurned'] as int).toString();
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _sleepController.dispose();
    _bloodSugarController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _exerciseMinutesController.dispose();
    _caloriesBurnedController.dispose();
    _foodAllergiesController.dispose();
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
                  const SizedBox(height: 24),
                  const Text(
                    'Optional — Medical & Workout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bloodSugarController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Blood sugar (mg/dL) — optional',
                      labelStyle: const TextStyle(color: AppColors.textGray),
                      hintText: 'e.g. 100',
                      hintStyle: const TextStyle(color: AppColors.textGray),
                      prefixIcon: const Icon(Icons.bloodtype, color: AppColors.primaryGreen, size: 20),
                      filled: true,
                      fillColor: AppColors.backgroundDarkLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bpSystolicController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            labelText: 'BP Systolic — optional',
                            labelStyle: const TextStyle(color: AppColors.textGray),
                            hintText: '120',
                            filled: true,
                            fillColor: AppColors.backgroundDarkLight,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _bpDiastolicController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            labelText: 'BP Diastolic — optional',
                            labelStyle: const TextStyle(color: AppColors.textGray),
                            hintText: '80',
                            filled: true,
                            fillColor: AppColors.backgroundDarkLight,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _exerciseMinutesController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Exercise minutes — optional',
                      labelStyle: const TextStyle(color: AppColors.textGray),
                      hintText: 'e.g. 30',
                      prefixIcon: const Icon(Icons.fitness_center, color: AppColors.primaryGreen, size: 20),
                      filled: true,
                      fillColor: AppColors.backgroundDarkLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _caloriesBurnedController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: InputDecoration(
                      labelText: 'Calories burned (exercise) — optional',
                      labelStyle: const TextStyle(color: AppColors.textGray),
                      hintText: 'e.g. 300',
                      prefixIcon: const Icon(Icons.local_fire_department, color: AppColors.primaryGreen, size: 20),
                      suffixText: 'kcal',
                      suffixStyle: const TextStyle(color: AppColors.textGray),
                      filled: true,
                      fillColor: AppColors.backgroundDarkLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildMealPreferencesSection(screenWidth),
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

                          final foodAllergiesText = _foodAllergiesController.text.trim();
                          final foodAllergies = foodAllergiesText.isEmpty
                              ? <String>[]
                              : foodAllergiesText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                          await MealPreferencesService.save(MealPreferences(
                            preferredCuisine: _preferredCuisine,
                            likedFoods: _likedFoods,
                            diabetes: _diabetes,
                            hypertension: _hypertension,
                            thyroidDisorder: _thyroidDisorder,
                            pcos: _pcos,
                            heartDisease: _heartDisease,
                            kidneyProblems: _kidneyProblems,
                            liverProblems: _liverProblems,
                            cholesterolIssues: _cholesterolIssues,
                            lactoseIntolerant: _lactoseIntolerant,
                            glutenAllergy: _glutenAllergy,
                            foodAllergies: foodAllergies,
                          ));

                          final userId = await LocalStorageService.getUserId();
                          final bloodSugar = double.tryParse(_bloodSugarController.text.trim());
                          final bpSystolic = int.tryParse(_bpSystolicController.text.trim());
                          final bpDiastolic = int.tryParse(_bpDiastolicController.text.trim());
                          final exerciseMinutes = int.tryParse(_exerciseMinutesController.text.trim());
                          final caloriesBurned = int.tryParse(_caloriesBurnedController.text.trim());
                          await DailyDataService.saveDailyData(
                            steps: int.parse(_stepsController.text),
                            calories: int.parse(_caloriesController.text),
                            sleepHours: double.parse(_sleepController.text),
                            date: yesterday,
                            userId: userId,
                            bloodSugar: bloodSugar,
                            bloodPressureSystolic: bpSystolic,
                            bloodPressureDiastolic: bpDiastolic,
                            exerciseMinutes: exerciseMinutes,
                            caloriesBurned: caloriesBurned,
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

  Widget _buildMealPreferencesSection(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_rounded, color: AppColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Meal preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Used to suggest today’s meal plan. Optional items default to No.',
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preferred cuisine (required)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _cuisineOptions.contains(_preferredCuisine) ? _preferredCuisine : _cuisineOptions.first,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
            ),
            dropdownColor: AppColors.backgroundDarkLight,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
            items: _cuisineOptions.map((e) => DropdownMenuItem(value: e, child: Text(_cuisineLabels[e] ?? e))).toList(),
            onChanged: (v) => setState(() => _preferredCuisine = v ?? 'pakistani'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Foods you like to eat (optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select foods you enjoy — we’ll include them in your meal plan.',
            style: TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _likedFoodOptions.map((key) {
              final selected = _likedFoods.contains(key);
              return FilterChip(
                label: Text(_likedFoodLabels[key] ?? key),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) _likedFoods = [..._likedFoods, key];
                    else _likedFoods = _likedFoods.where((e) => e != key).toList();
                  });
                },
                selectedColor: AppColors.primaryGreen.withOpacity(0.4),
                checkmarkColor: AppColors.primaryGreen,
                backgroundColor: AppColors.backgroundDark.withOpacity(0.6),
                side: BorderSide(
                  color: selected ? AppColors.primaryGreen : AppColors.borderGreen.withOpacity(0.6),
                ),
                labelStyle: TextStyle(
                  color: selected ? AppColors.textWhite : AppColors.textGray,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Optional — health & diet (default: No)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGray),
          ),
          const SizedBox(height: 10),
          _switchRow('Diabetes', _diabetes, (v) => setState(() => _diabetes = v)),
          _switchRow('High blood pressure (hypertension)', _hypertension, (v) => setState(() => _hypertension = v)),
          _switchRow('Thyroid disorder', _thyroidDisorder, (v) => setState(() => _thyroidDisorder = v)),
          _switchRow('PCOS / PCOD', _pcos, (v) => setState(() => _pcos = v)),
          _switchRow('Heart disease', _heartDisease, (v) => setState(() => _heartDisease = v)),
          _switchRow('Kidney problems', _kidneyProblems, (v) => setState(() => _kidneyProblems = v)),
          _switchRow('Liver problems', _liverProblems, (v) => setState(() => _liverProblems = v)),
          _switchRow('Cholesterol issues', _cholesterolIssues, (v) => setState(() => _cholesterolIssues = v)),
          _switchRow('Lactose intolerant', _lactoseIntolerant, (v) => setState(() => _lactoseIntolerant = v)),
          _switchRow('Gluten allergy (celiac disease)', _glutenAllergy, (v) => setState(() => _glutenAllergy = v)),
          const SizedBox(height: 14),
          const Text(
            'Any food allergies? (e.g. nuts, seafood, eggs)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGray),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _foodAllergiesController,
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: 'Comma separated, optional',
              hintStyle: const TextStyle(color: AppColors.textGray),
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderGreen)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textWhite),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}
