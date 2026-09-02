import 'package:flutter/material.dart';

import '../../core/localization.dart';
import '../../core/reading_settings.dart';
import '../../core/responsive_layout.dart';
import '../../core/stem_background.dart';
import 'auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.controller, super.key});

  final AuthController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.clearLoginError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await widget.controller.login(
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [TextSizeButton()]),
      body: StemBackgroundBody(
        child: Center(
          child: SingleChildScrollView(
            padding: pagePadding(context),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: 480 * readingScale(context)),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) => AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppStrings.get('login'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(AppStrings.get('loginHelp')),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _emailController,
                            enabled: !widget.controller.isLoggingIn,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username],
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            decoration: InputDecoration(
                              labelText: AppStrings.get('email'),
                              hintText: AppStrings.get('emailHint'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            enabled: !widget.controller.isLoggingIn,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: AppStrings.get('password'),
                              hintText: AppStrings.get('passwordHint'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed:
                                widget.controller.isLoggingIn ? null : _submit,
                            child: Text(
                              widget.controller.isLoggingIn
                                  ? AppStrings.get('loading')
                                  : AppStrings.get('login'),
                            ),
                          ),
                          if (widget.controller.hasLoginError) ...[
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.get('invalidCredentials'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
