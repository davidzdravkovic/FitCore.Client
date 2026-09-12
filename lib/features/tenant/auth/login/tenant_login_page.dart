import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/routing/tenant_paths.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/tenant/auth/tenant_session.dart';
import 'package:fitcore_client/features/tenant/auth/login/api/tenant_auth_api.dart';
import 'package:fitcore_client/features/tenant/auth/login/models/tenant_login_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TenantLoginPage extends StatefulWidget {
  const TenantLoginPage({super.key});

  @override
  State<TenantLoginPage> createState() => _TenantLoginPageState();
}

class _TenantLoginPageState extends State<TenantLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantAuthApi = TenantAuthApi();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _tenantAuthApi.login(
        LoginOrganizationRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;

      if (response.accessToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isEmpty ? 'Signed in' : response.message,
            ),
          ),
        );
        return;
      }

      ApiClient.instance.setAccessToken(response.accessToken);
      TenantSession.set(
        organizationName: response.organizationName,
        ownerFirstName: response.ownerFirstName,
      );
      context.go(TenantPaths.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'FitCore',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gym organisation',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'owner@gym.com',
                          prefixIcon: Icon(Icons.mail_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
