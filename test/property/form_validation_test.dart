import 'package:flutter_base_2025/core/utils/form_controller.dart';
import 'package:flutter_base_2025/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown, setUpAll, tearDownAll;

// Configure Glados for 100 iterations
final _explore = ExploreConfig(numRuns: 100);

/// **Feature: flutter-state-of-art-2025, Property 6: Form Validation Composition**
/// **Validates: Requirements 25.2**
void main() {
  group('Form Validation Properties', () {
    group('FieldController', () {
      test('initial state is valid with no validators', () {
        final controller = FieldController<String>();
        expect(controller.isValid, isTrue);
        expect(controller.error, isNull);
      });

      test('setValue marks field as dirty', () {
        final controller = FieldController<String>();
        expect(controller.isDirty, isFalse);

        controller.setValue('test');
        expect(controller.isDirty, isTrue);
      });

      test('touch marks field as touched', () {
        final controller = FieldController<String>();
        expect(controller.isTouched, isFalse);

        controller.touch();
        expect(controller.isTouched, isTrue);
      });

      test('reset clears state', () {
        final controller = FieldController<String>(initialValue: 'initial');
        controller.setValue('changed');
        controller.touch();

        controller.reset();
        expect(controller.value, isNull);
        expect(controller.isDirty, isFalse);
        expect(controller.isTouched, isFalse);
      });

      test('reset with value sets new initial', () {
        final controller = FieldController<String>();
        controller.reset('new value');
        expect(controller.value, equals('new value'));
      });
    });

    group('Validators', () {
      /// Property 6: Form Validation Composition
      /// For any composed validators, validation SHALL fail on first error
      /// and return that error message.
      Glados<String>(any.nonEmptyLetters, _explore).test(
        'compose returns first error',
        (value) {
          final validator = FormValidators.combine([
            FormValidators.required,
            FormValidators.minLength(5),
            FormValidators.email,
          ]);

          final error = validator(value);

          // If value is empty, should get required error
          if (value.isEmpty) {
            expect(error, contains('required'));
          }
          // If value is short, should get minLength error
          else if (value.length < 5) {
            expect(error, contains('5'));
          }
          // Otherwise check email format
          else if (!Validators.isValidEmail(value)) {
            expect(error, contains('email'));
          }
        },
      );

      test('required validator fails on empty', () {
        expect(FormValidators.required(''), isNotNull);
        expect(FormValidators.required(null), isNotNull);
        expect(FormValidators.required('value'), isNull);
      });

      test('email validator validates format', () {
        expect(FormValidators.email('invalid'), isNotNull);
        expect(FormValidators.email('test@example.com'), isNull);
      });

      test('minLength validator checks length', () {
        final validator = FormValidators.minLength(5);
        expect(validator('abc'), isNotNull);
        expect(validator('abcde'), isNull);
      });

      test('maxLength validator checks length', () {
        final validator = FormValidators.maxLength(5);
        expect(validator('abcdef'), isNotNull);
        expect(validator('abcde'), isNull);
      });

      test('combine runs validators in order', () {
        final validator = FormValidators.combine([
          (_) => 'first error',
          (_) => 'second error',
        ]);

        expect(validator('any'), equals('first error'));
      });

      test('combine returns null when all pass', () {
        final validator = FormValidators.combine([
          (_) => null,
          (_) => null,
        ]);

        expect(validator('any'), isNull);
      });
    });

    group('FormController', () {
      test('registerField creates controller', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        final field = form.registerField<String>('name');
        expect(field, isA<FieldController<String>>());
      });

      test('registerField returns existing controller', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        final field1 = form.registerField<String>('name');
        final field2 = form.registerField<String>('name');
        expect(identical(field1, field2), isTrue);
      });

      test('getValue returns field value', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        form.registerField<String>('name', initialValue: 'test');
        expect(form.getValue<String>('name'), equals('test'));
      });

      test('setValue updates field', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        form.registerField<String>('name');
        form.setValue('name', 'new value');
        expect(form.getValue<String>('name'), equals('new value'));
      });

      test('toMap returns all values', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        form.registerField<String>('name', initialValue: 'John');
        form.registerField<int>('age', initialValue: 30);

        final map = form.toMap();
        expect(map['name'], equals('John'));
        expect(map['age'], equals(30));
      });

      test('isValid checks all fields', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        form.registerField<String>(
          'name',
          validators: [FormValidators.required],
        );

        expect(form.isValid, isTrue); // No validation run yet
      });

      test('isDirty checks any field dirty', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        form.registerField<String>('name');
        form.registerField<String>('email');

        expect(form.isDirty, isFalse);

        form.setValue('name', 'test');
        expect(form.isDirty, isTrue);
      });

      test('touchAll touches all fields', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        final name = form.registerField<String>('name');
        final email = form.registerField<String>('email');

        form.touchAll();

        expect(name.isTouched, isTrue);
        expect(email.isTouched, isTrue);
      });

      test('reset clears all fields', () {
        final form = FormController<Map<String, dynamic>>(
          fromMap: (map) => map,
        );

        final name = form.registerField<String>('name');
        name.setValue('test');
        name.touch();

        form.reset();

        expect(name.value, isNull);
        expect(name.isDirty, isFalse);
        expect(name.isTouched, isFalse);
      });
    });

    group('FieldState', () {
      test('initial state properties', () {
        const state = FieldState<String>();
        expect(state.value, isNull);
        expect(state.error, isNull);
        expect(state.isDirty, isFalse);
        expect(state.isTouched, isFalse);
        expect(state.isValidating, isFalse);
        expect(state.isValid, isTrue);
        expect(state.hasError, isFalse);
        expect(state.showError, isFalse);
      });

      test('showError only when touched and has error', () {
        const stateWithError = FieldState<String>(
          error: 'error',
          isTouched: true,
        );
        expect(stateWithError.showError, isTrue);

        const stateNotTouched = FieldState<String>(error: 'error');
        expect(stateNotTouched.showError, isFalse);

        const stateNoError = FieldState<String>(isTouched: true);
        expect(stateNoError.showError, isFalse);
      });

      test('copyWith preserves values', () {
        const state = FieldState<String>(
          value: 'test',
          error: 'error',
          isDirty: true,
          isTouched: true,
        );

        final copied = state.copyWith();
        expect(copied.value, equals('test'));
        expect(copied.error, equals('error'));
        expect(copied.isDirty, isTrue);
        expect(copied.isTouched, isTrue);
      });

      test('copyWith clearError removes error', () {
        const state = FieldState<String>(error: 'error');
        final cleared = state.copyWith(clearError: true);
        expect(cleared.error, isNull);
      });
    });
  });
}
