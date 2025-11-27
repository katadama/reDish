import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends ScanEvent {
  const InitializeCamera();
}

class CaptureImage extends ScanEvent {
  const CaptureImage();
}

class AnalyzeImage extends ScanEvent {
  final File image;
  final int? initialListType;

  const AnalyzeImage(this.image, {this.initialListType});

  @override
  List<Object?> get props => [image, initialListType];
}

class CancelAnalysis extends ScanEvent {
  const CancelAnalysis();
}

class RetakeImage extends ScanEvent {
  const RetakeImage();
}

class ToggleManualEntry extends ScanEvent {
  const ToggleManualEntry();
}

class AnalyzeTextProduct extends ScanEvent {
  final String text;
  final int? initialListType;

  const AnalyzeTextProduct(this.text, {this.initialListType});

  @override
  List<Object?> get props => [text, initialListType];
}
