import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_recipes';

  Future<List<Recipe>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson
          .map((jsonString) => Recipe.fromJson(json.decode(jsonString)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isFavorite(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      return favoritesJson.any((jsonString) {
        final recipe = json.decode(jsonString) as Map<String, dynamic>;
        return recipe['idMeal'] == recipeId;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> addFavorite(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      final recipeJson = json.encode(recipe.toJson());
      if (favoritesJson.contains(recipeJson)) {
        return false;
      }
      
      favoritesJson.add(recipeJson);
      return await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      favoritesJson.removeWhere((jsonString) {
        final recipe = json.decode(jsonString) as Map<String, dynamic>;
        return recipe['idMeal'] == recipeId;
      });
      
      return await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleFavorite(Recipe recipe) async {
    final isFav = await isFavorite(recipe.idMeal);
    if (isFav) {
      return await removeFavorite(recipe.idMeal);
    } else {
      return await addFavorite(recipe);
    }
  }
}

