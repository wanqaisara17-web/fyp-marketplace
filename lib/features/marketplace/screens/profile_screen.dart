import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/marketplace_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;

          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: user?.profilePicture != null
                          ? Image.network(user!.profilePicture!)
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Test User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? 'test@student.uitm.edu.my',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Consumer<MarketplaceProvider>(
                builder: (context, marketplaceProvider, _) {
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: const Text(
                      'My Listings',
                    ), // page showing items the user has posted for sale, with options to edit or delete
                    subtitle: const Text('Items posted for sale'),
                    trailing: Chip(
                      label: Text(marketplaceProvider.items.length.toString()),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('My listings page coming soon'),
                        ),
                      );
                    },
                  );
                },
              ),

              Divider(color: Colors.grey[300]),

              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text(
                  'My Chats',
                ), // chat page for buyer and seller conversations
                subtitle: const Text('Buyer and seller conversations'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chats page coming soon')),
                  );
                },
              ),

              Divider(color: Colors.grey[300]),

              ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text('Post New Item'),
                subtitle: const Text('Sell an item to other students'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Use the Post tab to add a new item'),
                    ),
                  );
                },
              ),

              Divider(color: Colors.grey[300]),

              ListTile(
                leading: const Icon(Icons.verified_user),
                title: const Text('Student Verification'),
                subtitle: const Text('Email verified with SMS 2FA enabled'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your account uses Firebase verification'),
                    ),
                  );
                },
              ),

              Divider(color: Colors.grey[300]),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'), // setting page
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings page coming soon')),
                  );
                },
              ),

              Divider(color: Colors.grey[300]),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Sign out of this account?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await context.read<AuthProvider>().logout();
                            if (context.mounted) context.goNamed('login');
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
