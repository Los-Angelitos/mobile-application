class RoomType {
  final int id;
  final String name;

  RoomType({
    required this.id,
    required this.name,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
