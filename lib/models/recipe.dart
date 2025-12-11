class Recipe {
  final String idMeal;
  final String strMeal;
  final String? strMealAlternate;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String strTags;
  final String strYoutube;
  final List<String> ingredients;
  final List<String> measures;

  Recipe({
    required this.idMeal,
    required this.strMeal,
    this.strMealAlternate,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.strTags,
    required this.strYoutube,
    required this.ingredients,
    required this.measures,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

  
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString());
        measures.add(measure != null && measure.toString().trim().isNotEmpty 
            ? measure.toString() 
            : '');
      }
    }

    return Recipe(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealAlternate: json['strMealAlternate'],
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strTags: json['strTags'] ?? '',
      strYoutube: json['strYoutube'] ?? '',
      ingredients: ingredients,
      measures: measures,
    );
  }

  List<Map<String, String>> getIngredients() {
    List<Map<String, String>> result = [];
    for (int i = 0; i < ingredients.length; i++) {
      result.add({
        'ingredient': ingredients[i],
        'measure': i < measures.length ? measures[i] : '',
      });
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strCategory': strCategory,
      'strArea': strArea,
      'strInstructions': strInstructions,
      'strMealThumb': strMealThumb,
      'strTags': strTags,
      'strYoutube': strYoutube,
    };

    if (strMealAlternate != null) {
      json['strMealAlternate'] = strMealAlternate;
    }

    for (int i = 0; i < ingredients.length; i++) {
      json['strIngredient${i + 1}'] = ingredients[i];
      if (i < measures.length) {
        json['strMeasure${i + 1}'] = measures[i];
      }
    }

    return json;
  }
}
