import 'dart:async';

import 'package:flutter/widgets.dart';

/// Validator function type.
typedef Validator<T> = String? Function(T? value);

/// Async validator function type.
typedef AsyncValidator<T> = Future<String?> Function(T? value);

/// Field state.
class FieldState<T> {
  const FieldState({
    this.value,
    this.error,
    this.isDirty = false,
    this.isTouched = false,
    this.isValidating = false,
  });
  final T? value;
  final String? error;
  final bool isDirty;
  final bool isTouched;
  final bool isValidating;

  FieldState<T> copyWith({
    T? value,
    String? error,
    bool? isDirty,
    bool? isTouched,
    bool? isValidating,
    bool clearError = false,
  }) => FieldState<T>(
    value: value ?? this.value,
    error: clearError ? null : (error ?? this.error),
    isDirty: isDirty ?? this.isDirty,
    isTouched: isTouched ?? this.isTouched,
    isValidating: isValidating ?? this.isValidating,
  );

  bool get isValid => error == null;
  bool get hasError => error != null;
  bool get showError => isTouched && hasError;
}

/// Form field controller.
class FieldController<T> extends ChangeNotifier {
  FieldController({
    T? initialValue,
    List<Validator<T>>? validators,
    List<AsyncValidator<T>>? asyncValidators,
    Duration debounce = const Duration(milliseconds: 300),
  }) : _state = FieldState<T>(value: initialValue),
       _validators = validators ?? [],
       _asyncValidators = asyncValidators ?? [],
       _debounce = debounce;
  FieldState<T> _state;
  final List<Validator<T>> _validators;
  final List<AsyncValidator<T>> _asyncValidators;
  Timer? _debounceTimer;
  final Duration _debounce;

  FieldState<T> get state => _state;
  T? get value => _state.value;
  String? get error => _state.error;
  bool get isValid => _state.isValid;
  bool get isDirty => _state.isDirty;
  bool get isTouched => _state.isTouched;

  void setValue(T? value) {
    _state = _state.copyWith(value: value, isDirty: true, clearError: true);
    notifyListeners();
    _scheduleValidation();
  }

  void touch() {
    if (!_state.isTouched) {
      _state = _state.copyWith(isTouched: true);
      notifyListeners();
    }
  }

  void reset([T? value]) {
    _state = FieldState<T>(value: value);
    notifyListeners();
  }

  void _scheduleValidation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, validate);
  }

  Future<bool> validate() async {
    // Run sync validators
    for (final validator in _validators) {
      final error = validator(_state.value);
      if (error != null) {
        _state = _state.copyWith(error: error);
        notifyListeners();
        return false;
      }
    }

    // Run async validators
    if (_asyncValidators.isNotEmpty) {
      _state = _state.copyWith(isValidating: true);
      notifyListeners();

      for (final validator in _asyncValidators) {
        final error = await validator(_state.value);
        if (error != null) {
          _state = _state.copyWith(error: error, isValidating: false);
          notifyListeners();
          return false;
        }
      }

      _state = _state.copyWith(isValidating: false, clearError: true);
      notifyListeners();
    }

    _state = _state.copyWith(clearError: true);
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Generic form controller.
class FormController<T> extends ChangeNotifier {
  FormController({required T Function(Map<String, dynamic>) fromMap})
    : _fromMap = fromMap;
  final Map<String, FieldController<dynamic>> _fields = {};
  final T Function(Map<String, dynamic>) _fromMap;
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;
  bool get isValid => _fields.values.every((f) => f.isValid);
  bool get isDirty => _fields.values.any((f) => f.isDirty);

  /// Registers a field.
  FieldController<V> registerField<V>(
    String name, {
    V? initialValue,
    List<Validator<V>>? validators,
    List<AsyncValidator<V>>? asyncValidators,
  }) {
    if (_fields.containsKey(name)) {
      return _fields[name]! as FieldController<V>;
    }

    final controller = FieldController<V>(
      initialValue: initialValue,
      validators: validators,
      asyncValidators: asyncValidators,
    );

    controller.addListener(notifyListeners);
    _fields[name] = controller;
    return controller;
  }

  /// Gets a field controller.
  FieldController<V>? getField<V>(String name) =>
      _fields[name] as FieldController<V>?;

  /// Gets field value.
  V? getValue<V>(String name) => _fields[name]?.value as V?;

  /// Sets field value.
  void setValue<V>(String name, V? value) {
    _fields[name]?.setValue(value);
  }

  /// Validates all fields.
  Future<bool> validate() async {
    final results = await Future.wait(_fields.values.map((f) => f.validate()));
    return results.every((valid) => valid);
  }

  /// Touches all fields.
  void touchAll() {
    for (final field in _fields.values) {
      field.touch();
    }
  }

  /// Resets all fields.
  void reset() {
    for (final field in _fields.values) {
      field.reset();
    }
    _isSubmitting = false;
    notifyListeners();
  }

  /// Gets form data as map.
  Map<String, dynamic> toMap() =>
      _fields.map((key, field) => MapEntry(key, field.value));

  /// Gets form data as typed object.
  T toObject() => _fromMap(toMap());

  /// Submits the form.
  Future<bool> submit(Future<void> Function(T data) onSubmit) async {
    touchAll();

    if (!await validate()) {
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      await onSubmit(toObject());
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }
}
