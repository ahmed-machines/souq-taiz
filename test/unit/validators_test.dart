import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/core/utils/contact_links.dart';
import 'package:souq_taiz/core/utils/price_formatter.dart';
import 'package:souq_taiz/core/validators/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email('a@b.co'), isNull);
      expect(Validators.email('bad'), ValidationError.invalidEmail);
      expect(Validators.email('  '), ValidationError.required);
    });

    test('password needs 8+ chars with letter and digit', () {
      expect(Validators.password('abcdefg1'), isNull);
      expect(Validators.password('abcdefgh'), ValidationError.weakPassword);
      expect(Validators.password('12345678'), ValidationError.weakPassword);
      expect(Validators.password('a1'), ValidationError.weakPassword);
    });

    test('confirm password', () {
      expect(Validators.confirmPassword('x', 'x'), isNull);
      expect(
        Validators.confirmPassword('x', 'y'),
        ValidationError.passwordMismatch,
      );
    });

    test('Yemeni phone formats', () {
      for (final ok in [
        '777123456',
        '0777123456',
        '+967777123456',
        '00967 777 123 456',
        '733-123-456',
      ]) {
        expect(Validators.phone(ok), isNull, reason: ok);
      }
      for (final bad in ['123', '877123456', '77712345', '']) {
        expect(Validators.phone(bad), isNotNull, reason: bad);
      }
    });

    test('title and description length', () {
      expect(Validators.title('abcd'), ValidationError.tooShort);
      expect(Validators.title('a' * 101), ValidationError.tooLong);
      expect(Validators.title('Good title'), isNull);
      expect(Validators.description('short'), ValidationError.tooShort);
    });

    test('price', () {
      expect(Validators.price(null), ValidationError.invalidPrice);
      expect(Validators.price(0), ValidationError.invalidPrice);
      expect(Validators.price(-5), ValidationError.invalidPrice);
      expect(Validators.price(1500), isNull);
      expect(
        Validators.price(Validators.maxPrice + 1),
        ValidationError.priceTooHigh,
      );
    });

    test('rating', () {
      expect(Validators.rating(0), ValidationError.invalidRating);
      expect(Validators.rating(6), ValidationError.invalidRating);
      expect(Validators.rating(3), isNull);
    });

    test('image type and size', () {
      expect(Validators.image(fileName: 'a.JPG', bytes: 100), isNull);
      expect(
        Validators.image(fileName: 'a.gif', bytes: 100),
        ValidationError.invalidImageType,
      );
      expect(
        Validators.image(fileName: 'noext', bytes: 100),
        ValidationError.invalidImageType,
      );
      expect(
        Validators.image(
          fileName: 'a.png',
          bytes: Validators.maxImageBytes + 1,
        ),
        ValidationError.imageTooLarge,
      );
    });
  });

  group('ContactLinks', () {
    test('normalizes Yemeni numbers', () {
      expect(ContactLinks.normalizeYemenPhone('0777123456'), '967777123456');
      expect(
        ContactLinks.normalizeYemenPhone('+967 777 123 456'),
        '967777123456',
      );
      expect(ContactLinks.normalizeYemenPhone('12345'), isNull);
    });

    test('builds a safe WhatsApp URL with encoded text', () {
      final uri = ContactLinks.whatsApp('777123456', message: 'hi & bye?')!;
      expect(uri.host, 'wa.me');
      expect(uri.path, '/967777123456');
      expect(uri.queryParameters['text'], 'hi & bye?');
      expect(uri.toString(), isNot(contains(' ')));
    });

    test('rejects invalid numbers (no URL injection)', () {
      expect(ContactLinks.whatsApp('777123456/../evil'), isNull);
      expect(ContactLinks.phoneCall('abc'), isNull);
    });
  });

  group('PriceFormatter', () {
    test('formats YER in Arabic and English', () {
      expect(PriceFormatter.format(1500000, locale: 'en'), '1,500,000 YER');
      expect(PriceFormatter.format(1500000, locale: 'ar'), endsWith('ر.ي'));
    });
  });
}
