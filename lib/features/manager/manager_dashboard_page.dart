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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ManagerMembershipRequestsPage(
                        membership: membership,
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
                onTap: () {
                  _comingSoon(context, 'Meals');
                },
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.shopping_cart_outlined,
                title: 'Daily Bazaar',
                subtitle:
                    'Manage daily purchases and expenses',
                onTap: () {
                  _comingSoon(context, 'Daily Bazaar');
                },
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.receipt_long_outlined,
                title: 'Bills & Payments',
                subtitle:
                    'View member bills and payment status',
                onTap: () {
                  _comingSoon(context, 'Bills & Payments');
                },
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon:
                    Icons.account_balance_wallet_outlined,
                title: 'Finance',
                subtitle:
                    'View monthly mess finances',
                onTap: () {
                  _comingSoon(context, 'Finance');
                },
              ),

              const SizedBox(height: 12),

              _DashboardTile(
                icon: Icons.campaign_outlined,
                title: 'Announcements',
                subtitle:
                    'Send updates to mess members',
                onTap: () {
                  _comingSoon(context, 'Announcements');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _comingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be implemented next.',
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

// ============================================================
// MEMBERSHIP REQUEST MANAGEMENT
// ============================================================

class ManagerMembershipRequestsPage
    extends StatefulWidget {
  const ManagerMembershipRequestsPage({
    super.key,
    required this.membership,
  });

  final Map<String, dynamic> membership;

  @override
  State<ManagerMembershipRequestsPage>
      createState() =>
          _ManagerMembershipRequestsPageState();
}

class _ManagerMembershipRequestsPageState
    extends State<ManagerMembershipRequestsPage> {
  bool _loading = true;

  String? _error;
  String? _updatingId;

  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final messId =
        widget.membership['mess_id']?.toString();

    if (messId == null || messId.isEmpty) {
      setState(() {
        _loading = false;
        _error =
            'No mess was found for this manager.';
      });

      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('mess_memberships')
          .select(
            '''
            id,
            user_id,
            student_id,
            batch_year,
            status,
            created_at,
            profiles (
              full_name
            ),
            member_types (
              name
            )
            ''',
          )
          .eq('mess_id', messId)
          .eq('status', 'pending')
          .order(
            'created_at',
            ascending: true,
          );

      if (!mounted) return;

      setState(() {
        _requests =
            List<Map<String, dynamic>>.from(data);

        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _approve(
    Map<String, dynamic> request,
  ) async {
    final id = request['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Approve membership?'),
          content: const Text(
            'This member will receive active access to the mess.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _updatingId = id;
    });

    try {
      await Supabase.instance.client
          .from('mess_memberships')
          .update({
            'status': 'active',
            'approved_at': DateTime.now()
                .toUtc()
                .toIso8601String(),
          })
          .eq('id', id);

      await _loadRequests();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Membership approved.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingId = null;
        });
      }
    }
  }

  Future<void> _reject(
    Map<String, dynamic> request,
  ) async {
    final id = request['id']?.toString();

    if (id == null || id.isEmpty) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Reject membership?'),
          content: const Text(
            'The pending membership request will be removed. The user can submit a new request later.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _updatingId = id;
    });

    try {
      await Supabase.instance.client
          .from('mess_memberships')
          .delete()
          .eq('id', id)
          .eq('status', 'pending');

      await _loadRequests();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Membership request rejected.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingId = null;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await _loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Membership requests'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
              ),

              const SizedBox(height: 16),

              const Text(
                'Could not load requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _error!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: _refresh,
                icon:
                    const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),

            Icon(
              Icons.inbox_outlined,
              size: 64,
            ),

            SizedBox(height: 16),

            Text(
              'No pending membership requests',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'New membership requests will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (_, __) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          final request = _requests[index];

          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(
    Map<String, dynamic> request,
  ) {
    final profile = request['profiles'];
    final memberType = request['member_types'];

    String name = 'Member';
    String typeName = 'Member';

    if (profile is Map) {
      name =
          profile['full_name']?.toString() ??
              'Member';
    }

    if (memberType is Map) {
      typeName =
          memberType['name']?.toString() ??
              'Member';
    }

    final id =
        request['id']?.toString() ?? '';

    final studentId =
        request['student_id']?.toString() ??
            '-';

    final batchYear =
        request['batch_year']?.toString() ??
            '-';

    final updating =
        _updatingId == id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child:
                      Icon(Icons.person_outline),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                      ),

                      const SizedBox(height: 2),

                      Text(typeName),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Text(
                  'Student ID: $studentId',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.school_outlined,
                  size: 20,
                ),

                const SizedBox(width: 8),

                Text(
                  'Batch: $batchYear',
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (updating)
              const Center(
                child:
                    CircularProgressIndicator(),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _reject(request);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                      label:
                          const Text('Reject'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        _approve(request);
                      },
                      icon: const Icon(
                        Icons.check_rounded,
                      ),
                      label:
                          const Text('Approve'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}