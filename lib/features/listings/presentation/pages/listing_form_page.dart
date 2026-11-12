import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/localization/message_mapper.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/validators/validators.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../../../shared/widgets/page_container.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../categories/presentation/controllers/category_providers.dart';
import '../../../locations/presentation/controllers/location_providers.dart';
import '../../domain/entities/listing.dart';
import '../../domain/usecases/listing_input.dart';
import '../controllers/listing_providers.dart';
import '../widgets/image_reorder_strip.dart';

/// Create (editId == null) or edit a listing.
class ListingFormPage extends ConsumerStatefulWidget {
  const ListingFormPage({super.key, this.editId});

  final String? editId;

  @override
  ConsumerState<ListingFormPage> createState() => _ListingFormPageState();
}

class _ListingFormPageState extends ConsumerState<ListingFormPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _phone = TextEditingController();
  String? _categoryId;
  String? _subcategoryId;
  String? _locationId;
  PriceType _priceType = PriceType.fixed;
  List<ListingImage> _images = [];
  ValidationError? _imageError;
  bool _saving = false;
  bool _loading = false;
  Listing? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) {
      _loading = true;
      Future.microtask(_loadExisting);
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _description, _price, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final user = ref.read(currentUserProvider);
    final listing = await ref
        .read(listingRepositoryProvider)
        .getById(widget.editId!);
    if (!mounted) return;
    if (listing == null || listing.ownerId != user?.uid) {
      context.go(RouteNames.seller);
      return;
    }
    setState(() {
      _existing = listing;
      _title.text = listing.title;
      _description.text = listing.description;
      _price.text = listing.price.toString();
      _phone.text = listing.contactPhone;
      _categoryId = listing.categoryId;
      _subcategoryId = listing.subcategoryId;
      _locationId = listing.locationId;
      _priceType = listing.priceType;
      _images = [for (final u in listing.imageUrls) RemoteImage(u)];
      _loading = false;
    });
  }

  Future<void> _pickImages() async {
    final l10n = AppLocalizations.of(context);
    // Resize/compress at pick time: max 1600px, JPEG quality 80.
    final files = await ImagePicker().pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    ValidationError? error;
    final added = <ListingImage>[];
    for (final f in files) {
      if (_images.length + added.length >= Validators.maxImages) {
        error = ValidationError.tooManyImages;
        break;
      }
      final bytes = await f.readAsBytes();
      final e = Validators.image(fileName: f.name, bytes: bytes.length);
      if (e != null) {
        error = e;
        continue;
      }
      added.add(LocalImage(PickedImage(name: f.name, bytes: bytes)));
    }
    if (!mounted) return;
    setState(() {
      _images = [..._images, ...added];
      _imageError = error;
    });
    if (error != null) showToast(context, error.message(l10n));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(currentUserProvider);
    final formOk = _form.currentState!.validate();
    final imgErr = _images.isEmpty ? ValidationError.noImages : null;
    setState(() => _imageError = imgErr);
    if (!formOk || imgErr != null || user == null) return;

    setState(() => _saving = true);
    final result = await ref
        .read(submitListingProvider)
        .call(
          owner: user,
          existingId: widget.editId,
          existingCreatedAt: _existing?.createdAt,
          images: _images,
          input: ListingInput(
            title: _title.text,
            description: _description.text,
            categoryId: _categoryId,
            subcategoryId: _subcategoryId,
            locationId: _locationId,
            price: num.tryParse(_price.text.trim()),
            priceType: _priceType,
            contactPhone: _phone.text,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      success: (_) {
        ref
          ..invalidate(myListingsProvider)
          ..invalidate(sellerStatsProvider);
        showToast(context, l10n.listingSubmitted);
        context.go(RouteNames.seller);
      },
      failure: (f) => showToast(context, f.message(l10n)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    if (!ref.watch(firebaseReadyProvider)) {
      return PageContainer(
        child: EmptyState(
          message: l10n.errConfiguration,
          icon: Icons.cloud_off,
        ),
      );
    }
    if (_loading) return const PageContainer(child: SkeletonBox(height: 300));

    final categories = ref.watch(topCategoriesProvider);
    final subs = ref.watch(subcategoriesProvider(_categoryId));
    final locations = ref.watch(locationsProvider).value ?? const [];
    const gap = SizedBox(height: AppSpacing.md);

    return PageContainer(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.editId == null ? l10n.createListing : l10n.editListing,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                gap,
                AppTextField(
                  controller: _title,
                  label: l10n.listingTitle,
                  maxLength: Validators.titleMax,
                  validator: (v) => Validators.title(v)?.message(l10n),
                ),
                AppTextField(
                  controller: _description,
                  label: l10n.description,
                  maxLines: 5,
                  maxLength: Validators.descriptionMax,
                  validator: (v) => Validators.description(v)?.message(l10n),
                ),
                gap,
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.category),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name.of(lang)),
                      ),
                  ],
                  validator: (v) => v == null ? l10n.vRequired : null,
                  onChanged: (v) => setState(() {
                    _categoryId = v;
                    _subcategoryId = null;
                  }),
                ),
                if (subs.isNotEmpty) ...[
                  gap,
                  DropdownButtonFormField<String?>(
                    key: ValueKey('sub-$_categoryId'),
                    initialValue: _subcategoryId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.subcategory),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.allOption),
                      ),
                      for (final c in subs)
                        DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name.of(lang)),
                        ),
                    ],
                    onChanged: (v) => setState(() => _subcategoryId = v),
                  ),
                ],
                gap,
                DropdownButtonFormField<String>(
                  initialValue: _locationId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.location),
                  items: [
                    for (final l in locations)
                      DropdownMenuItem(
                        value: l.id,
                        child: Text(l.name.of(lang)),
                      ),
                  ],
                  validator: (v) => v == null ? l10n.vRequired : null,
                  onChanged: (v) => setState(() => _locationId = v),
                ),
                gap,
                AppTextField(
                  controller: _price,
                  label: l10n.priceLabel,
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.price(
                    num.tryParse((v ?? '').trim()),
                  )?.message(l10n),
                ),
                gap,
                SegmentedButton<PriceType>(
                  segments: [
                    ButtonSegment(
                      value: PriceType.fixed,
                      label: Text(l10n.fixedPrice),
                    ),
                    ButtonSegment(
                      value: PriceType.negotiable,
                      label: Text(l10n.negotiable),
                    ),
                  ],
                  selected: {_priceType},
                  onSelectionChanged: (s) =>
                      setState(() => _priceType = s.first),
                ),
                gap,
                AppTextField(
                  controller: _phone,
                  label: l10n.contactPhone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => Validators.phone(v)?.message(l10n),
                ),
                gap,
                Text(
                  l10n.images,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  l10n.imagesHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_images.isNotEmpty)
                  ImageReorderStrip(
                    images: _images,
                    onChanged: (v) => setState(() => _images = v),
                  ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(l10n.addImages),
                  ),
                ),
                if (_imageError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      _imageError!.message(l10n),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.submitForReview,
                  isLoading: _saving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
