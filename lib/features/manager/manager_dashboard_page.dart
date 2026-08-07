import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerDashboardPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final Map<String, dynamic> membership;
  final Map<String, dynamic> managerAssignment;

  const ManagerDashboardPage({
    super.key,
    required this.profile,
    required this.membership,
    required this.managerAssignment,
  });

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final name =
        profile['full_name'] ??
        profile['name'] ??
        'Manager';

    final studentId =
        membership['student_id']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                studentId.isEmpty
                    ? 'Mess Manager'
                    : '$studentId • Mess Manager',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 36,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Manager access active',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'You have manager access for the current mess month.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Management',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 14),

              _DashboardTile(
                icon: Icons.people_alt_outlined,
                title: 'Membership requests',
                subtitle:
                    'Approve or reject new mess members',
                onTap: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Membership management coming next.',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.restaurant_menu_rounded,
                title: 'Meals',
                subtitle:
                    'Manage meals and cancellations',
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.shopping_cart_outlined,
                title: 'Daily Bazaar',
                subtitle:
                    'Manage daily purchases and expenses',
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.receipt_long_outlined,
                title: 'Bills & Payments',
                subtitle:
                    'View member bills and payment status',
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Finance',
                subtitle:
                    'View monthly mess finances',
                onTap: () {},
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.campaign_outlined,
                title: 'Announcements',
                subtitle:
                    'Send updates to mess members',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Icon(
          icon,
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
        onTap: onTap,
      ),
    );
  }
}