/// User's meal preferences for daily meal plan generation.
/// Collected in daily data collection; optional conditions default to false (NO).
/// [likedFoods] = foods user likes so AI can include them (e.g. rice, roti, biryani).
class MealPreferences {
  /// Mandatory: preferred cuisine (pakistani, desi, etc.).
  final String preferredCuisine;

  /// Foods the user likes to eat; AI should include these in suggestions.
  final List<String> likedFoods;

  final bool diabetes;
  final bool hypertension;
  final bool thyroidDisorder;
  final bool pcos;
  final bool heartDisease;
  final bool kidneyProblems;
  final bool liverProblems;
  final bool cholesterolIssues;
  final bool lactoseIntolerant;
  final bool glutenAllergy;
  final List<String> foodAllergies;

  const MealPreferences({
    this.preferredCuisine = 'general',
    this.likedFoods = const [],
    this.diabetes = false,
    this.hypertension = false,
    this.thyroidDisorder = false,
    this.pcos = false,
    this.heartDisease = false,
    this.kidneyProblems = false,
    this.liverProblems = false,
    this.cholesterolIssues = false,
    this.lactoseIntolerant = false,
    this.glutenAllergy = false,
    this.foodAllergies = const [],
  });

  List<String> get medicalConditionsForApi {
    final list = <String>[];
    if (diabetes) list.add('diabetes');
    if (hypertension) list.add('hypertension');
    if (thyroidDisorder) list.add('thyroid_disorder');
    if (pcos) list.add('pcos');
    if (heartDisease) list.add('heart_disease');
    if (kidneyProblems) list.add('kidney_problems');
    if (liverProblems) list.add('liver_problems');
    if (cholesterolIssues) list.add('cholesterol_issues');
    if (lactoseIntolerant) list.add('lactose_intolerant');
    if (glutenAllergy) list.add('gluten_allergy');
    return list;
  }

  List<String> get allergiesForApi {
    final list = List<String>.from(foodAllergies);
    if (glutenAllergy && !list.any((e) => e.toLowerCase().contains('gluten'))) {
      list.add('gluten');
    }
    return list;
  }

  Map<String, dynamic> toJson() => {
        'preferredCuisine': preferredCuisine,
        'likedFoods': likedFoods,
        'diabetes': diabetes,
        'hypertension': hypertension,
        'thyroidDisorder': thyroidDisorder,
        'pcos': pcos,
        'heartDisease': heartDisease,
        'kidneyProblems': kidneyProblems,
        'liverProblems': liverProblems,
        'cholesterolIssues': cholesterolIssues,
        'lactoseIntolerant': lactoseIntolerant,
        'glutenAllergy': glutenAllergy,
        'foodAllergies': foodAllergies,
      };

  factory MealPreferences.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MealPreferences();
    final fa = json['foodAllergies'];
    final lf = json['likedFoods'];
    return MealPreferences(
      preferredCuisine: json['preferredCuisine'] as String? ?? 'general',
      likedFoods: lf is List ? lf.map((e) => e.toString()).toList() : [],
      diabetes: json['diabetes'] as bool? ?? false,
      hypertension: json['hypertension'] as bool? ?? false,
      thyroidDisorder: json['thyroidDisorder'] as bool? ?? false,
      pcos: json['pcos'] as bool? ?? false,
      heartDisease: json['heartDisease'] as bool? ?? false,
      kidneyProblems: json['kidneyProblems'] as bool? ?? false,
      liverProblems: json['liverProblems'] as bool? ?? false,
      cholesterolIssues: json['cholesterolIssues'] as bool? ?? false,
      lactoseIntolerant: json['lactoseIntolerant'] as bool? ?? false,
      glutenAllergy: json['glutenAllergy'] as bool? ?? false,
      foodAllergies: fa is List ? fa.map((e) => e.toString()).toList() : [],
    );
  }
}
