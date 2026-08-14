class AuthUser {
  const AuthUser({required this.id, required this.placeOfWork});

  final String id;
  final String placeOfWork;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: '${json['id'] ?? ''}',
      placeOfWork: '${json['placeOfWork'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeOfWork': placeOfWork,
      };
}

class StoredUser {
  const StoredUser({
    required this.id,
    required this.emailHash,
    required this.passwordHash,
    required this.placeOfWork,
  });

  final String id;
  final String emailHash;
  final String passwordHash;
  final String placeOfWork;

  factory StoredUser.fromJson(Map<String, dynamic> json) {
    return StoredUser(
      id: '${json['id'] ?? ''}',
      emailHash: '${json['emailHash'] ?? ''}',
      passwordHash: '${json['passwordHash'] ?? ''}',
      placeOfWork: '${json['placeOfWork'] ?? ''}',
    );
  }
}
