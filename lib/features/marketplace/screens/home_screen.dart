import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/item_model.dart';
import '../providers/marketplace_provider.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;

  final List<String> categories = [
    'Books',
    'Electronics',
    'Clothing',
    'Furniture',
    'Appliances',
    'Home',
    'Others',
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<MarketplaceProvider>().fetchItems();
    });
  }

  String getPostedTime(String createdAt) {
    final postedDate = DateTime.tryParse(createdAt);

    if (postedDate == null) {
      return 'Recently posted';
    }

    final difference = DateTime.now().difference(postedDate);

    if (difference.inMinutes < 1) {
      return 'Posted just now';
    } else if (difference.inMinutes < 60) {
      return 'Posted ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Posted ${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Posted yesterday';
    } else {
      return 'Posted ${difference.inDays} days ago';
    }
  }

  Color getStatusColor(String status) {
    return status.toLowerCase() == 'sold' ? Colors.red : Colors.green;
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'books':
        return Icons.menu_book;
      case 'electronics':
        return Icons.devices;
      case 'clothing':
        return Icons.checkroom;
      case 'furniture':
        return Icons.chair;
      case 'appliances':
        return Icons.kitchen;
      case 'home':
        return Icons.home;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UiTM Marketplace"), centerTitle: true),
      body: Consumer<MarketplaceProvider>(
        builder: (context, marketplaceProvider, child) {
          if (marketplaceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (marketplaceProvider.error != null) {
            return Center(child: Text('Error: ${marketplaceProvider.error}'));
          }

          final displayedItems = selectedCategory == null
              ? marketplaceProvider.latestItems
              : marketplaceProvider.latestItems
                    .where((item) => item.category == selectedCategory)
                    .toList();

          return RefreshIndicator(
            onRefresh: () => marketplaceProvider.fetchItems(),
            child: ListView(
              children: [
                _buildSearchBanner(context),

                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(
                            getCategoryIcon(category),
                            size: 16,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = isSelected ? null : category;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategory == null
                            ? 'Latest Items'
                            : '$selectedCategory Items',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedCategory != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = null;
                            });
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),

                if (displayedItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No items found for this category'),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.58,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final item = displayedItems[index];
                        return _buildItemCard(context, item);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[800]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find student items faster',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search textbooks, electronics, clothes, furniture, and campus essentials posted by UiTM students.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search marketplace items',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item) {
    final statusColor = getStatusColor(item.status);

    return GestureDetector(
      onTap: () {
        context.push('/product-detail?id=${item.id}');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 105,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      getCategoryIcon(item.category),
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${item.itemPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getPostedTime(item.createdAt),
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
