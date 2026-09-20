import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/core/routing/platform_paths.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_auth_scaffold.dart';
import 'package:fitcore_client/features/platform/auth/api/platform_auth_api.dart';
import 'package:fitcore_client/features/platform/auth/models/platform_verify_request.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlatformVerifyPage extends StatefulWidget {
  const PlatformVerifyPage({super.key, this.token});

  final String? token;

  @override
  State<PlatformVerifyPage> createState() => _PlatformVerifyPageState();
}

class _PlatformVerifyPageState extends State<PlatformVerifyPage> {
  final _platformAuthApi = PlatformAuthApi();

  bool _started = false;
  bool _isVerifying = true;
  String? _errorTitle;
  String? _errorBody;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    if (_started) return;
    _started = true;

    final token = widget.token?.trim();
    if (token == null || token.isEmpty) {
      setState(() {
        _isVerifying = false;
        _errorTitle = 'Invalid sign-in link';
        _errorBody = 'This link is missing a token. Request a new one from the login page.';
      });
      return;
    }

    try {
      final response = await _platformAuthApi.verify(
        PlatformVerifyRequest(token: token),
      );

      if (response.accessToken.isEmpty) {
        throw ApiException(
          'This sign-in link is invalid or has expired.',
          statusCode: 401,
        );
      }

      ApiClient.instance.setAccessToken(response.accessToken);

      if (!mounted) return;
      context.go(PlatformPaths.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      final expired =
          e.statusCode == 401 ||
          e.message.toLowerCase().contains('expired') ||
          e.message.toLowerCase().contains('invalid');
      setState(() {
        _isVerifying = false;
        _errorTitle = expired
            ? 'Link expired or already used'
            : 'Sign-in failed';
        _errorBody = expired
            ? 'This magic link can only be used once. Go back to login to get a new email.'
            : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorTitle = 'Sign-in failed';
        _errorBody = 'Something went wrong while signing in. Try again from the login page.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    if (_isVerifying) {
      return Scaffold(
        backgroundColor: t.canvas,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: FitCoreSpace.x5),
                Text(
                  'Signing you in…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FitAuthScaffold(
      title: _errorTitle ?? 'Unable to sign in',
      subtitle: _errorBody ?? 'Request a new sign-in link.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(FitCoreSpace.x3),
            decoration: BoxDecoration(
              color: t.stateNegative.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(FitCoreRadius.md),
              border: Border.all(
                color: t.stateNegative.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.link_off, size: 18, color: t.stateNegative),
                const SizedBox(width: FitCoreSpace.x3),
                Expanded(
                  child: Text(
                    'This link can no longer be used.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.stateNegative,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FitCoreSpace.x5),
          FitAuthSubmitButton(
            label: 'Back to login',
            isSubmitting: false,
            onPressed: () => context.go(PlatformPaths.login),
          ),
        ],
      ),
    );
  }
}
