class RoomType {
  final int id;
  final String name;
  final int price;
  RoomType({
    required this.id,
    required this.name,
    required this.price,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: json['id'] ?? 0,
      name: json['description'] ?? '',
      price: json['price'] ?? '',
    );
  }
}
