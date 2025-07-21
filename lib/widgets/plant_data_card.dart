import 'package:flutter/material.dart';
import '../models/plant_data.dart';

class PlantDataCard extends StatelessWidget {
  final PlantData plantData;

  const PlantDataCard({super.key, required this.plantData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plantData.commonName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              plantData.scientificName,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 24),
            _buildSectionTitle('Description'),
            ...plantData.description.map((point) => _buildDescriptionItem(point)).toList(),
            const SizedBox(height: 20),
            _buildSectionTitle('Key Facts'),
            ...plantData.keyFacts.map((fact) => _buildFactItem(fact)).toList(),
            const SizedBox(height: 20),
            _buildSectionTitle('Care Guide'),
            _buildCareSection(Icons.water_drop, 'Watering', plantData.careGuide.watering),
            _buildCareSection(Icons.wb_sunny, 'Sunlight', plantData.careGuide.sunlight),
            _buildCareSection(Icons.grass, 'Soil', plantData.careGuide.soil),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.tealAccent,
      ),
    );
  }

  Widget _buildFactItem(String fact) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fact,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(String point) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.tealAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              point,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareSection(IconData icon, String title, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.tealAccent, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(left: 34.0, top: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(color: Colors.tealAccent, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(color: Colors.grey, height: 1.3),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
