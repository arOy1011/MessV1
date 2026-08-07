import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({
    super.key,
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  State<PendingApprovalPage> createState() =>
      _PendingApprovalPageState();
}

class _PendingApprovalPageState
    extends State<PendingApprovalPage> {
  bool _refreshing = false;

  Future<void> _checkStatus() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    try {
      await widget.onRefresh();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not check approval status: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership pending'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed:
                _refreshing ? null : AuthService.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkStatus,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 100),

            const Icon(
              Icons.hourglass_top_rounded,
              size: 72,
            ),

            const SizedBox(height: 24),

            Text(
              'Waiting for manager approval',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 12),

            Text(
              'Your membership request has been submitted. '
              'A mess manager must approve it before you can '
              'access the mess.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 28),

            Center(
              child: FilledButton.icon(
                onPressed:
                    _refreshing ? null : _checkStatus,
                icon: _refreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                      ),
                label: Text(
                  _refreshing
                      ? 'Checking...'
                      : 'Check approval status',
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'You can also pull down on this page to refresh.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}