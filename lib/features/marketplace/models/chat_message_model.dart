class ChatMessage {
  final int id;
  final int itemId;
  final int senderId;
  final int receiverId;
  final String message;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.itemId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: int.parse(json['id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      receiverId: int.parse(json['receiver_id'].toString()),
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
