import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';

/// Common callback types used throughout the intake feature
/// This standardizes interfaces and improves code readability

/// Callback when a person is selected
typedef PersonSelectedCallback = void Function(MemoryOsoba person);

/// Callback when a file is uploaded  
typedef FileUploadedCallback = void Function(String filePath);

/// Callback for save operations (no BuildContext — async-safe)
typedef SaveCallback = Future<void> Function(bool markAsArrived);

/// Callback for form validation
typedef ValidationCallback = bool Function();

/// Callback when validation function is set
typedef ValidationSetterCallback = void Function(ValidationCallback? validate);

/// Callback when person data is edited
typedef PersonEditedCallback = void Function(MemoryOsoba person);

/// Simple refresh callback
typedef IntakeRefreshCallback = VoidCallback;
