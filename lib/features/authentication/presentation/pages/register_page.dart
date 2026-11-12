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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final failure = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _email.text,
          password: _password.text,
          name: _name.text,
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        );
    if (failure != null && mounted) {
      showToast(context, failure.message(AppLocalizations.of(context)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loading = ref.watch(authControllerProvider).isLoading;
    return AuthFormCard(
      title: l10n.register,
      children: [
        Form(
          key: _form,
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: l10n.fullName,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.title(v)?.message(l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _email,
                label: l10n.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.email(v)?.message(l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _phone,
                label: l10n.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? null
                    : Validators.phone(v)?.message(l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _password,
                label: l10n.password,
                obscure: true,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.password(v)?.message(l10n),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _confirm,
                label: l10n.confirmPassword,
                obscure: true,
                onSubmitted: (_) => _submit(),
                validator: (v) => Validators.confirmPassword(
                  v,
                  _password.text,
                )?.message(l10n),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: l10n.register, isLoading: loading, onPressed: _submit),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.haveAccount),
            TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text(l10n.login),
            ),
          ],
        ),
      ],
    );
  }
}
