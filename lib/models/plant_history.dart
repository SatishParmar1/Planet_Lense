class PlantHistory {
  final int? id;
  final String userId;
  final String imagePath;
  final String plantName;
  final String scientificName;
  final String description;
  final double confidence;
  final bool isFavorite;
  final DateTime createdAt;
  final Map<String, dynamic>? additionalData;

  PlantHistory({
    this.id,
    required this.userId,
    required this.imagePath,
    required this.plantName,
    required this.scientificName,
    required this.description,
    required this.confidence,
    this.isFavorite = false,
    required this.createdAt,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imagePath': imagePath,
      'plantName': plantName,
      'scientificName': scientificName,
      'description': description,
      'confidence': confidence,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'additionalData': additionalData != null ? 
          additionalData.toString() : null,
    };
  }

  factory PlantHistory.fromMap(Map<String, dynamic> map) {
    return PlantHistory(
      id: map['id'],
      userId: map['userId'],
      imagePath: map['imagePath'],
      plantName: map['plantName'],
      scientificName: map['scientificName'],
      description: map['description'],
      confidence: map['confidence'],
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      additionalData: map['additionalData'] != null ? 
          {'raw': map['additionalData']} : null,
    );
  }

  PlantHistory copyWith({
    int? id,
    String? userId,
    String? imagePath,
    String? plantName,
    String? scientificName,
    String? description,
    double? confidence,
    bool? isFavorite,
    DateTime? createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return PlantHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      plantName: plantName ?? this.plantName,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'PlantHistory(id: $id, plantName: $plantName, scientificName: $scientificName, isFavorite: $isFavorite)';
  }
}
