import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chat_screen.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final String baseUrl = "http://127.0.0.1:8080/demo";

  // Demo current user for now.
  // User 2 = buyer
  // User 1 = seller
  final int currentUserId = 2;

  bool isLoading = true;
  String? errorMessage;
  List<dynamic> chats = [];

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  Future<void> fetchChatList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_chat_list.php?user_id=$currentUserId"),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          chats = data["chats"] ?? [];
        });
      } else {
        setState(() {
          errorMessage = data["message"] ?? "Failed to load chats";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Connection error: $e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  String formatTime(String? dateTimeText) {
    if (dateTimeText == null || dateTimeText.isEmpty) {
      return "";
    }

    final dateTime = DateTime.tryParse(dateTimeText);

    if (dateTime == null) {
      return "";
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: fetchChatList, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(onRefresh: fetchChatList, child: buildBody()),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(errorMessage!, textAlign: TextAlign.center),
            ),
          ),
        ],
      );
    }

    if (chats.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 140),
          Icon(Icons.chat_bubble_outline, size: 70, color: Colors.grey),
          SizedBox(height: 12),
          Center(
            child: Text(
              "No chats yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          SizedBox(height: 6),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Open an item and tap Chat with Seller to start a buyer-seller conversation.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = chats[index];

        final int itemId = int.parse(chat["item_id"].toString());
        final int sellerId = int.parse(chat["seller_id"].toString());
        final String itemName = chat["item_name"] ?? "Unknown Item";
        final String lastMessage = chat["last_message"] ?? "";
        final String lastMessageTime = chat["last_message_time"] ?? "";

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
          title: Text(
            itemName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            formatTime(lastMessageTime),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  itemId: itemId,
                  buyerId: currentUserId,
                  sellerId: sellerId,
                  itemName: itemName,
                ),
              ),
            ).then((_) {
              fetchChatList();
            });
          },
        );
      },
    );
  }
}
