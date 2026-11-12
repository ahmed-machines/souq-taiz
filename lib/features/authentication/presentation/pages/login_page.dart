import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_form_card.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final failure = await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text, _password.text);
    if (failure != null && mounted) {
      showToast(context, failure.message(AppLocalizations.of(context)));
    }
    // On success the router redirects automatically (auth state changes).
  }

  Future<void> _google() async {
    final failure = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();
    if (failure != null && mounted) {
      showToast(context, failure.message(AppLocalizations.of(context)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loading = ref.watch(authControllerProvider).isLoading;
    return AuthFormCard(
      title: l10n.login,
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              children: [
                AppTextField(
                  controller: _email,
                  label: l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.email(v)?.message(l10n),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _password,
                  label: l10n.password,
                  obscure: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (v) => Validators.required(v)?.message(l10n),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: l10n.login, isLoading: loading, onPressed: _submit),
        TextButton(
          onPressed: () => context.go(RouteNames.forgotPassword),
          child: Text(l10n.forgotPassword),
        ),
        OutlinedButton.icon(
          onPressed: loading ? null : _google,
          icon: const Icon(Icons.g_mobiledata),
          label: Text(l10n.continueGoogle),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.noAccount),
            TextButton(
              onPressed: () => context.go(RouteNames.register),
              child: Text(l10n.register),
            ),
          ],
        ),
      ],
    );
  }
}
