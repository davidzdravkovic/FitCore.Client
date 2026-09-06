import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/platform_dashboard/api/invitations_api.dart';
import 'package:fitcore_client/features/platform_dashboard/api/invitations_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlatformDashboardPage extends StatefulWidget {
  const PlatformDashboardPage({super.key});

  @override
  State<PlatformDashboardPage> createState() => _PlatformDashboardPageState();
}

class _PlatformDashboardPageState extends State<PlatformDashboardPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _invitationsApi = InvitationsApi();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _invitationsApi.create(
        CreateInviteRequest(email: _emailController.text.trim()),
      );

      if (!mounted) return;

      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isEmpty
                ? 'Invitation sent'
                : response.message,
          ),
        ),
      );
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
      appBar: AppBar(
        title: const Text('Platform'),
        actions: [
          TextButton(
            onPressed: () {
              ApiClient.instance.setAccessToken(null);
              context.go('/platform/login');
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Invite gym',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send a free-plan invitation to a gym owner’s email.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Owner email',
                        hintText: 'owner@gym.com',
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 24),
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
                          : const Text('Send invite'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
