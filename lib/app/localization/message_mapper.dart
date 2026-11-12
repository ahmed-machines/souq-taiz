import '../../core/errors/failure.dart';
import '../../core/validators/validators.dart';
import 'generated/app_localizations.dart';

/// Maps typed failures/validation errors to localized user-facing text.
extension FailureMessages on Failure {
  String message(AppLocalizations l) => switch (type) {
    FailureType.network => l.errNetwork,
    FailureType.unauthenticated => l.errUnauthenticated,
    FailureType.permissionDenied => l.errPermission,
    FailureType.notFound => l.errNotFound,
    FailureType.validation => l.errValidation,
    FailureType.configuration => l.errConfiguration,
    FailureType.invalidCredentials => l.errInvalidCredentials,
    FailureType.emailInUse => l.errEmailInUse,
    FailureType.weakPassword => l.errWeakPassword,
    FailureType.accountSuspended => l.errSuspended,
    FailureType.tooManyRequests => l.errTooMany,
    FailureType.cancelled || FailureType.unknown => l.errUnknown,
  };
}

extension ValidationMessages on ValidationError {
  String message(AppLocalizations l) => switch (this) {
    ValidationError.required => l.vRequired,
    ValidationError.invalidEmail => l.vEmail,
    ValidationError.weakPassword => l.vPassword,
    ValidationError.passwordMismatch => l.vPasswordMismatch,
    ValidationError.invalidPhone => l.vPhone,
    ValidationError.tooShort => l.vTooShort,
    ValidationError.tooLong => l.vTooLong,
    ValidationError.invalidPrice => l.vPrice,
    ValidationError.priceTooHigh => l.vPriceHigh,
    ValidationError.tooManyImages => l.vTooManyImages,
    ValidationError.noImages => l.vNoImages,
    ValidationError.invalidImageType => l.vImageType,
    ValidationError.imageTooLarge => l.vImageSize,
    ValidationError.invalidRating => l.vRating,
  };
}
