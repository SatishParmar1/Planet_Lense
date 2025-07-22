import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../viewmodels/plant_identification_viewmodel.dart';
import '../widgets/plant_data_card.dart';

// Enum for camera operations
enum CameraOperation {
  initialize,
  takePicture,
  toggleFlash,
  dispose,
}

// Data class for camera operation with parameters
class CameraOperationData {
  final CameraOperation operation;
  final Map<String, dynamic>? parameters;
  
  CameraOperationData(this.operation, [this.parameters]);
}

// Static function for gallery picking (for compute isolation)
Future<void> _pickImageFromGalleryIsolate(PlantIdentificationViewModel viewModel) async {
  await viewModel.pickImageFromGallery();
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _showResults = false;
  bool _isCameraOperationInProgress = false;
  
  // Stream controller for camera operations
  late StreamController<CameraOperationData> _cameraOperationController;
  late StreamSubscription<CameraOperationData> _cameraOperationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraOperationStream();
    _initializeCameraAsync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraOperationSubscription.cancel();
    _cameraOperationController.close();
    _disposeCameraAsync();
    super.dispose();
  }

  void _initializeCameraOperationStream() {
    _cameraOperationController = StreamController<CameraOperationData>();
    _cameraOperationSubscription = _cameraOperationController.stream.listen(
      _handleCameraOperation,
      onError: (error) {
        debugPrint('Camera operation error: $error');
        if (mounted) {
          setState(() {
            _isCameraOperationInProgress = false;
          });
        }
      },
    );
  }

  // Handle camera operations in a separate async context
  Future<void> _handleCameraOperation(CameraOperationData operationData) async {
    if (!mounted) return;
    
    setState(() {
      _isCameraOperationInProgress = true;
    });

    try {
      switch (operationData.operation) {
        case CameraOperation.initialize:
          await _performCameraInitialization();
          break;
        case CameraOperation.takePicture:
          await _performTakePicture();
          break;
        case CameraOperation.toggleFlash:
          await _performToggleFlash();
          break;
        case CameraOperation.dispose:
          await _performCameraDisposal();
          break;
      }
    } catch (e) {
      debugPrint('Camera operation failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCameraOperationInProgress = false;
        });
      }
    }
  }

  void _initializeCameraAsync() {
    // Queue camera initialization operation
    _cameraOperationController.add(CameraOperationData(CameraOperation.initialize));
  }

  void _disposeCameraAsync() {
    // Queue camera disposal operation
    _cameraOperationController.add(CameraOperationData(CameraOperation.dispose));
  }

  // Individual camera operation implementations
  Future<void> _performCameraInitialization() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _performTakePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint('Camera not initialized');
      return;
    }

    try {
      // Add haptic feedback on main thread
      await HapticFeedback.lightImpact();
      
      // Take picture in background
      final image = await _cameraController!.takePicture();
      
      if (mounted) {
        final viewModel = context.read<PlantIdentificationViewModel>();
        await viewModel.setImageFromPath(image.path);
        setState(() {
          _showResults = true;
        });
        
        // Run plant identification in background
        _identifyPlantInBackground(viewModel);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _performToggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final newFlashState = !_isFlashOn;
        await _cameraController!.setFlashMode(
          newFlashState ? FlashMode.torch : FlashMode.off,
        );
        if (mounted) {
          setState(() {
            _isFlashOn = newFlashState;
          });
        }
      } catch (e) {
        debugPrint('Error toggling flash: $e');
      }
    }
  }

  Future<void> _performCameraDisposal() async {
    try {
      await _cameraController?.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }

  // Background plant identification
  void _identifyPlantInBackground(PlantIdentificationViewModel viewModel) {
    // Run in microtask to avoid blocking UI
    Future.microtask(() async {
      try {
        await viewModel.identifyPlant();
      } catch (e) {
        debugPrint('Error identifying plant: $e');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _cameraOperationController.add(CameraOperationData(CameraOperation.dispose));
        break;
      case AppLifecycleState.resumed:
        _cameraOperationController.add(CameraOperationData(CameraOperation.initialize));
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  // Updated picture taking method (now threaded)
  Future<void> _takePicture() async {
    if (_isCameraOperationInProgress) {
      debugPrint('Camera operation already in progress');
      return;
    }
    _cameraOperationController.add(CameraOperationData(CameraOperation.takePicture));
  }

  // Updated gallery picking method with background processing
  Future<void> _pickFromGallery() async {
    if (_isCameraOperationInProgress) {
      debugPrint('Camera operation already in progress');
      return;
    }

    setState(() {
      _isCameraOperationInProgress = true;
    });

    try {
      final viewModel = context.read<PlantIdentificationViewModel>();
      
      // Pick image in background using compute for CPU-intensive operations
      await compute(_pickImageFromGalleryIsolate, viewModel);
      
      if (viewModel.hasImage && mounted) {
        setState(() {
          _showResults = true;
        });
        
        // Run plant identification in background
        _identifyPlantInBackground(viewModel);
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCameraOperationInProgress = false;
        });
      }
    }
  }

  // Updated flash toggle method (now threaded)
  void _toggleFlash() {
    if (_isCameraOperationInProgress) return;
    _cameraOperationController.add(CameraOperationData(CameraOperation.toggleFlash));
  }

  void _backToCamera() {
    setState(() {
      _showResults = false;
    });
    final viewModel = context.read<PlantIdentificationViewModel>();
    viewModel.clearResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          'Plant Lens',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isCameraInitialized && !_showResults)
            IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: _isFlashOn ? Colors.yellow : Colors.white,
              ),
            ),
        ],
      ),
      body: Consumer<PlantIdentificationViewModel>(
        builder: (context, viewModel, child) {
          if (_showResults) {
            return _buildResultsView(viewModel);
          }
          return _buildCameraView();
        },
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              _isCameraOperationInProgress 
                ? 'Initializing camera...'
                : 'Camera not available',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Overlay with scan guide
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
            child: CustomPaint(
              painter: ScanOverlayPainter(),
            ),
          ),
        ),

        // Loading overlay when operation is in progress
        if (_isCameraOperationInProgress)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Instruction text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Point your camera at a plant to identify it',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      _buildActionButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onPressed: _isCameraOperationInProgress ? null : _pickFromGallery,
                      ),
                      
                      // Capture button
                      GestureDetector(
                        onTap: _isCameraOperationInProgress ? null : _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isCameraOperationInProgress 
                              ? Colors.grey 
                              : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _isCameraOperationInProgress 
                                  ? Colors.grey.shade600 
                                  : Colors.green.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Settings placeholder
                      _buildActionButton(
                        icon: Icons.tune,
                        label: 'Settings',
                        onPressed: _isCameraOperationInProgress ? null : () {
                          // TODO: Implement settings
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: onPressed != null ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: onPressed != null ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(PlantIdentificationViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _backToCamera,
                    icon: Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Plant Identification Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Results content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Image display
                    if (viewModel.hasImage)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          File(viewModel.selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    
                    SizedBox(height: 24),
                    
                    // Results
                    _buildResultsContent(viewModel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(PlantIdentificationViewModel viewModel) {
    if (viewModel.isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
            SizedBox(height: 16),
            Text(
              "Analyzing your plant...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "This may take a few seconds",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Failed to identify the plant',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _backToCamera,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _identifyPlantInBackground(viewModel),
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade600,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (viewModel.hasPlantData) {
      return PlantDataCard(plantData: viewModel.plantData!);
    }

    // Empty state - should not normally be reached
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.eco,
            size: 48,
            color: Colors.green.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Ready to identify plants!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Take a photo or select from gallery to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom painter for the scan overlay
class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scanAreaSize = size.width * 0.7;
    final cornerLength = 30.0;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw corner brackets
    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
