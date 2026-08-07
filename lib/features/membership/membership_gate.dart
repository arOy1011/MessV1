import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/mess_service.dart';
import '../home/home_page.dart';
import 'pending_approval_page.dart';

class MembershipGate extends StatefulWidget {
  const MembershipGate({
    super.key,
    required this.profile,
  });

  final Map<String, dynamic> profile;

  @override
  State<MembershipGate> createState() => _MembershipGateState();
}

class _MembershipGateState extends State<MembershipGate> {
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _membership;

  @override
  void initState() {
    super.initState();
    _loadMembership();
  }

  Future<void> _loadMembership() async {
    final user = AuthService.currentUser;

    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'No authenticated user found.';
      });
      return;
    }

    try {
      final membership =
          await MessService.getMessMembership(user.id);

      if (!mounted) return;

      setState(() {
        _membership = membership;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('MessMate'),
          actions: [
            IconButton(
              onPressed: AuthService.signOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: Center(
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
                  'Could not load membership',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });

                    _loadMembership();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_membership == null) {
      return MembershipApplicationPage(
        profile: widget.profile,
        onSubmitted: _loadMembership,
      );
    }

    final status =
        (_membership!['status'] ?? '').toString().toLowerCase();

    switch (status) {
      case 'active':
        return HomePage(
          profile: widget.profile,
          membership: _membership!,
        );

      case 'pending':
        return PendingApprovalPage(
          onRefresh: _loadMembership,
        );

      case 'inactive':
        return const MembershipUnavailablePage(
          title: 'Membership inactive',
          message:
              'Your mess membership is currently inactive. Contact a mess manager for assistance.',
        );

      case 'deactivated':
        return const MembershipUnavailablePage(
          title: 'Membership deactivated',
          message:
              'Your mess membership has been deactivated. Contact a mess manager if you need assistance.',
        );

      default:
        return MembershipUnavailablePage(
          title: 'Unknown membership status',
          message: 'Membership status: $status',
        );
    }
  }
}

class MembershipApplicationPage extends StatefulWidget {
  const MembershipApplicationPage({
    super.key,
    required this.profile,
    required this.onSubmitted,
  });

  final Map<String, dynamic> profile;
  final Future<void> Function() onSubmitted;

  @override
  State<MembershipApplicationPage> createState() =>
      _MembershipApplicationPageState();
}

class _MembershipApplicationPageState
    extends State<MembershipApplicationPage> {
  final _studentIdController = TextEditingController();
  final _batchYearController = TextEditingController();

  bool _loading = true;
  bool _submitting = false;

  String? _error;

  List<Map<String, dynamic>> _messes = [];
  List<Map<String, dynamic>> _memberTypes = [];

  String? _selectedMessId;
  String? _selectedMemberTypeId;

  @override
  void initState() {
    super.initState();
    _loadMesses();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _batchYearController.dispose();
    super.dispose();
  }

  Future<void> _loadMesses() async {
    try {
      final messes = await MessService.getActiveMesses();

      if (!mounted) return;

      setState(() {
        _messes = messes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _selectMess(String? messId) async {
    setState(() {
      _selectedMessId = messId;
      _selectedMemberTypeId = null;
      _memberTypes = [];
    });

    if (messId == null) return;

    try {
      final types = await MessService.getMemberTypes(messId);

      if (!mounted) return;

      setState(() {
        _memberTypes = types;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  Future<void> _submit() async {
    final user = AuthService.currentUser;

    if (user == null) return;

    if (_selectedMessId == null) {
      _showMessage('Select your mess.');
      return;
    }

    if (_selectedMemberTypeId == null) {
      _showMessage('Select your member type.');
      return;
    }

    final studentId = _studentIdController.text.trim();

    if (studentId.isEmpty) {
      _showMessage('Enter your student ID.');
      return;
    }

    final batchYear =
        int.tryParse(_batchYearController.text.trim());

    if (batchYear == null ||
        batchYear < 1900 ||
        batchYear > 2100) {
      _showMessage('Enter a valid batch year.');
      return;
    }

    setState(() => _submitting = true);

    try {
      await MessService.createMembership(
        messId: _selectedMessId!,
        userId: user.id,
        memberTypeId: _selectedMemberTypeId!,
        studentId: studentId,
        batchYear: batchYear,
      );

      await widget.onSubmitted();
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a mess'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: AuthService.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mess membership',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Hello ${widget.profile['full_name'] ?? ''}. Select your mess and submit your membership request.',
                  ),

                  const SizedBox(height: 28),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedMessId,
                    decoration: const InputDecoration(
                      labelText: 'Mess',
                      prefixIcon:
                          Icon(Icons.restaurant_rounded),
                    ),
                    items: _messes.map((mess) {
                      return DropdownMenuItem<String>(
                        value: mess['id'].toString(),
                        child: Text(
                          mess['name']?.toString() ?? 'Mess',
                        ),
                      );
                    }).toList(),
                    onChanged:
                        _submitting ? null : _selectMess,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedMemberTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Member type',
                      prefixIcon:
                          Icon(Icons.category_outlined),
                    ),
                    items: _memberTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['id'].toString(),
                        child: Text(
                          type['name']?.toString() ??
                              'Member',
                        ),
                      );
                    }).toList(),
                    onChanged: _selectedMessId == null ||
                            _submitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedMemberTypeId = value;
                            });
                          },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _studentIdController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      prefixIcon:
                          Icon(Icons.badge_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _batchYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Batch year',
                      hintText: 'e.g. 2024',
                      prefixIcon:
                          Icon(Icons.school_outlined),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed:
                        _submitting ? null : _submit,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit membership request',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MembershipUnavailablePage extends StatelessWidget {
  const MembershipUnavailablePage({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MessMate'),
        actions: [
          IconButton(
            onPressed: AuthService.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}