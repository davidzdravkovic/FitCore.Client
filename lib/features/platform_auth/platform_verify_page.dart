import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/platform_auth/api/platform_auth_api.dart';
import 'package:fitcore_client/features/platform_auth/api/platform_verify_models.dart';
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
      context.go('/platform');
    } on ApiException catch (e) {
      if (!mounted) return;
      final expired = e.statusCode == 401 ||
          e.message.toLowerCase().contains('expired') ||
          e.message.toLowerCase().contains('invalid');
      setState(() {
        _isVerifying = false;
        _errorTitle = expired ? 'Link expired or already used' : 'Sign-in failed';
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _isVerifying
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'Signing you in…',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.link_off,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorTitle ?? 'Unable to sign in',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorBody ?? 'Request a new sign-in link.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: () => context.go('/platform/login'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Back to login'),
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
