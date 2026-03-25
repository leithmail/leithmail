import 'package:flutter_test/flutter_test.dart';
import 'package:leithmail/domain/entities/email_address.dart';

void main() {
  group('EmailAddress.parse', () {
    test('parses valid email', () {
      final email = EmailAddress.parse('test@example.com');
      expect(email.local, 'test');
      expect(email.domain, 'example.com');
    });

    test('throws on missing @', () {
      expect(() => EmailAddress.parse('invalid'), throwsFormatException);
    });

    test('throws on empty local part', () {
      expect(() => EmailAddress.parse('@example.com'), throwsFormatException);
    });

    test('throws on empty domain part', () {
      expect(() => EmailAddress.parse('test@'), throwsFormatException);
    });

    test('throws on multiple @ symbols', () {
      expect(
        () => EmailAddress.parse('test@test@example.com'),
        throwsFormatException,
      );
    });

    test('throws on empty string', () {
      expect(() => EmailAddress.parse(''), throwsFormatException);
    });
  });

  group('toString', () {
    test('returns full email address', () {
      final email = EmailAddress(local: 'test', domain: 'example.com');
      expect(email.toString(), 'test@example.com');
      expect(email.value, 'test@example.com');
    });

    test('parse and toString roundtrip', () {
      const raw = 'test@example.com';
      expect(EmailAddress.parse(raw).toString(), raw);
    });
  });

  group('equality', () {
    test('equal when local and domain match', () {
      final a = EmailAddress(local: 'test', domain: 'example.com');
      final b = EmailAddress(local: 'test', domain: 'example.com');
      expect(a, equals(b));
    });

    test('not equal when local differs', () {
      final a = EmailAddress(local: 'test1', domain: 'example.com');
      final b = EmailAddress(local: 'test2', domain: 'example.com');
      expect(a, isNot(equals(b)));
    });

    test('not equal when domain differs', () {
      final a = EmailAddress(local: 'test', domain: 'example1.com');
      final b = EmailAddress(local: 'test', domain: 'example2.com');
      expect(a, isNot(equals(b)));
    });

    test('hashCode is equal for equal addresses', () {
      final a = EmailAddress(local: 'test', domain: 'example.com');
      final b = EmailAddress(local: 'test', domain: 'example.com');
      expect(a.hashCode, b.hashCode);
    });

    test('hashCode differs for different addresses', () {
      final a = EmailAddress(local: 'test1', domain: 'example.com');
      final b = EmailAddress(local: 'test2', domain: 'example.com');
      expect(a.hashCode, isNot(b.hashCode));
    });

    test('usable as map key', () {
      final map = <EmailAddress, String>{};
      final email = EmailAddress.parse('test@example.com');
      map[email] = 'value';
      expect(map[EmailAddress.parse('test@example.com')], 'value');
    });
  });

  group('json serialization', () {
    test('serializes to json', () {
      final email = EmailAddress(local: 'test', domain: 'example.com');
      expect(email.toJson(), {'local': 'test', 'domain': 'example.com'});
    });

    test('deserializes from json', () {
      final email = EmailAddress.fromJson({
        'local': 'test',
        'domain': 'example.com',
      });
      expect(email.local, 'test');
      expect(email.domain, 'example.com');
    });

    test('json roundtrip', () {
      final email = EmailAddress.parse('test@example.com');
      expect(EmailAddress.fromJson(email.toJson()), equals(email));
    });
  });
}
