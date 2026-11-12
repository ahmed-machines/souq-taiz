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

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final failure = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text);
    if (!mounted) return;
    showToast(context, failure?.message(l10n) ?? l10n.resetSent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthFormCard(
      title: l10n.forgotPassword,
      children: [
        Form(
          key: _form,
          child: AppTextField(
            controller: _email,
            label: l10n.email,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _submit(),
            validator: (v) => Validators.email(v)?.message(l10n),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.sendResetLink,
          isLoading: ref.watch(authControllerProvider).isLoading,
          onPressed: _submit,
        ),
        TextButton(
          onPressed: () => context.go(RouteNames.login),
          child: Text(l10n.login),
        ),
      ],
    );
  }
}
