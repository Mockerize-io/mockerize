import 'package:flutter/material.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';

abstract class MockerizeAbstractController {
  String? error;
  final bool? loading;
  final bool? required;
  final String? Function(String? value)? validation;

  MockerizeAbstractController({
    this.error,
    this.loading,
    this.required,
    this.validation,
  });
}

class MockerizeTextController extends MockerizeAbstractController {
  final TextEditingController controller;
  final String? value;

  MockerizeTextController({
    this.value,
    required this.controller,
    super.error,
    super.loading,
    super.required,
    super.validation,
  });
}

class MockerizeStatusController extends MockerizeAbstractController {
  final Status? value;

  MockerizeStatusController({
    this.value,
    super.error,
    super.loading,
    super.required,
    super.validation,
  });
}
