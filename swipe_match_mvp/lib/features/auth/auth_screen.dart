import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_error.dart';
import '../../core/supabase/supabase_config.dart';
import 'auth_view_model.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(authActionProvider);

    ref.listen(authActionProvider, (previous, next) {
      if (!next.hasError || next.error == null) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(next.error!))));
    });

    if (!SupabaseConfig.isConfigured) {
      return const _SetupRequired();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Match')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 32),
            Text(
              _isSignUp ? 'Create your account' : 'Welcome back',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Build a profile, discover people, and match when likes are mutual.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: action.isLoading ? null : _submit,
              child: Text(_isSignUp ? 'Sign up' : 'Sign in'),
            ),
            TextButton(
              onPressed: action.isLoading
                  ? null
                  : () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign in'
                    : 'Need an account? Sign up',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final viewModel = ref.read(authActionProvider.notifier);

    if (_isSignUp) {
      await viewModel.signUp(email, password);
    } else {
      await viewModel.signIn(email, password);
    }
  }
}

class _SetupRequired extends StatelessWidget {
  const _SetupRequired();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Match')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Supabase is not configured yet. Run the app with SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
