import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/routing/platform_paths.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/features/platform/dashboard/api/invitations_api.dart';
import 'package:fitcore_client/features/platform/dashboard/api/tenants_api.dart';
import 'package:fitcore_client/features/platform/dashboard/models/invitations_models.dart';
import 'package:fitcore_client/features/platform/dashboard/models/tenants_models.dart';
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
  final _tenantsApi = TenantsApi();

  bool _isSubmitting = false;
  bool _isLoadingTenants = true;
  String? _tenantsError;
  List<TenantResponse> _tenants = const [];

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _isLoadingTenants = true;
      _tenantsError = null;
    });

    try {
      final tenants = await _tenantsApi.list();
      if (!mounted) return;
      setState(() {
        _tenants = tenants;
        _isLoadingTenants = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _tenantsError = e.message;
        _isLoadingTenants = false;
      });
    }
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
            response.message.isEmpty ? 'Invitation sent' : response.message,
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

  Future<void> _cancelTenant(TenantResponse tenant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel organization'),
          content: Text(
            'Cancel ${tenant.name}? Staff will no longer be able to sign in '
            'and the organization will be treated as deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel organization'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _tenantsApi.cancel(tenant.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tenant.name} cancelled')),
      );
      await _loadTenants();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
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
              context.go(PlatformPaths.login);
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Send invite'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Organizations',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: _isLoadingTenants ? null : _loadTenants,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cancel soft-deletes a gym by setting status to Cancelled.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTenantsBody(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTenantsBody(ThemeData theme) {
    if (_isLoadingTenants) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_tenantsError != null) {
      return Column(
        children: [
          Text(_tenantsError!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loadTenants,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (_tenants.isEmpty) {
      return Text(
        'No organizations yet.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('')),
        ],
        rows: [
          for (final tenant in _tenants)
            DataRow(
              cells: [
                DataCell(Text(tenant.name)),
                DataCell(Text(tenant.businessEmail)),
                DataCell(Text(tenant.status)),
                DataCell(
                  tenant.isCancelled
                      ? const Text('—')
                      : IconButton(
                          tooltip: 'Cancel organization',
                          onPressed: () => _cancelTenant(tenant),
                          icon: const Icon(Icons.cancel_outlined),
                        ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
