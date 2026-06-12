import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import 'chat_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final int? itemId = int.tryParse(productId);

    return Scaffold(
      appBar: AppBar(title: const Text('Item Details'), centerTitle: true),
      body: Consumer<MarketplaceProvider>(
        builder: (context, provider, child) {
          if (itemId == null) {
            return const Center(child: Text('Invalid item ID'));
          }

          final item = provider.getItemById(itemId);

          if (item == null) {
            return const Center(child: Text('Item not found'));
          }

          final bool isAvailable = item.status.toLowerCase() == 'available';

          return ListView(
            children: [
              Container(
                height: 260,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              color: isAvailable
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Posted on ${item.createdAt.split(' ')[0]}',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'RM ${item.itemPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Transaction Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.payments),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Buyer and seller may arrange payment through QR transfer or Cash on Delivery.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Seller Info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 28, child: Icon(Icons.person)),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Test User',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Verified UiTM Student Seller',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Buying Flow',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.chat),
                              title: Text('1. Chat with seller'),
                              subtitle: Text('Ask about item availability.'),
                            ),
                            ListTile(
                              leading: Icon(Icons.handshake),
                              title: Text('2. Arrange meetup or delivery'),
                              subtitle: Text(
                                'Buyer and seller decide together.',
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.check_circle),
                              title: Text('3. Complete transaction'),
                              subtitle: Text('Payment is done by QR or cash.'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                itemId: item.id,
                                buyerId: 2,
                                sellerId: 1,
                                itemName: item.itemName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat with Seller'),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
