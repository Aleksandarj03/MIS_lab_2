import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeData extends StatelessWidget {
  final String instructions;
  final List<Map<String, String>> ingredients;
  final String? youtubeUrl;

  const RecipeData({
    super.key,
    required this.instructions,
    required this.ingredients,
    this.youtubeUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (youtubeUrl != null && youtubeUrl!.isNotEmpty) ...[
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(youtubeUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Watch on YouTube'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Instructions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            instructions,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Ingredients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${ingredient['ingredient']} - ${ingredient['measure']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

