class PlantData {
  final String commonName;
  final String scientificName;
  final List<String> keyFacts;
  final List<String> description;
  final CareGuide careGuide;

  PlantData({
    required this.commonName,
    required this.scientificName,
    required this.keyFacts,
    required this.description,
    required this.careGuide,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      commonName: json['commonName'] ?? '',
      scientificName: json['scientificName'] ?? '',
      keyFacts: List<String>.from(json['keyFacts'] ?? []),
      description: List<String>.from(json['description'] ?? []),
      careGuide: CareGuide.fromJson(json['careGuide'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commonName': commonName,
      'scientificName': scientificName,
      'keyFacts': keyFacts,
      'description': description,
      'careGuide': careGuide.toJson(),
    };
  }
}

class CareGuide {
  final List<String> watering;
  final List<String> sunlight;
  final List<String> soil;

  CareGuide({
    required this.watering,
    required this.sunlight,
    required this.soil,
  });

  factory CareGuide.fromJson(Map<String, dynamic> json) {
    return CareGuide(
      watering: List<String>.from(json['watering'] ?? []),
      sunlight: List<String>.from(json['sunlight'] ?? []),
      soil: List<String>.from(json['soil'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watering': watering,
      'sunlight': sunlight,
      'soil': soil,
    };
  }
}
