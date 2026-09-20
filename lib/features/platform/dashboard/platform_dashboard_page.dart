import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/routing/platform_paths.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/core/widgets/fit_data_panel.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/platform/dashboard/api/invitations_api.dart';
import 'package:fitcore_client/features/platform/dashboard/api/tenants_api.dart';
import 'package:fitcore_client/features/platform/dashboard/models/create_invite_request.dart';
import 'package:fitcore_client/features/platform/dashboard/models/tenant_response.dart';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${tenant.name} cancelled')));
      await _loadTenants();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final compact =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.medium;
    final pad = compact ? FitCoreSpace.x4 : FitCoreSpace.x6;

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        title: const Text('Platform'),
        shape: Border(bottom: BorderSide(color: t.borderSubtle)),
        actions: [
          TextButton(
            onPressed: () {
              ApiClient.instance.setAccessToken(null);
              context.go(PlatformPaths.login);
            },
            style: TextButton.styleFrom(foregroundColor: t.textSecondary),
            child: const Text('Sign out'),
          ),
          const SizedBox(width: FitCoreSpace.x2),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInviteCard(context),
                    const SizedBox(height: FitCoreSpace.x6),
                    FitPageHeader(
                      title: 'Organizations',
                      description: 'Cancel soft-deletes a gym by setting status to Cancelled.',
                      meta: _tenants.isNotEmpty
                          ? FitCountBadge(count: _tenants.length, noun: 'total')
                          : null,
                      actions: [
                        OutlinedButton.icon(
                          onPressed: _isLoadingTenants ? null : _loadTenants,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: FitCoreSpace.x4),
                    SizedBox(
                      height: 420,
                      child: FitDataPanel(child: _buildTenantsBody()),
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

  Widget _buildInviteCard(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Container(
      padding: const EdgeInsets.all(FitCoreSpace.x5),
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        border: Border.all(color: t.borderSubtle),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Invite gym', style: theme.textTheme.titleMedium),
            const SizedBox(height: FitCoreSpace.x1),
            Text(
              'Send a free-plan invitation to a gym owner’s email.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
              ),
            ),
            const SizedBox(height: FitCoreSpace.x5),
            LayoutBuilder(
              builder: (context, constraints) {
                final field = TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Owner email',
                    hintText: 'owner@gym.com',
                    prefixIcon: Icon(Icons.mail_outline, size: 18),
                  ),
                  validator: Validators.email,
                );

                final submit = FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send invite'),
                );

                if (constraints.maxWidth < FitCoreBreakpoints.compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      field,
                      const SizedBox(height: FitCoreSpace.x4),
                      submit,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: field),
                    const SizedBox(width: FitCoreSpace.x3),
                    SizedBox(width: 150, child: submit),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantsBody() {
    if (_isLoadingTenants) {
      return const FitTableSkeleton(columnFlex: [3, 3, 1, 2]);
    }

    if (_tenantsError != null) {
      return FitErrorState(message: _tenantsError!, onRetry: _loadTenants);
    }

    if (_tenants.isEmpty) {
      return const FitEmptyState(
        icon: Icons.apartment_outlined,
        title: 'No organizations yet',
        message: 'Invited gyms appear here once they register.',
      );
    }

    return FitRecordTable(
      columns: const [
        FitColumn(label: 'Name', flex: 3, minWidth: 170),
        FitColumn(label: 'Email', flex: 3, minWidth: 200),
        FitColumn(label: 'Currency', flex: 1, minWidth: 100, hideBelow: 820),
        FitColumn(label: 'Status', flex: 2, minWidth: 130),
      ],
      rows: [
        for (final tenant in _tenants)
          FitRecordRow(
            leading: FitAvatar(name: tenant.name),
            cells: [
              FitTextCell(tenant.name, strong: true),
              FitTextCell(tenant.businessEmail, muted: true),
              if (tenant.currency.isEmpty)
                const FitTextCell.empty()
              else
                FitTextCell(tenant.currency, mono: true),
              FitStatusChip(
                label: tenant.status,
                tone: tenant.isCancelled ? FitTone.negative : FitTone.positive,
              ),
            ],
            actions: [
              if (!tenant.isCancelled)
                FitRowAction(
                  icon: Icons.cancel_outlined,
                  tooltip: 'Cancel organization',
                  danger: true,
                  onPressed: () => _cancelTenant(tenant),
                ),
            ],
          ),
      ],
    );
  }
}
