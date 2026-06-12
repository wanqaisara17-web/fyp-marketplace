class Item {
  final int id;
  final String itemName;
  final double itemPrice;
  final String description;
  final String category;
  final String createdAt;
  final String status;
  final int sellerId;

  Item({
    required this.id,
    required this.itemName,
    required this.itemPrice,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.status,
    this.sellerId = 1,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: int.parse(json['id'].toString()),
      itemName: json['item_name'] ?? '',
      itemPrice: double.parse(json['item_price'].toString()),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? 'available',
      sellerId: int.tryParse(json['seller_id']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'item_price': itemPrice,
      'description': description,
      'category': category,
      'created_at': createdAt,
      'status': status,
      'seller_id': sellerId,
    };
  }
}
