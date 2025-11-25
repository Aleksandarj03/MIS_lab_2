import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_image.dart';
import '../widgets/recipe_title.dart';
import '../widgets/recipe_data.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: RecipeImage(imageUrl: recipe.strMealThumb),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecipeTitle(title: recipe.strMeal),
                RecipeData(
                  instructions: recipe.strInstructions,
                  ingredients: recipe.getIngredients(),
                  youtubeUrl: recipe.strYoutube,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

