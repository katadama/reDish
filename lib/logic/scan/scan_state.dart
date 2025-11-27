import 'package:equatable/equatable.dart';
import 'package:coo_list/config/list_type_constants.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'dart:io';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {
  const ScanInitial();
}

class ScanCameraReady extends ScanState {
  const ScanCameraReady();
}

class ScanCameraError extends ScanState {
  final String message;

  const ScanCameraError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScanImageCaptured extends ScanState {
  final File image;

  const ScanImageCaptured(this.image);

  @override
  List<Object?> get props => [image];
}

class ScanAnalyzing extends ScanState {
  final File image;

  const ScanAnalyzing(this.image);

  @override
  List<Object?> get props => [image];
}

class ScanAnalysisSuccess extends ScanState {
  final ProductModel product;
  final File? image;
  final int initialListType;

  const ScanAnalysisSuccess({
    required this.product,
    this.image,
    this.initialListType = ListType.home,
  });

  @override
  List<Object?> get props => [product, image, initialListType];
}

class ScanAnalysisError extends ScanState {
  final String message;
  final File? image;

  const ScanAnalysisError({
    required this.message,
    this.image,
  });

  @override
  List<Object?> get props => [message, image];
}

class ScanManualEntry extends ScanState {
  const ScanManualEntry();
}

class ScanTextAnalysisError extends ScanState {
  final String message;

  const ScanTextAnalysisError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ScanTextAnalyzing extends ScanState {
  const ScanTextAnalyzing();
}
