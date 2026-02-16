import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/nutrition_database_service.dart';
import 'package:fitzee_new/core/services/daily_nutrition_service.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/core/services/notification_service.dart';
import 'package:fitzee_new/core/models/food_item.dart';
import 'package:fitzee_new/core/models/food_nutrition.dart';

class MealEntryScreen extends StatefulWidget {
  final DateTime? date;
  final String? mealType;

  const MealEntryScreen({
    super.key,
    this.date,
    this.mealType,
  });

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _filteredFoods = [];
  FoodItem? _selectedFood;
  String? _selectedPortion;
  String? _selectedMealType;
  FoodNutrition? _calculatedNutrition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType ?? 'breakfast';
    _loadFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFoods() {
    setState(() {
      _filteredFoods = NutritionDatabaseService.getAllFoods();
    });
  }

  void _searchFoods(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFoods = NutritionDatabaseService.getAllFoods();
      } else {
        _filteredFoods = NutritionDatabaseService.searchFoods(query);
      }
    });
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _selectedFood = food;
      _selectedPortion = null;
      _calculatedNutrition = null;
    });
  }

  void _selectPortion(String portion) {
    if (_selectedFood == null) return;

    setState(() {
      _selectedPortion = portion;
      final grams = NutritionDatabaseService.getPortionGrams(portion);
      if (grams != null) {
        _calculatedNutrition = _selectedFood!.nutritionPer100g.calculateForGrams(grams);
      }
    });
  }

  Future<void> _saveEntry() async {
    if (_selectedFood == null || _selectedPortion == null || _calculatedNutrition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select food and portion'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final grams = NutritionDatabaseService.getPortionGrams(_selectedPortion!)!;
      final entry = FoodEntry(
        foodId: _selectedFood!.id,
        foodName: _selectedFood!.name,
        portionType: _selectedPortion!,
        grams: grams,
        nutrition: _calculatedNutrition!,
        date: widget.date ?? DateTime.now(),
        mealType: _selectedMealType!,
      );

      final userId = await LocalStorageService.getUserId();
      await DailyNutritionService.saveFoodEntry(entry, userId: userId);

      NotificationService.showMealAddedNotification(
        mealType: _selectedMealType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food entry saved successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openCustomItemSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDarkLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CustomFoodSheet(
        mealType: _selectedMealType!,
        date: widget.date ?? DateTime.now(),
        onSaved: () {
          Navigator.of(ctx).pop();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Custom food entry saved!'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
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
          'Add Meal',
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Meal Type Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildMealTypeButton('breakfast', 'Breakfast', Icons.wb_sunny),
                    const SizedBox(width: 8),
                    _buildMealTypeButton('lunch', 'Lunch', Icons.lunch_dining),
                    const SizedBox(width: 8),
                    _buildMealTypeButton('dinner', 'Dinner', Icons.dinner_dining),
                    const SizedBox(width: 8),
                    _buildMealTypeButton('snack', 'Snack', Icons.cookie),
                  ],
                ),
              ),
              // Add custom item button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: _openCustomItemSheet,
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
                  label: const Text(
                    'Add custom item (name + kcal)',
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchFoods,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Search food...',
                    hintStyle: const TextStyle(color: AppColors.textGray),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textGray),
                    filled: true,
                    fillColor: AppColors.backgroundDarkLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Food List
              Expanded(
                child: _filteredFoods.isEmpty
                    ? const Center(
                        child: Text(
                          'No foods found',
                          style: TextStyle(color: AppColors.textGray),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 0,
                          bottom: _selectedFood != null ? 300 : 16,
                        ),
                        itemCount: _filteredFoods.length,
                        itemBuilder: (context, index) {
                          final food = _filteredFoods[index];
                          final isSelected = _selectedFood?.id == food.id;
                          return _buildFoodItem(food, isSelected);
                        },
                      ),
              ),
            ],
          ),
          // Selected Food & Portion - Positioned at bottom
          if (_selectedFood != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSelectionCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildMealTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedMealType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMealType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.backgroundDarkLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.textBlack : AppColors.textGray, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.textBlack : AppColors.textGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItem(FoodItem food, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectFood(food),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.3) : AppColors.backgroundDarkLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${food.nutritionPer100g.calories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Text(
                  'per 100g',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Selected: ${_selectedFood!.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 16),
          // Portion Selection
          const Text(
            'Select Portion:',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NutritionDatabaseService.getPortionTypes().map((portion) {
              final isSelected = _selectedPortion == portion;
              return GestureDetector(
                onTap: () => _selectPortion(portion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : AppColors.backgroundDarkBlueGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : AppColors.textGray,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    portion.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.textBlack : AppColors.textWhite,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // Nutrition Display
          if (_calculatedNutrition != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDarkBlueGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nutrition:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionItem('Calories', '${_calculatedNutrition!.calories.toStringAsFixed(0)}', 'kcal'),
                      _buildNutritionItem('Protein', '${_calculatedNutrition!.protein.toStringAsFixed(1)}', 'g'),
                      _buildNutritionItem('Carbs', '${_calculatedNutrition!.carbs.toStringAsFixed(1)}', 'g'),
                      _buildNutritionItem('Fat', '${_calculatedNutrition!.fat.toStringAsFixed(1)}', 'g'),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.textBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.textBlack)
                  : const Text(
                      'Save Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$label ($unit)',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for adding a custom food item with name and kcal (and optional macros).
class _CustomFoodSheet extends StatefulWidget {
  final String mealType;
  final DateTime date;
  final VoidCallback onSaved;

  const _CustomFoodSheet({
    required this.mealType,
    required this.date,
    required this.onSaved,
  });

  @override
  State<_CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends State<_CustomFoodSheet> {
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter item name'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    final kcal = double.tryParse(_kcalController.text.trim());
    if (kcal == null || kcal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid kcal value'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    final protein = double.tryParse(_proteinController.text.trim()) ?? 0;
    final carbs = double.tryParse(_carbsController.text.trim()) ?? 0;
    final fat = double.tryParse(_fatController.text.trim()) ?? 0;

    setState(() => _saving = true);
    try {
      final nutrition = FoodNutrition(
        calories: kcal,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
      final entry = FoodEntry(
        foodId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        foodName: name,
        portionType: 'custom',
        grams: 100,
        nutrition: nutrition,
        date: widget.date,
        mealType: widget.mealType,
      );
      final userId = await LocalStorageService.getUserId();
      await DailyNutritionService.saveFoodEntry(entry, userId: userId);
      if (mounted) widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add custom item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meal: ${widget.mealType[0].toUpperCase()}${widget.mealType.substring(1)}',
              style: const TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item name *',
                hintText: 'e.g. Homemade cake',
                labelStyle: const TextStyle(color: AppColors.textGray),
                hintStyle: const TextStyle(color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.backgroundDarkBlueGreen,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textWhite),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kcalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories (kcal) *',
                hintText: 'e.g. 350',
                labelStyle: const TextStyle(color: AppColors.textGray),
                hintStyle: const TextStyle(color: AppColors.textGray),
                filled: true,
                fillColor: AppColors.backgroundDarkBlueGreen,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textWhite),
            ),
            const SizedBox(height: 16),
            const Text(
              'Optional macros (grams)',
              style: TextStyle(color: AppColors.textGray, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Protein',
                      filled: true,
                      fillColor: AppColors.backgroundDarkBlueGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: AppColors.textWhite),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Carbs',
                      filled: true,
                      fillColor: AppColors.backgroundDarkBlueGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: AppColors.textWhite),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _fatController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Fat',
                      filled: true,
                      fillColor: AppColors.backgroundDarkBlueGreen,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: AppColors.textWhite),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textBlack),
                      )
                    : const Text('Save custom entry', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
