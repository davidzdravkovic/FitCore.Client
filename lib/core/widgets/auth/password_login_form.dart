import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/validation/validators.dart';
import 'package:fitcore_client/core/widgets/fit_auth_scaffold.dart';
import 'package:flutter/material.dart';

typedef PasswordLoginSubmit = Future<void> Function(
  String email,
  String password,
);

/// Shared email + password sign-in form used by staff and member portals.
class PasswordLoginForm extends StatefulWidget {
  const PasswordLoginForm({
    super.key,
    required this.subtitle,
    required this.onSubmit,
    this.emailHint = 'you@email.com',
    this.submitLabel = 'Continue',
    this.brandName = 'FitCore',
  });

  final String brandName;
  final String subtitle;
  final String emailHint;
  final String submitLabel;
  final PasswordLoginSubmit onSubmit;

  @override
  State<PasswordLoginForm> createState() => _PasswordLoginFormState();
}

class _PasswordLoginFormState extends State<PasswordLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
      await widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
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
      brandName: widget.brandName,
      title: 'Sign in',
      subtitle: widget.subtitle,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: widget.emailHint,
                  prefixIcon: const Icon(Icons.mail_outline, size: 18),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: FitCoreSpace.x4),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
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
              const SizedBox(height: FitCoreSpace.x6),
              FitAuthSubmitButton(
                label: widget.submitLabel,
                isSubmitting: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
