import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  final int itemId;
  final int buyerId;
  final int sellerId;
  final String itemName;

  const ChatScreen({
    super.key,
    required this.itemId,
    required this.buyerId,
    required this.sellerId,
    required this.itemName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final String baseUrl = "http://127.0.0.1:8080/demo";

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_message.php?item_id=${widget.itemId}"),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          _messages = (data["messages"] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Fetch messages error: $e");
    }

    setState(() => _isLoading = false);
  }

  Future<void> sendMessage({
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send_message.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "item_id": widget.itemId,
          "sender_id": senderId,
          "receiver_id": receiverId,
          "message": message.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        _messageController.clear();
        await fetchMessages();
      }
    } catch (e) {
      debugPrint("Send message error: $e");
    }
  }

  void sendBuyerMessage() {
    sendMessage(
      senderId: widget.buyerId,
      receiverId: widget.sellerId,
      message: _messageController.text,
    );
  }

  void sendDemoSellerReply() {
    sendMessage(
      senderId: widget.sellerId,
      receiverId: widget.buyerId,
      message: "Yes, this item is still available. We can arrange a meetup.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentUserId = widget.buyerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
        centerTitle: true,
        actions: [
          IconButton(onPressed: fetchMessages, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.yellow.shade100,
            padding: const EdgeInsets.all(10),
            child: const Text(
              "Demo chat for buyer-seller transaction. Payment is arranged outside the app.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text("No messages yet. Start chatting!"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final bool isMe = msg.senderId == currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? "Buyer" : "Seller",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.green.shade100
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                msg.message,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: sendDemoSellerReply,
                icon: const Icon(Icons.person),
                label: const Text("Demo Seller Reply"),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type as buyer...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sendBuyerMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
