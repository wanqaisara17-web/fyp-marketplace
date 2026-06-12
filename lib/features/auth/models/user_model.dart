class User {
  final int id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phone;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phone,
    this.address,
  });

  factory User.dummy() {
    return User(
      id: 1,
      name: 'Test User',
      email: '0123456789@student.uitm.edu.my',
      profilePicture: null,
      phone: '+60123456789',
      address: 'UiTM Jasin Campus, Melaka',
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? profilePicture,
    String? phone,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
