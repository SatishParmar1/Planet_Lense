class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? lastSignIn;
  final bool isSignedIn;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.lastSignIn,
    this.isSignedIn = false,
  });

  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      displayName: '',
      photoUrl: null,
      lastSignIn: null,
      isSignedIn: false,
    );
  }

  factory UserModel.fromGoogleSignIn(dynamic googleUser) {
    return UserModel(
      id: googleUser.id,
      email: googleUser.email,
      displayName: googleUser.displayName ?? '',
      photoUrl: googleUser.photoUrl,
      lastSignIn: DateTime.now(),
      isSignedIn: true,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? lastSignIn,
    bool? isSignedIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      isSignedIn: isSignedIn ?? this.isSignedIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'lastSignIn': lastSignIn?.toIso8601String(),
      'isSignedIn': isSignedIn,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'],
      lastSignIn: json['lastSignIn'] != null 
          ? DateTime.parse(json['lastSignIn'] as String)
          : null,
      isSignedIn: json['isSignedIn'] ?? false,
    );
  }

  // Convenient getters
  String get name => displayName.isNotEmpty ? displayName : email.split('@').first;
  
  String get initials {
    if (displayName.isNotEmpty) {
      final names = displayName.split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      }
      return displayName[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, displayName: $displayName, email: $email, isSignedIn: $isSignedIn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
