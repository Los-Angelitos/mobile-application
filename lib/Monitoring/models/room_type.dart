class RoomType {
  final int id;
  final String name;
  final int price;
  RoomType({
    required this.id,
    required this.name,
    required this.price,
  final String? description;
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: json['id'] ?? 0,
      name: json['description'] ?? '',
      price: json['price'] ?? '',
      // CORREGIDO: Usar 'description' como nombre si 'name' no está disponible
      name: json['name'] ?? json['description'] ?? 'Tipo sin nombre',
      description: json['description'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomType && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}