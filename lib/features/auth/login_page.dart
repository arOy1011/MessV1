import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateInputs() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showMessage('Enter your email address.');
      return false;
    }

    if (!email.endsWith('@iacs.res.in')) {
      _showMessage('Use your IACS email address.');
      return false;
    }

    if (password.isEmpty) {
      _showMessage('Enter your password.');
      return false;
    }

    return true;
  }

  Future<void> _signIn() async {
    if (!_validateInputs()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    setState(() => _loading = true);

    try {
      await AuthService.signIn(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to sign in. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createAccount() async {
    if (!_validateInputs()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.session != null) {
        _showMessage('Account created successfully.');
      } else {
        _showMessage(
          'Account created. Check your IACS email for verification.',
        );

        setState(() {
          _isCreatingAccount = false;
        });
      }
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to create account. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    try {
      await AuthService.signInWithGoogle();
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Google sign-in failed.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    size: 72,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _isCreatingAccount
                        ? 'Create account'
                        : 'MessMate',
                    textAlign: TextAlign.center,
                    style:
                        Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isCreatingAccount
                        ? 'Create your MessMate account'
                        : 'Hostel mess management',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'IACS email',
                      hintText: 'yourid@iacs.res.in',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) {
                      if (_loading) return;

                      if (_isCreatingAccount) {
                        _createAccount();
                      } else {
                        _signIn();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: _isCreatingAccount
                          ? 'Create password'
                          : 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  if (_isCreatingAccount) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Use at least 6 characters.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _loading
                        ? null
                        : (_isCreatingAccount
                            ? _createAccount
                            : _signIn),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isCreatingAccount
                                  ? 'Create account'
                                  : 'Sign in',
                            ),
                    ),
                  ),

                  if (!_isCreatingAccount) ...[
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed:
                          _loading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.login_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'Continue with Google',
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _loading ? null : _toggleMode,
                    child: Text(
                      _isCreatingAccount
                          ? 'Already have an account? Sign in'
                          : 'New to MessMate? Create account',
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isCreatingAccount
                        ? 'Create an account using your IACS email.'
                        : 'New members will complete their mess profile after signing in.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
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