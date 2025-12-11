import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorites_service.dart';
import '../widgets/recipe_image.dart';
import '../widgets/recipe_title.dart';
import '../widgets/recipe_data.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.recipe.idMeal);
    setState(() {
      _isFavorite = isFav;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await _favoritesService.toggleFavorite(widget.recipe);
    await _checkFavoriteStatus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              if (!_isLoading)
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: RecipeImage(imageUrl: widget.recipe.strMealThumb),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecipeTitle(title: widget.recipe.strMeal),
                RecipeData(
                  instructions: widget.recipe.strInstructions,
                  ingredients: widget.recipe.getIngredients(),
                  youtubeUrl: widget.recipe.strYoutube,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

