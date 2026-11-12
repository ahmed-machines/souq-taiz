import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/app/localization/generated/app_localizations.dart';
import 'package:souq_taiz/app/localization/message_mapper.dart';
import 'package:souq_taiz/app/theme/app_spacing.dart';
import 'package:souq_taiz/core/validators/validators.dart';
import 'package:souq_taiz/core/widgets/form_widgets.dart';
import 'package:souq_taiz/features/listings/domain/entities/listing.dart';
import 'package:souq_taiz/features/listings/presentation/widgets/listing_card.dart';
import 'package:souq_taiz/features/search/domain/search_query.dart';
import 'package:souq_taiz/features/search/presentation/widgets/search_filters.dart';

import '../helpers/test_app.dart';

final _listing = Listing(
  id: 'l1',
  ownerId: 'o',
  ownerName: 'Owner',
  title: 'Toyota Corolla 2015',
  description: 'A long enough description',
  categoryId: 'cars',
  locationId: 'taiz',
  price: 6500000,
  priceType: PriceType.negotiable,
  imageUrls: const [],
  contactPhone: '777123456',
  status: ListingStatus.published,
  isFeatured: true,
  createdAt: DateTime(2026),
);

// ---------------------------------------------------------------------------
// Minimal standalone form widgets — test validation without page-level routing
// ---------------------------------------------------------------------------

class _LoginTestForm extends StatefulWidget {
  const _LoginTestForm();
  @override
  State<_LoginTestForm> createState() => _LoginTestFormState();
}

class _LoginTestFormState extends State<_LoginTestForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => _form.currentState!.validate();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _email,
            label: l10n.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => Validators.email(v)?.message(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _password,
            label: l10n.password,
            obscure: true,
            validator: (v) => Validators.required(v)?.message(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: _submit, child: Text(l10n.login)),
        ],
      ),
    );
  }
}

class _RegisterTestForm extends StatefulWidget {
  const _RegisterTestForm();
  @override
  State<_RegisterTestForm> createState() => _RegisterTestFormState();
}

class _RegisterTestFormState extends State<_RegisterTestForm> {
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

  void _submit() => _form.currentState!.validate();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _name,
            label: l10n.fullName,
            validator: (v) => Validators.title(v)?.message(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _email,
            label: l10n.email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => Validators.email(v)?.message(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _phone,
            label: l10n.phone,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? null
                : Validators.phone(v)?.message(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _password,
            label: l10n.password,
            obscure: true,
            validator: (v) => Validators.password(v)?.message(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _confirm,
            label: l10n.confirmPassword,
            obscure: true,
            validator: (v) =>
                Validators.confirmPassword(v, _password.text)?.message(l10n),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: _submit, child: Text(l10n.register)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

void main() {
  testWidgets('ListingCard shows title, price, badges and handles taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      testApp(
        SizedBox(
          height: 300,
          width: 220,
          child: ListingCard(
            listing: _listing,
            onTap: () => taps++,
            showFavorite: false,
          ),
        ),
        locale: const Locale('en'),
      ),
    );
    expect(find.text('Toyota Corolla 2015'), findsOneWidget);
    expect(find.text('6,500,000 YER'), findsOneWidget);
    expect(find.text('Negotiable'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    await tester.tap(find.byType(GestureDetector).first);
    expect(taps, 1);
  });

  testWidgets('Login form validates empty and malformed input', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(testApp(const _LoginTestForm()));
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    expect(find.text('بريد إلكتروني غير صالح'), findsNothing);
    expect(find.text('هذا الحقل مطلوب'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    expect(find.text('بريد إلكتروني غير صالح'), findsOneWidget);
  });

  testWidgets('Register form checks password strength and confirmation', (
    tester,
  ) async {
    useTallViewport(tester);
    await tester.pumpWidget(
      testApp(const _RegisterTestForm(), locale: const Locale('en')),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ahmed Ali');
    await tester.enterText(fields.at(1), 'a@b.co');
    await tester.enterText(fields.at(3), 'weak');
    await tester.enterText(fields.at(4), 'different1');
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    expect(
      find.text('At least 8 characters with a letter and a digit'),
      findsOneWidget,
    );
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('SearchFilters emits the applied query', (tester) async {
    SearchQuery? emitted;
    await tester.pumpWidget(
      testApp(
        SearchFilters(
          query: const SearchQuery(),
          onChanged: (q) => emitted = q,
        ),
        locale: const Locale('en'),
      ),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'toyota');
    await tester.enterText(fields.at(1), '1000');
    await tester.enterText(fields.at(2), '5000');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Search'));
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pump();
    expect(emitted?.keyword, 'toyota');
    expect(emitted?.minPrice, 1000);
    expect(emitted?.maxPrice, 5000);

    await tester.ensureVisible(find.text('Clear filters'));
    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    expect(emitted, const SearchQuery());
  });
}
