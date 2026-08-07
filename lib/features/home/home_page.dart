import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.profile,
    required this.membership,
  });

  final Map<String, dynamic> profile;
  final Map<String, dynamic> membership;

  @override
  Widget build(BuildContext context) {
    final name = profile['full_name']?.toString().trim();
    final displayName =
        (name == null || name.isEmpty) ? 'Member' : name;

    final studentId =
        membership['student_id']?.toString() ?? '-';

    final batchYear =
        membership['batch_year']?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('MessMate'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: AuthService.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Hello, $displayName',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 6),

            Text(
              'Your mess dashboard',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Active member',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Student ID: $studentId',
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Batch year: $batchYear',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Mess',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 12),

            _HomeActionCard(
              icon: Icons.no_meals_outlined,
              title: 'Meal cancellation',
              subtitle:
                  'Cancel meals for a date or date range',
              onTap: () {
                _comingSoon(
                  context,
                  'Meal cancellation',
                );
              },
            ),

            const SizedBox(height: 12),

            _HomeActionCard(
              icon: Icons.tune_rounded,
              title: 'Monthly food preferences',
              subtitle:
                  'View your fixed preferences for this month',
              onTap: () {
                _comingSoon(
                  context,
                  'Monthly food preferences',
                );
              },
            ),

            const SizedBox(height: 12),

            _HomeActionCard(
              icon: Icons.receipt_long_outlined,
              title: 'Billing',
              subtitle:
                  'View your monthly bill and payment status',
              onTap: () {
                _comingSoon(
                  context,
                  'Billing',
                );
              },
            ),

            const SizedBox(height: 12),

            _HomeActionCard(
              icon: Icons.campaign_outlined,
              title: 'Announcements',
              subtitle:
                  'Updates and notices from the mess',
              onTap: () {
                _comingSoon(
                  context,
                  'Announcements',
                );
              },
            ),

            const SizedBox(height: 12),

            _HomeActionCard(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              subtitle:
                  'View your account and membership details',
              onTap: () {
                _comingSoon(
                  context,
                  'Profile',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _comingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be added next.',
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Icon(icon),
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