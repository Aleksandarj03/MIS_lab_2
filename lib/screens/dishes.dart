import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import '../widgets/meal_grid_item.dart';
import 'recipe_detail.dart';

class DishesScreen extends StatefulWidget {
  final String category;

  const DishesScreen({
    super.key,
    required this.category,
  });

  @override
  State<DishesScreen> createState() => _DishesScreenState();
}

class _DishesScreenState extends State<DishesScreen> {
  final ApiService _apiService = ApiService();
  List<Meal> _meals = [];
  List<Meal> _filteredMeals = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _searchController.addListener(_filterMeals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
    });

    final meals = await _apiService.getMealsByCategory(widget.category);
    setState(() {
      _meals = meals;
      _filteredMeals = meals;
      _isLoading = false;
    });
  }

  void _filterMeals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMeals = _meals;
      } else {
        _filteredMeals = _meals
            .where((meal) =>
                meal.strMeal.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _searchMeals(String query) async {
    if (query.isEmpty) {
      _loadMeals();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final meals = await _apiService.searchMeals(query);
    setState(() {
      _filteredMeals = meals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Dishes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search dishes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: _searchMeals,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMeals.isEmpty
                    ? const Center(
                        child: Text('No dishes found'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredMeals.length,
                        itemBuilder: (context, index) {
                          return MealGridItem(
                            meal: _filteredMeals[index],
                            onTap: () async {
                              final recipe = await _apiService.getRecipeById(
                                _filteredMeals[index].idMeal,
                              );
                              if (recipe != null && mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

