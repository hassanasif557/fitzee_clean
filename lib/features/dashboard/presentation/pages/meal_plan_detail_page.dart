import 'package:flutter/material.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/models/daily_meal_plan.dart';

/// Shows details of a single meal (breakfast, lunch, or dinner) from the daily suggested plan.
/// User can tap "Change meal" to pick one of the suggested alternatives.
class MealPlanDetailPage extends StatefulWidget {
  final String mealType;
  final MealSlot meal;

  const MealPlanDetailPage({
    super.key,
    required this.mealType,
    required this.meal,
  });

  @override
  State<MealPlanDetailPage> createState() => _MealPlanDetailPageState();
}

class _MealPlanDetailPageState extends State<MealPlanDetailPage> {
  /// Currently displayed meal description (original or user-selected alternative).
  late String _displayedDescription;
  /// True when user has chosen an alternative (show a small note).
  bool _isReplacement = false;

  @override
  void initState() {
    super.initState();
    _displayedDescription = widget.meal.description;
  }

  void _showChangeMealSheet() {
    final options = [
      _Option(label: 'Original suggestion', description: widget.meal.description, isOriginal: true),
      ...widget.meal.alternatives.map((alt) => _Option(label: 'Alternative', description: alt, isOriginal: false)),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundDarkLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose a meal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select one option for ${widget.mealType}',
                style: TextStyle(fontSize: 13, color: AppColors.textGray),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: options.length,
                itemBuilder: (ctx, i) {
                  final opt = options[i];
                  final isSelected = _displayedDescription == opt.description;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isSelected
                          ? AppColors.primaryGreen.withOpacity(0.25)
                          : AppColors.backgroundDark.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _displayedDescription = opt.description;
                            _isReplacement = !opt.isOriginal;
                          });
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                opt.isOriginal ? Icons.restaurant_rounded : Icons.swap_horiz_rounded,
                                color: AppColors.primaryGreen,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (opt.isOriginal)
                                      Text(
                                        'Original suggestion',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      opt.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: AppColors.textWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.mealType,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              if (meal.calories > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${meal.calories} cal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
              if (_displayedDescription.isNotEmpty) ...[
                const SizedBox(height: 20),
                if (_isReplacement) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'You chose this replacement',
                          style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
                const Text(
                  'Meal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _displayedDescription,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
              if (meal.reason.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Why we suggest this',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    meal.reason,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
              if (meal.precautions.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Healthy tips & precautions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Follow these for a healthier choice (e.g. portion control, less oil):',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 10),
                ...meal.precautions.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.health_and_safety_rounded,
                          size: 20,
                          color: AppColors.primaryGreen.withOpacity(0.9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textWhite,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (meal.alternatives.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Replacements (if you want something else)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                ...meal.alternatives.map(
                  (alt) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 20,
                          color: AppColors.primaryGreen.withOpacity(0.9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            alt,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textWhite,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (meal.ingredients.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                ...meal.ingredients.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textWhite,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (meal.instructions.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meal.instructions,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (meal.alternatives.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showChangeMealSheet,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                    label: const Text('Change meal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Pick a different option for this meal',
                    style: TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option {
  final String label;
  final String description;
  final bool isOriginal;

  _Option(
      {required this.label, required this.description, required this.isOriginal});
}
