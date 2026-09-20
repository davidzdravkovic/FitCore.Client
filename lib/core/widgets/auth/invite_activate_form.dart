import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/core/widgets/fit_auth_scaffold.dart';
import 'package:flutter/material.dart';

typedef InviteActivateSubmit = Future<void> Function(
  String token,
  String password,
);

/// Shared invite-token + password setup form used by staff and member portals.
class InviteActivateForm extends StatefulWidget {
  const InviteActivateForm({
    super.key,
    required this.token,
    required this.instructionsWithToken,
    required this.missingTokenLoginLabel,
    required this.onMissingTokenLogin,
    required this.onSubmit,
    this.title = 'Set your password',
    this.missingTokenMessage = 'This invitation link is missing its token. Ask your gym to send a new invite.',
    this.submitLabel = 'Save password',
  });

  final String? token;
  final String title;
  final String instructionsWithToken;
  final String missingTokenMessage;
  final String missingTokenLoginLabel;
  final VoidCallback onMissingTokenLogin;
  final String submitLabel;
  final InviteActivateSubmit onSubmit;

  @override
  State<InviteActivateForm> createState() => _InviteActivateFormState();
}

class _InviteActivateFormState extends State<InviteActivateForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _hasToken => widget.token != null && widget.token!.isNotEmpty;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_hasToken) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(widget.token!, _passwordController.text);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FitAuthScaffold(
      title: widget.title,
      subtitle: _hasToken
          ? widget.instructionsWithToken
          : widget.missingTokenMessage,
      child: _hasToken
          ? Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: FitCoreSpace.x4),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _confirmController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: Icon(Icons.lock_outline, size: 18),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return Validators.password(value);
                    },
                  ),
                  const SizedBox(height: FitCoreSpace.x6),
                  FitAuthSubmitButton(
                    label: widget.submitLabel,
                    isSubmitting: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            )
          : FitAuthSubmitButton(
              label: widget.missingTokenLoginLabel,
              isSubmitting: false,
              onPressed: widget.onMissingTokenLogin,
            ),
    );
  }
}
