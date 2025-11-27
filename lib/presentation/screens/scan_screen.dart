import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/scan/scan_bloc.dart';
import 'package:coo_list/logic/scan/scan_event.dart';
import 'package:coo_list/logic/scan/scan_state.dart';
import 'package:coo_list/presentation/screens/product_details_screen.dart';
import 'package:coo_list/services/openrouter_service.dart';
import 'package:coo_list/data/models/product_model.dart';

class ScanScreen extends StatefulWidget {
  static const String routeName = '/scan';

  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  late final ScanBloc _scanBloc;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanBloc = ScanBloc(
      openRouterService: context.read<OpenRouterService>(),
    );
    _scanBloc.add(const InitializeCamera());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanBloc.close();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _scanBloc.cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _scanBloc.add(const InitializeCamera());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scanBloc,
      child: Scaffold(
        body: BlocConsumer<ScanBloc, ScanState>(
          listener: (context, state) {
            if (state is ScanAnalysisSuccess) {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                    product: state.product,
                    image: state.image,
                    initialListType: state.initialListType,
                  ),
                ),
              )
                  .then((_) {
                _scanBloc.add(const InitializeCamera());
              });
            }
          },
          builder: (context, state) {
            if (state is ScanInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF34744),
                ),
              );
            } else if (state is ScanCameraError) {
              return _buildErrorWidget(state.message);
            } else if (state is ScanCameraReady) {
              return _buildCameraPreview();
            } else if (state is ScanImageCaptured) {
              return _buildImagePreview(state.image);
            } else if (state is ScanAnalyzing) {
              return _buildAnalyzingWidget(state.image);
            } else if (state is ScanTextAnalyzing) {
              return _buildTextAnalyzingWidget();
            } else if (state is ScanAnalysisError) {
              return _buildAnalysisErrorWidget(state);
            } else if (state is ScanTextAnalysisError) {
              return _buildTextAnalysisErrorWidget(state);
            } else if (state is ScanManualEntry) {
              return _buildManualEntryWidget();
            } else {
              return const Center(
                child: Text('Ismeretlen állapot'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final cameraController = _scanBloc.cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF34744),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(cameraController),
        ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Helyezd a terméket közepére',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {
              _scanBloc.add(const ToggleManualEntry());
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                _scanBloc.add(const CaptureImage());
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(File image) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _scanBloc.add(const RetakeImage());
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Újra',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _scanBloc.add(AnalyzeImage(image));
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Analizálás'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAnalyzingWidget() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black87),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Szöveg analizálása',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kérlek várj egy pillanatot',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                _scanBloc.add(const ToggleManualEntry());
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white70,
              ),
              label: const Text(
                'Mégse',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingWidget(File image) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Termék analizálása',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kérlek várj egy pillanatot',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                _scanBloc.add(const CancelAnalysis());
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white70,
              ),
              label: const Text(
                'Vissza',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAnalysisErrorWidget(ScanTextAnalysisError state) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black87),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Szöveg analizálása nem sikerült',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    _textController.clear();
                    _scanBloc.add(const ToggleManualEntry());
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Próbáld újra a szöveges bevitelt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    _scanBloc.add(const InitializeCamera());
                  },
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    'Kamerára váltás',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisErrorWidget(ScanAnalysisError state) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Analizáció nem sikerült',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    _scanBloc.add(const RetakeImage());
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Új kép készítése'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                if (state.image != null) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      _scanBloc.add(AnalyzeImage(state.image!));
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'Próbáld újra',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryWidget() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Container(
            color: Colors.black87,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Termék hozzáadása szöveggel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            TextField(
                              controller: _textController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'SF Pro',
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Írd be a termék nevét és leírását',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontFamily: 'SF Pro',
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 17),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_textController.text.trim().isNotEmpty) {
                                    _scanBloc.add(AnalyzeTextProduct(
                                        _textController.text.trim()));
                                    _textController.clear();
                                  }
                                },
                                icon: const Icon(Icons.search,
                                    color: Colors.white, size: 22),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    'Analizálás',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(44),
                                  backgroundColor: const Color(0xFFF34744),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 1,
                                  shadowColor: const Color(0xFFF34744)
                                      .withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  const defaultProduct = ProductModel(
                                    name: 'Termék Neve',
                                    category: 'Gyümölcs',
                                    price: 0,
                                    weight: 0,
                                    db: 1,
                                    spoilage: 7,
                                  );
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(
                                        product: defaultProduct,
                                        image: File(''),
                                        initialListType: 2,
                                      ),
                                    ),
                                  )
                                      .then((_) {
                                    _scanBloc.add(const InitializeCamera());
                                  });
                                },
                                icon: const Icon(Icons.add,
                                    color: Color(0xFFF99B9B), size: 20),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 0.0),
                                  child: Text(
                                    'Manuális hozzáadás',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Color(0xFFF99B9B),
                                    ),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(38),
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFF99B9B),
                                  side: const BorderSide(
                                      color: Color(0xFFF99B9B), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                _scanBloc.add(const ToggleManualEntry());
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Kamera hiba',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _scanBloc.add(const InitializeCamera());
              },
              child: const Text('Próbáld újra'),
            ),
          ],
        ),
      ),
    );
  }
}
