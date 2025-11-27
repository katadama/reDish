import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:coo_list/config/list_type_constants.dart';
import 'package:coo_list/logic/scan/scan_event.dart';
import 'package:coo_list/logic/scan/scan_state.dart';
import 'package:coo_list/services/openrouter_service.dart';
import 'package:coo_list/services/camera_manager.dart';
import 'package:coo_list/data/models/product_model.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final OpenRouterService _openRouterService;
  final CameraManager _cameraManager;

  ScanBloc({
    required OpenRouterService openRouterService,
    CameraManager? cameraManager,
  })  : _openRouterService = openRouterService,
        _cameraManager = cameraManager ?? CameraManager(),
        super(const ScanInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<CaptureImage>(_onCaptureImage);
    on<AnalyzeImage>(_onAnalyzeImage);
    on<CancelAnalysis>(_onCancelAnalysis);
    on<RetakeImage>(_onRetakeImage);
    on<ToggleManualEntry>(_onToggleManualEntry);
    on<AnalyzeTextProduct>(_onAnalyzeTextProduct);
  }

  CameraController? get cameraController => _cameraManager.controller;

  Future<void> _onInitializeCamera(
      InitializeCamera event, Emitter<ScanState> emit) async {
    emit(const ScanInitial());

    final error = await _cameraManager.initialize();
    if (error != null) {
      emit(ScanCameraError(error));
      return;
    }

    emit(const ScanCameraReady());
  }

  Future<void> _onCaptureImage(
      CaptureImage event, Emitter<ScanState> emit) async {
    if (!_cameraManager.isInitialized) {
      emit(const ScanCameraError('Kamera nincs inicializálva'));
      return;
    }

    final imagePath = await _cameraManager.captureImage();
    if (imagePath == null) {
      emit(const ScanCameraError('Nem sikerült képet készíteni'));
      return;
    }

    final File image = File(imagePath);
    emit(ScanImageCaptured(image));
  }

  Future<void> _onAnalyzeImage(
      AnalyzeImage event, Emitter<ScanState> emit) async {
    emit(ScanAnalyzing(event.image));

    try {
      final response =
          await _openRouterService.analyzeImageProduct(event.image);

      final product = ProductModel.fromJson(response);

      if (product.error != null) {
        emit(ScanAnalysisError(
          message: 'Kép analizálása nem sikerült: ${product.error!}',
          image: event.image,
        ));
        return;
      }

      emit(ScanAnalysisSuccess(
        product: product,
        image: event.image,
        initialListType: event.initialListType ?? ListType.home,
      ));
    } catch (e) {
      emit(ScanAnalysisError(
        message: 'Nem sikerült a kép analizálása: $e',
        image: event.image,
      ));
    }
  }

  void _onCancelAnalysis(CancelAnalysis event, Emitter<ScanState> emit) {
    emit(const ScanCameraReady());
  }

  void _onRetakeImage(RetakeImage event, Emitter<ScanState> emit) {
    emit(const ScanCameraReady());
  }

  void _onToggleManualEntry(ToggleManualEntry event, Emitter<ScanState> emit) {
    if (state is ScanManualEntry) {
      emit(const ScanCameraReady());
    } else {
      emit(const ScanManualEntry());
    }
  }

  Future<void> _onAnalyzeTextProduct(
      AnalyzeTextProduct event, Emitter<ScanState> emit) async {
    emit(const ScanTextAnalyzing());

    try {
      final response = await _openRouterService.analyzeTextProduct(event.text);

      final product = ProductModel.fromJson(response);

      if (product.error != null) {
        emit(ScanTextAnalysisError(
          message: 'Szöveg analizálása nem sikerült: ${product.error!}',
        ));
        return;
      }

      emit(ScanAnalysisSuccess(
        product: product,
        image: null,
        initialListType: event.initialListType ?? ListType.shopping,
      ));
    } catch (e) {
      emit(ScanTextAnalysisError(
        message: 'Nem sikerült a szöveg analizálása: $e',
      ));
    }
  }

  @override
  Future<void> close() async {
    await _cameraManager.dispose();
    return super.close();
  }
}
