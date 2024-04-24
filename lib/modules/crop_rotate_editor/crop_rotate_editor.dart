import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp_crop_rotate_toolbar.dart';
import 'package:pro_image_editor/models/crop_rotate_editor/transform_factors.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../mixins/converted_configs.dart';
import '../../mixins/extended_loop.dart';
import '../../mixins/standalone_editor.dart';
import '../../models/editor_image.dart';
import '../../models/init_configs/crop_rotate_editor_init_configs.dart';
import '../../models/transform_helper.dart';
import '../../widgets/auto_image.dart';
import '../../widgets/layer_stack.dart';
import '../../widgets/platform_popup_menu.dart';
import '../../widgets/pro_image_editor_desktop_mode.dart';
import 'utils/crop_area_part.dart';
import 'utils/crop_aspect_ratios.dart';
import 'utils/crop_corner_painter.dart';
import 'utils/rotate_angle.dart';
import 'widgets/crop_aspect_ratio_options.dart';

/// The `CropRotateEditor` widget allows users to editing images with crop, flip and rotate tools.
///
/// You can create a `CropRotateEditor` using one of the factory methods provided:
/// - `CropRotateEditor.file`: Loads an image from a file.
/// - `CropRotateEditor.asset`: Loads an image from an asset.
/// - `CropRotateEditor.network`: Loads an image from a network URL.
/// - `CropRotateEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `CropRotateEditor.autoSource`: Automatically selects the source based on provided parameters.
class CropRotateEditor extends StatefulWidget
    with StandaloneEditor<CropRotateEditorInitConfigs> {
  @override
  final CropRotateEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  /// Constructs a `CropRotateEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations for the editor.
  const CropRotateEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

  /// Constructs a `CropRotateEditor` widget with image data loaded from memory.
  factory CropRotateEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded from a file.
  factory CropRotateEditor.file(
    File file, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(file: file),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded from an asset.
  factory CropRotateEditor.asset(
    String assetPath, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded from a network URL.
  factory CropRotateEditor.network(
    String networkUrl, {
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
  }) {
    return CropRotateEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `CropRotateEditor` widget with an image loaded automatically based on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory CropRotateEditor.autoSource({
    Key? key,
    required CropRotateEditorInitConfigs initConfigs,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
  }) {
    if (byteArray != null) {
      return CropRotateEditor.memory(
        byteArray,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null) {
      return CropRotateEditor.file(
        file,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null) {
      return CropRotateEditor.network(
        networkUrl,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null) {
      return CropRotateEditor.asset(
        assetPath,
        key: key,
        initConfigs: initConfigs,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must be provided.");
    }
  }

  @override
  State<CropRotateEditor> createState() => CropRotateEditorState();
}

/// A state class for ImageCropRotateEditor widget.
///
/// This class handles the state and UI for an image editor
/// that supports cropping, rotating, and aspect ratio adjustments.
class CropRotateEditorState extends State<CropRotateEditor>
    with
        TickerProviderStateMixin,
        ImageEditorConvertedConfigs,
        StandaloneEditorState<CropRotateEditor, CropRotateEditorInitConfigs>,
        ExtendedLoop {
  late AnimationController _rotateCtrl;
  late AnimationController _scaleCtrl;

  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  int _rotationCount = 0;
  late double _aspectRatio;
  bool _flipX = false;
  bool _flipY = false;
  bool _showWidgets = false;
  bool _blockInteraction = false;

  double _painterOpacity = 0;
  double _aspectRatioZoomHelper = 1;
  double _userZoom = 1;
  double _oldScaleFactor = 1;
  final double _screenPadding = 20;
  Offset _translate = const Offset(0, 0);
  double _startingPinchScale = 1;
  Offset _startingTranslate = Offset.zero;
  Offset _startingCenterOffset = Offset.zero;

  Rect _cropRect = Rect.zero;
  Rect _viewRect = Rect.zero;
  late BoxConstraints _contentConstraints;
  late BoxConstraints _renderedImgConstraints = BoxConstraints();
  late TapDownDetails _doubleTapDetails;

  /// Debounce for scaling actions in the editor.
  bool _interactionActive = false;

  double get _cropCornerLength => 36;
  double get _interactiveCornerArea => isDesktop
      ?
      // TODO: set cursor to 5 after fix bug that cursor is detected wrong
      15
      : _cropCornerLength;

  double get _zoomFactor => _aspectRatioZoomHelper * _userZoom;

  double get _imgWidth => initConfigs.imageSize.width;
  double get _imgHeight => initConfigs.imageSize.height;

  double get _ratio =>
      1 /
      (_aspectRatio == 0 ? initConfigs.imageSize.aspectRatio : _aspectRatio);

  bool get _imageSticksToScreenWidth =>
      _imgWidth >= _contentConstraints.maxWidth;
  bool get _rotated90deg => _rotationCount % 2 != 0;
  Size get _renderedImgSize => Size(
        _rotated90deg
            ? _renderedImgConstraints.maxHeight
            : _renderedImgConstraints.maxWidth,
        _rotated90deg
            ? _renderedImgConstraints.maxWidth
            : _renderedImgConstraints.maxHeight,
      );

  CropAreaPart _currentCropAreaPart = CropAreaPart.none;
  MouseCursor _cursor = SystemMouseCursors.basic;

  @override
  void initState() {
    super.initState();

    double initAngle = transformConfigs?.angle ?? 0.0;
    _rotateCtrl = AnimationController(
        duration: cropRotateEditorConfigs.animationDuration, vsync: this);
    _rotateCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        var tempZoom = _aspectRatioZoomHelper;
        _calcAspectRatioZoomHelper();
        if (tempZoom != _aspectRatioZoomHelper) {
          _userZoom *= tempZoom / _aspectRatioZoomHelper;
          _setOffsetLimits();
        }
        setState(() {});
      }
    });
    _rotateAnimation =
        Tween<double>(begin: initAngle, end: initAngle).animate(_rotateCtrl);

    double initScale = transformConfigs?.scaleRotation ?? 1;
    _scaleCtrl = AnimationController(
        duration: cropRotateEditorConfigs.animationDuration, vsync: this);
    _scaleAnimation =
        Tween<double>(begin: initScale, end: initScale).animate(_scaleCtrl);

    _aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;

    if (transformConfigs != null) {
      _rotationCount = (transformConfigs!.angle * 2 / pi).abs().toInt();
      _flipX = transformConfigs!.flipX;
      _flipY = transformConfigs!.flipY;
      _translate = transformConfigs!.offset;
      _aspectRatioZoomHelper = transformConfigs!.scaleAspectRatio;
      _userZoom = transformConfigs!.scaleUser;
      _aspectRatio = transformConfigs!.aspectRatio;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calcCropRect(calcCropRect: true);
      _showWidgets = true;

      loopWithTransitionTiming(
        (double curveT) {
          _painterOpacity = 1 * curveT;
          setState(() {});
        },
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void reset() {
    _flipX = false;
    _flipY = false;
    _translate = Offset.zero;

    int rotationCount = _rotationCount % 4;
    _rotateAnimation = Tween<double>(
            begin: rotationCount == 3 ? pi / 2 : -rotationCount * pi / 2,
            end: 0)
        .animate(_rotateCtrl);
    _rotateCtrl
      ..reset()
      ..forward();
    _rotationCount = 0;

    _scaleAnimation =
        Tween<double>(begin: _oldScaleFactor * _zoomFactor, end: 1)
            .animate(_scaleCtrl);
    _scaleCtrl
      ..reset()
      ..forward();
    _oldScaleFactor = 1;

    _userZoom = 1;
    _aspectRatioZoomHelper = 1;
    _aspectRatio =
        cropRotateEditorConfigs.initAspectRatio ?? CropAspectRatios.custom;
    _calcCropRect(calcCropRect: true);
    setState(() {});
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Handles the crop image operation.
  Future<void> done() async {
    Navigator.pop(
      context,
      TransformConfigs(
        cropRect: _cropRect,
        angle: _rotateAnimation.value,
        scaleAspectRatio: _aspectRatioZoomHelper,
        scaleUser: _userZoom,
        scaleRotation: _scaleAnimation.value,
        aspectRatio: _ratio,
        flipX: _flipX,
        flipY: _flipY,
        offset: _translate,
        maxSide: _imageSticksToScreenWidth
            ? ImageMaxSide.horizontal
            : ImageMaxSide.vertical,
      ),
    );
  }

  /// Flip the image horizontally
  void flip() {
    setState(() {
      if (_rotationCount % 2 != 0) {
        _flipY = !_flipY;
      } else {
        _flipX = !_flipX;
      }
    });
  }

  /// Rotates the image clockwise.
  void rotate() {
    var piHelper =
        cropRotateEditorConfigs.rotateDirection == RotateDirection.left
            ? -pi
            : pi;

    _rotationCount++;
    _rotateAnimation = Tween<double>(
            begin: _rotateAnimation.value, end: _rotationCount * piHelper / 2)
        .animate(
      CurvedAnimation(
        parent: _rotateCtrl,
        curve: cropRotateEditorConfigs.rotateAnimationCurve,
      ),
    );
    _rotateCtrl
      ..reset()
      ..forward();

    Size contentSize = Size(
      _contentConstraints.maxWidth - _screenPadding * 2,
      _contentConstraints.maxHeight - _screenPadding * 2,
    );

    double scaleX = contentSize.width / _renderedImgSize.width;
    double scaleY = contentSize.height / _renderedImgSize.height;

    double scale = min(scaleX, scaleY);

    if (_rotated90deg) {
      scale *= _aspectRatioZoomHelper;
    }

    _scaleAnimation = Tween<double>(begin: _oldScaleFactor, end: scale).animate(
      CurvedAnimation(
        parent: _scaleCtrl,
        curve: cropRotateEditorConfigs.scaleAnimationCurve,
      ),
    );
    _scaleCtrl
      ..reset()
      ..forward();

    _oldScaleFactor = scale;
    setState(() {});
  }

  /// Opens a dialog to select from predefined aspect ratios.
  void openAspectRatioOptions() {
    showModalBottomSheet<double>(
        context: context,
        backgroundColor:
            imageEditorTheme.cropRotateEditor.aspectRatioSheetBackgroundColor,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return CropAspectRatioOptions(
            aspectRatio: _aspectRatio,
            configs: configs,
            originalAspectRatio: initConfigs.imageSize.aspectRatio,
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          reset();
          _aspectRatio = value;

          if (_ratio >= 0) {
            Size bodySize = Size(
              _contentConstraints.maxWidth - _screenPadding * 2,
              _contentConstraints.maxHeight - _screenPadding * 2,
            );
            _cropRect = Rect.fromCenter(
              center: _cropRect.center,
              width: bodySize.width,
              height: bodySize.width * _ratio,
            );
            if (_cropRect.height > bodySize.height) {
              _cropRect = Rect.fromCenter(
                center: _cropRect.center,
                width: bodySize.height / _ratio,
                height: bodySize.height,
              );
            }

            _calcAspectRatioZoomHelper();
          }
        });
      }
    });
  }

  void _calcAspectRatioZoomHelper() {
    double w = _rotated90deg ? _cropRect.height : _cropRect.width;
    double h = _rotated90deg ? _cropRect.width : _cropRect.height;
    double imgW = _rotated90deg
        ? _renderedImgConstraints.maxHeight
        : _renderedImgConstraints.maxWidth;
    double imgH = _rotated90deg
        ? _renderedImgConstraints.maxWidth
        : _renderedImgConstraints.maxHeight;

    if (w > imgW) {
      _aspectRatioZoomHelper = w / imgW;
    } else if (h > imgH) {
      _aspectRatioZoomHelper = h / imgH;
    } else {
      _aspectRatioZoomHelper = 1;
    }
  }

  void _calcCropRect({
    bool calcCropRect = false,
  }) {
    if (!_showWidgets) return;
    double imgSizeRatio = _imgHeight / _imgWidth;

    double newImgW = _renderedImgConstraints.maxWidth;
    double newImgH = _renderedImgConstraints.maxHeight;

    double cropWidth =
        _imageSticksToScreenWidth ? newImgW : newImgH / imgSizeRatio;
    double cropHeight =
        _imageSticksToScreenWidth ? newImgW * imgSizeRatio : newImgH;

    if (calcCropRect || _cropRect.isEmpty) {
      _cropRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
    }
    _viewRect = Rect.fromLTWH(0, 0, cropWidth, cropHeight);
  }

  CropAreaPart _determineCropAreaPart(Offset localPosition) {
    Offset offset = _getRealHitPoint(zoom: _userZoom, position: localPosition) +
        _translate * _userZoom;
    double dx = offset.dx;
    double dy = offset.dy;

    double halfCropWidth = _cropRect.width / 2;
    double halfCropHeight = _cropRect.height / 2;

    double left = dx + halfCropWidth;
    double right = dx - halfCropWidth;
    double top = dy + halfCropHeight;
    double bottom = dy - halfCropHeight;

    bool nearLeftEdge = left.abs() <= _interactiveCornerArea;
    bool nearRightEdge = right.abs() <= _interactiveCornerArea;
    bool nearTopEdge = top.abs() <= _interactiveCornerArea;
    bool nearBottomEdge = bottom.abs() <= _interactiveCornerArea;

    if (_cropRect.contains(localPosition)) {
      if (nearLeftEdge && nearTopEdge) {
        return CropAreaPart.topLeft;
      } else if (nearRightEdge && nearTopEdge) {
        return CropAreaPart.topRight;
      } else if (nearLeftEdge && nearBottomEdge) {
        return CropAreaPart.bottomLeft;
      } else if (nearRightEdge && nearBottomEdge) {
        return CropAreaPart.bottomRight;
      } else if (nearLeftEdge) {
        return CropAreaPart.left;
      } else if (nearRightEdge) {
        return CropAreaPart.right;
      } else if (nearTopEdge) {
        return CropAreaPart.top;
      } else if (nearBottomEdge) {
        return CropAreaPart.bottom;
      } else {
        return CropAreaPart.inside;
      }
    } else {
      return CropAreaPart.none;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_blockInteraction) return;
    _blockInteraction = true;

    _startingPinchScale = _userZoom;
    _startingTranslate = _translate;

    // Calculate the center offset point from the old zoomed view
    _startingCenterOffset = _startingTranslate +
        _getRealHitPoint(position: details.localFocalPoint, zoom: _userZoom) /
            _userZoom;

    _currentCropAreaPart = _determineCropAreaPart(details.localFocalPoint);
    _interactionActive = true;
    _blockInteraction = false;
    setState(() {});
  }

  void _onScaleEnd(ScaleEndDetails details) async {
    if (_blockInteraction) return;
    _blockInteraction = true;
    _interactionActive = false;
    setState(() {});

    if (_cropRect != _viewRect) {
      Rect startCropRect = _cropRect;
      Rect targetCropRect = _viewRect;

      /*    if (_aspectRatio == -1) {
        _viewRect = Rect.fromCenter(
          center: _cropRect.center,
          width: _viewRect.width * _cropRect.size.aspectRatio,
          height: _viewRect.height / _cropRect.size.aspectRatio,
        );
      } */

      double startZoom = _userZoom;
      double targetZoom =
          _userZoom * _viewRect.size.longestSide / _cropRect.size.longestSide;

      Offset startOffset = _translate;
      Offset targetOffset = startOffset -
          Offset(
                (startCropRect.left -
                    (targetCropRect.right - startCropRect.right)),
                (startCropRect.top -
                    (targetCropRect.bottom - startCropRect.bottom)),
              ) /
              startZoom /
              2;

      await loopWithTransitionTiming(
        (double curveT) {
          _userZoom = startZoom + (targetZoom - startZoom) * curveT;

          _translate = startOffset + (targetOffset - startOffset) * curveT;

          _cropRect = Rect.fromLTRB(
            startCropRect.left +
                (targetCropRect.left - startCropRect.left) * curveT,
            startCropRect.top +
                (targetCropRect.top - startCropRect.top) * curveT,
            startCropRect.right +
                (targetCropRect.right - startCropRect.right) * curveT,
            startCropRect.bottom +
                (targetCropRect.bottom - startCropRect.bottom) * curveT,
          );
          _setOffsetLimits();
          setState(() {});
        },
        duration: cropRotateEditorConfigs.animationDuration,
        transitionFunction: Curves.decelerate.transform,
      );

      _cropRect = targetCropRect;
      _translate = targetOffset;
      _userZoom = targetZoom;

      _calcCropRect();
      _setOffsetLimits();
      setState(() {});
    }
    _blockInteraction = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_blockInteraction) return;
    _blockInteraction = true;
    if (details.pointerCount == 2) {
      double newZoom = max(
        1,
        min(
          cropRotateEditorConfigs.maxScale,
          _startingPinchScale * details.scale,
        ),
      );

      // Calculate the center offset point from the new zoomed view
      Offset centerZoomOffset =
          _startingCenterOffset * _startingPinchScale / newZoom;

      // Update translation and zoom values
      _translate =
          _startingTranslate - _startingCenterOffset + centerZoomOffset;
      _userZoom = newZoom;

      // Set offset limits and trigger widget rebuild
      _setOffsetLimits();
      setState(() {});
    } else {
      /*    Offset offsetX = _getRealHitPoint(zoom: _startingPinchScale, position: details.localFocalPoint) + _translate * _startingPinchScale;
      print(offsetX.dx.abs());
      print(_viewRect.width);
      if (offsetX.dx.abs() > _viewRect.width / 2) {
        _userZoom -= 0.1;
        _setOffsetLimits();
        setState(() {});
      } */

      if (_currentCropAreaPart != CropAreaPart.none &&
          _currentCropAreaPart != CropAreaPart.inside) {
        Offset offset = _getRealHitPoint(
                zoom: _userZoom, position: details.localFocalPoint) +
            _translate * _userZoom;

        double imgW = _renderedImgConstraints.maxWidth;
        double imgH = _renderedImgConstraints.maxHeight;

        double outsidePadding = _screenPadding * 2;
        double cornerGap = _cropCornerLength * 2.25;
        double minCornerDistance = outsidePadding + cornerGap;

        double dx = offset.dx + _viewRect.width / 2;
        double dy = offset.dy + _viewRect.height / 2;

        double maxRight = _cropRect.right + outsidePadding - minCornerDistance;
        double maxBottom =
            _cropRect.bottom + outsidePadding - minCornerDistance;

        switch (_currentCropAreaPart) {
          case CropAreaPart.topLeft:
            double left = max(0, dx);
            _cropRect = Rect.fromLTRB(
              min(maxRight, left),
              min(maxBottom, max(0, dy)),
              _cropRect.right,
              _cropRect.bottom,
            );

            break;
          case CropAreaPart.topRight:
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              max(0, min(dy, maxBottom)),
              max(cornerGap + _cropRect.left, min(imgW, dx)),
              _cropRect.bottom,
            );

            break;
          case CropAreaPart.bottomLeft:
            _cropRect = Rect.fromLTRB(
              max(0, min(maxRight, dx)),
              _cropRect.top,
              _cropRect.right,
              max(cornerGap + _cropRect.top, min(imgH, dy)),
            );
            break;
          case CropAreaPart.bottomRight:
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top,
              max(cornerGap + _cropRect.left, min(imgW, dx)),
              max(cornerGap + _cropRect.top, min(imgH, dy)),
            );
            break;
          case CropAreaPart.left:
            _cropRect = Rect.fromLTRB(
              min(maxRight, max(0, dx)),
              _cropRect.top,
              _cropRect.right,
              _cropRect.bottom,
            );
            break;
          case CropAreaPart.right:
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top,
              max(cornerGap + _cropRect.left, min(imgW, dx)),
              _cropRect.bottom,
            );
            break;
          case CropAreaPart.top:
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              min(maxBottom, max(0, dy)),
              _cropRect.right,
              _cropRect.bottom,
            );
            break;
          case CropAreaPart.bottom:
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top,
              _cropRect.right,
              max(cornerGap + _cropRect.top, min(imgH, dy)),
            );
            break;
          default:
            break;
        }

        if (_ratio >= 0 && _cropRect.size.aspectRatio != _ratio) {
          if (_currentCropAreaPart == CropAreaPart.left ||
              _currentCropAreaPart == CropAreaPart.right) {
            _cropRect = Rect.fromCenter(
              center: _cropRect.center,
              width: _cropRect.width,
              height: _cropRect.width * _ratio,
            );
          } else if (_currentCropAreaPart == CropAreaPart.top ||
              _currentCropAreaPart == CropAreaPart.bottom) {
            _cropRect = Rect.fromCenter(
              center: _cropRect.center,
              width: _cropRect.height / _ratio,
              height: _cropRect.height,
            );
          } else if (_currentCropAreaPart == CropAreaPart.topLeft ||
              _currentCropAreaPart == CropAreaPart.topRight) {
            double gapBottom = _viewRect.height - _cropRect.bottom;
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _viewRect.height - gapBottom - _cropRect.width * _ratio,
              _cropRect.right,
              _cropRect.bottom,
            );
          } else if (_currentCropAreaPart == CropAreaPart.bottomLeft ||
              _currentCropAreaPart == CropAreaPart.bottomRight) {
            _cropRect = Rect.fromLTRB(
              _cropRect.left,
              _cropRect.top,
              _cropRect.right,
              _cropRect.width * _ratio + _cropRect.top,
            );
          }
        }

        setState(() {});
      } else {
        _translate +=
            Offset(details.focalPointDelta.dx, details.focalPointDelta.dy) *
                (cropRotateEditorConfigs.reverseDragDirection ? -1 : 1);
        _setOffsetLimits();

        setState(() {});
      }
    }
    _blockInteraction = false;
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() async {
    double clampValue(double value, double min, double max) {
      if (value < min) {
        return min;
      } else if (value > max) {
        return max;
      } else {
        return value;
      }
    }

    if (!cropRotateEditorConfigs.enableDoubleTap || _blockInteraction) return;
    _blockInteraction = true;

    bool zoomInside = _userZoom <= 1;
    double startZoom = _userZoom;
    double targetZoom =
        zoomInside ? cropRotateEditorConfigs.doubleTapScaleFactor : 1;
    Offset startOffset = _translate;

    Offset targetOffset = zoomInside
        ? (_translate -
            Offset(
              _doubleTapDetails.localPosition.dx -
                  _renderedImgConstraints.maxWidth / 2,
              _doubleTapDetails.localPosition.dy -
                  _renderedImgConstraints.maxHeight / 2,
            ))
        : Offset.zero;

    double maxOffsetX =
        (_renderedImgConstraints.maxWidth * targetZoom - _viewRect.width) /
            2 /
            targetZoom;
    double maxOffsetY =
        (_renderedImgConstraints.maxHeight * targetZoom - _viewRect.height) /
            2 /
            targetZoom;

    /// direct double clamp trigger an error on android samsung s10 so better use own solution to clamp
    targetOffset = Offset(
      clampValue(targetOffset.dx, -maxOffsetX, maxOffsetX),
      clampValue(targetOffset.dy, -maxOffsetY, maxOffsetY),
    );

    await loopWithTransitionTiming(
      (double curveT) {
        _userZoom = startZoom + (targetZoom - startZoom) * curveT;
        _translate = startOffset +
            (targetOffset - startOffset) * targetZoom / _userZoom * curveT;
        setState(() {});
      },
      duration: cropRotateEditorConfigs.animationDuration,
      transitionFunction: Curves.decelerate.transform,
    );

    _userZoom = targetZoom;
    _translate = targetOffset;
    _setOffsetLimits();
    setState(() {});
    _blockInteraction = false;
  }

  void _setOffsetLimits() {
    if (_zoomFactor == 1) {
      _translate = const Offset(0, 0);
    } else {
      double cropWidth = (_viewRect.right - _viewRect.left);
      double cropHeight = (_viewRect.bottom - _viewRect.top);

      double minX =
          (_renderedImgConstraints.maxWidth * _zoomFactor - cropWidth) /
              2 /
              _zoomFactor;
      double minY =
          (_renderedImgConstraints.maxHeight * _zoomFactor - cropHeight) /
              2 /
              _zoomFactor;

      if (_rotated90deg) {}

      var offset = _translate;

      if (offset.dx > minX) {
        _translate = Offset(minX, _translate.dy);
      }
      if (offset.dx < -minX) {
        _translate = Offset(-minX, _translate.dy);
      }
      if (offset.dy > minY) {
        _translate = Offset(_translate.dx, minY);
      }
      if (offset.dy < -minY) {
        _translate = Offset(_translate.dx, -minY);
      }
    }
  }

  void _mouseScroll(PointerSignalEvent event) {
    // Check if interaction is blocked
    if (_blockInteraction) return;

    if (event is PointerScrollEvent) {
      // Define zoom factor and extract vertical scroll delta
      double factor = cropRotateEditorConfigs.mouseScaleFactor;

      double deltaY = event.scrollDelta.dy *
          (cropRotateEditorConfigs.reverseMouseScroll ? -1 : 1);

      double startZoom = _userZoom;
      double newZoom = _userZoom;
      // Adjust zoom based on scroll direction
      if (deltaY > 0) {
        newZoom -= factor;
        newZoom = max(1, newZoom);
      } else if (deltaY < 0) {
        newZoom += factor;
        newZoom = min(cropRotateEditorConfigs.maxScale, newZoom);
      }

      // Calculate the center offset point from the old zoomed view
      Offset centerOffset = _translate +
          _getRealHitPoint(zoom: startZoom, position: event.localPosition) /
              startZoom;
      // Calculate the center offset point from the new zoomed view
      Offset centerZoomOffset = centerOffset * startZoom / newZoom;

      // Update translation and zoom values
      _translate -= centerOffset - centerZoomOffset;
      _userZoom = newZoom;

      // Set offset limits and trigger widget rebuild
      _setOffsetLimits();
      _setMouseCursor();
      setState(() {});
    }
  }

  void _setMouseCursor() {
    SystemMouseCursor getCornerCursor(int cursorNo) {
      int no = cursorNo;

      if (_flipX && !_flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 1 : -1;
      } else if (!_flipX && _flipY) {
        no -= cursorNo == 0 || cursorNo == 2 ? 1 : -1;
      } else if (_flipX && _flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 2 : -2;
      }

      RotateAngleSide angle = getRotateAngleSide(_rotateAnimation.value);
      if (angle == RotateAngleSide.left) {
        no--;
      } else if (angle == RotateAngleSide.bottom) {
        no -= 2;
      } else if (angle == RotateAngleSide.right) {
        no -= 3;
      }

      switch (no % 4) {
        case 0:
          return SystemMouseCursors.resizeUpLeft;
        case 1:
          return SystemMouseCursors.resizeUpRight;
        case 2:
          return SystemMouseCursors.resizeDownRight;
        case 3:
          return SystemMouseCursors.resizeDownLeft;
        default:
          if (kDebugMode) {
            throw ErrorDescription('Invalid cursor number!');
          } else {
            debugPrint('Invalid cursor number!');
            return SystemMouseCursors.basic;
          }
      }
    }

    SystemMouseCursor getSideCursor(int cursorNo) {
      int no = cursorNo;

      if (_flipX && !_flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 2 : 0;
      } else if (!_flipX && _flipY) {
        no -= cursorNo == 0 || cursorNo == 2 ? 0 : 2;
      } else if (_flipX && _flipY) {
        no += cursorNo == 0 || cursorNo == 2 ? 2 : -2;
      }

      RotateAngleSide angle = getRotateAngleSide(_rotateAnimation.value);
      if (angle == RotateAngleSide.left) {
        no--;
      } else if (angle == RotateAngleSide.bottom) {
        no -= 2;
      } else if (angle == RotateAngleSide.right) {
        no -= 3;
      }

      switch (no % 4) {
        case 0:
          return SystemMouseCursors.resizeLeft;
        case 1:
          return SystemMouseCursors.resizeUp;
        case 2:
          return SystemMouseCursors.resizeRight;
        case 3:
          return SystemMouseCursors.resizeDown;
        default:
          if (kDebugMode) {
            throw ErrorDescription('Invalid cursor number!');
          } else {
            debugPrint('Invalid cursor number!');
            return SystemMouseCursors.basic;
          }
      }
    }

    int cursorNumber = -1;

    switch (_currentCropAreaPart) {
      case CropAreaPart.topLeft:
        cursorNumber = 0;
        break;
      case CropAreaPart.topRight:
        cursorNumber = 1;
        break;
      case CropAreaPart.bottomRight:
        cursorNumber = 2;
        break;
      case CropAreaPart.bottomLeft:
        cursorNumber = 3;
        break;
      case CropAreaPart.left:
        cursorNumber = 4;
        break;
      case CropAreaPart.top:
        cursorNumber = 5;
        break;
      case CropAreaPart.right:
        cursorNumber = 6;
        break;
      case CropAreaPart.bottom:
        cursorNumber = 7;
        break;
      case CropAreaPart.inside:
        if (_userZoom > 1 ||
            _cropRect.size.aspectRatio.toStringAsFixed(3) !=
                _renderedImgSize.aspectRatio.toStringAsFixed(3)) {
          _cursor = SystemMouseCursors.move;
        } else {
          _cursor = SystemMouseCursors.basic;
        }
        return;
      default:
        _cursor = SystemMouseCursors.basic;
        return;
    }

    _cursor = cursorNumber <= 3
        ? getCornerCursor(cursorNumber)
        : getSideCursor(cursorNumber - 4);
  }

  Offset _getRealHitPoint({
    required double zoom,
    required Offset position,
  }) {
    double imgW = _renderedImgConstraints.maxWidth;
    double imgH = _renderedImgConstraints.maxHeight;

    // Calculate the transformed local position of the pointer
    Offset transformedLocalPosition = position * zoom;
    // Calculate the size of the transformed image
    Size transformedImgSize = Size(
      imgW * zoom,
      imgH * zoom,
    );

    // Calculate the center offset point from the old zoomed view
    return Offset(
      transformedLocalPosition.dx - transformedImgSize.width / 2,
      transformedLocalPosition.dy - transformedImgSize.height / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: imageEditorTheme.uiOverlayStyle,
        child: Theme(
          data: theme.copyWith(
              tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: imageEditorTheme.cropRotateEditor.background,
            appBar: _buildAppBar(constraints),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
        ),
      );
    });
  }

  /// Builds the app bar for the editor, including buttons for actions such as back, rotate, aspect ratio, and done.
  PreferredSizeWidget? _buildAppBar(BoxConstraints constraints) {
    return customWidgets.appBarCropRotateEditor ??
        (imageEditorTheme.editorMode == ThemeEditorMode.simple
            ? AppBar(
                automaticallyImplyLeading: false,
                backgroundColor:
                    imageEditorTheme.cropRotateEditor.appBarBackgroundColor,
                foregroundColor:
                    imageEditorTheme.cropRotateEditor.appBarForegroundColor,
                actions: [
                  IconButton(
                    tooltip: i18n.cropRotateEditor.back,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: Icon(icons.backButton),
                    onPressed: close,
                  ),
                  const Spacer(),
                  if (constraints.maxWidth >= 300) ...[
                    if (cropRotateEditorConfigs.canRotate)
                      IconButton(
                        icon: Icon(icons.cropRotateEditor.rotate),
                        tooltip: i18n.cropRotateEditor.rotate,
                        onPressed: rotate,
                      ),
                    if (cropRotateEditorConfigs.canFlip)
                      IconButton(
                        icon: Icon(icons.cropRotateEditor.flip),
                        tooltip: i18n.cropRotateEditor.flip,
                        onPressed: flip,
                      ),
                    if (cropRotateEditorConfigs.canChangeAspectRatio)
                      IconButton(
                        key:
                            const ValueKey('pro-image-editor-aspect-ratio-btn'),
                        icon: Icon(icons.cropRotateEditor.aspectRatio),
                        tooltip: i18n.cropRotateEditor.ratio,
                        onPressed: openAspectRatioOptions,
                      ),
                    if (cropRotateEditorConfigs.canReset)
                      IconButton(
                        icon: Icon(icons.cropRotateEditor.reset),
                        tooltip: i18n.cropRotateEditor.reset,
                        onPressed: reset,
                      ),
                    const Spacer(),
                    _buildDoneBtn(),
                  ] else ...[
                    const Spacer(),
                    _buildDoneBtn(),
                    PlatformPopupBtn(
                      designMode: designMode,
                      title: i18n.cropRotateEditor.smallScreenMoreTooltip,
                      options: [
                        if (cropRotateEditorConfigs.canRotate)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.rotate,
                            icon: Icon(icons.cropRotateEditor.rotate),
                            onTap: () {
                              rotate();

                              if (designMode ==
                                  ImageEditorDesignModeE.cupertino) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        if (cropRotateEditorConfigs.canFlip)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.flip,
                            icon: Icon(icons.cropRotateEditor.flip),
                            onTap: flip,
                          ),
                        if (cropRotateEditorConfigs.canChangeAspectRatio)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.ratio,
                            icon: Icon(icons.cropRotateEditor.aspectRatio),
                            onTap: openAspectRatioOptions,
                          ),
                        if (cropRotateEditorConfigs.canReset)
                          PopupMenuOption(
                            label: i18n.cropRotateEditor.reset,
                            icon: Icon(icons.cropRotateEditor.reset),
                            onTap: reset,
                          ),
                      ],
                    ),
                  ],
                ],
              )
            : null);
  }

  Widget? _buildBottomNavigationBar() {
    if (imageEditorTheme.editorMode == ThemeEditorMode.whatsapp) {
      return WhatsAppCropRotateToolbar(
        configs: configs,
        onCancel: close,
        onRotate: rotate,
        onDone: done,
        onReset: reset,
        openAspectRatios: openAspectRatioOptions,
      );
    }
    return null;
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _contentConstraints = constraints;
        _calcCropRect();

        return _buildMouseCursor(
          child: _buildRotationTransform(
            child: _buildFlipTransform(
              child: _buildRotationScaleTransform(
                child: _buildPaintContainer(
                  child: _buildCropPainter(
                    child: _buildUserScaleTransform(
                      child: _buildTranslate(
                        child: _buildMouseListener(
                          child: _buildGestureDetector(
                            child: _buildImage(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMouseCursor({required Widget child}) {
    return MouseRegion(
      cursor: _cursor,
      child: child,
    );
  }

  Listener _buildMouseListener({required Widget child}) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: isDesktop ? _mouseScroll : null,
      onPointerHover: isDesktop
          ? (event) {
              var area = _determineCropAreaPart(event.localPosition);
              if (area != _currentCropAreaPart) {
                _currentCropAreaPart = area;
                _setMouseCursor();
                setState(() {});
              }
            }
          : null,
      child: child,
    );
  }

  Widget _buildGestureDetector({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: _onScaleStart,
      onScaleEnd: _onScaleEnd,
      onScaleUpdate: _onScaleUpdate,
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: child,
    );
  }

  AnimatedBuilder _buildRotationTransform({required Widget child}) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) => Transform.rotate(
        angle: _rotateAnimation.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );
  }

  Transform _buildFlipTransform({required Widget child}) {
    return Transform.flip(
      flipX: _flipX,
      flipY: _flipY,
      child: child,
    );
  }

  Widget _buildUserScaleTransform({required Widget child}) {
    return Transform.scale(
      scale: _zoomFactor,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildTranslate({required Widget child}) {
    return Transform.translate(
      offset: _translate,
      child: child,
    );
  }

  Widget _buildRotationScaleTransform({required Widget child}) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );
  }

  Widget _buildCropPainter({required Widget child}) {
    return CustomPaint(
      isComplex: _showWidgets,
      willChange: _showWidgets,
      foregroundPainter: _showWidgets
          ? CropCornerPainter(
              offset: _translate,
              cropRect: _cropRect,
              viewRect: _viewRect,
              scaleFactor: _zoomFactor,
              rotationScaleFactor: _oldScaleFactor,
              interactionActive: _interactionActive,
              screenSize: Size(
                _contentConstraints.maxWidth,
                _contentConstraints.maxHeight,
              ),
              opacity: _painterOpacity,
              imageEditorTheme: imageEditorTheme,
              cornerLength: _cropCornerLength,
            )
          : null,
      child: child,
    );
  }

  Widget _buildPaintContainer({required Widget child}) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(_screenPadding),
        child: child,
      ),
    );
  }

  Widget _buildImage() {
    double maxWidth = _imgWidth /
        _imgHeight *
        (_contentConstraints.maxHeight - _screenPadding * 2);
    double maxHeight = (_contentConstraints.maxWidth - _screenPadding * 2) *
        _imgHeight /
        _imgWidth;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _renderedImgConstraints = constraints;
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              AutoImage(
                editorImage,
                fit: BoxFit.contain,
                designMode: designMode,
                width: _imgWidth,
                height: _imgHeight,
              ),

              /// TODO: Add layers with hero animation.
              /// Note: When the image is rotated or flipped it affect the hero animation.

              if (cropRotateEditorConfigs.transformLayers && layers != null)
                ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  child: LayerStack(
                    transformHelper: TransformHelper(
                      alignTopLeft: false,
                      mainBodySize: bodySizeWithLayers,
                      mainImageSize: imageSizeWithLayers,
                      editorBodySize: Size(
                        _renderedImgConstraints.maxWidth,
                        _renderedImgConstraints.maxHeight,
                      ),
                    ),
                    configs: configs,
                    layers: layers!,
                    clipBehavior: Clip.none,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      tooltip: i18n.cropRotateEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(icons.applyChanges),
      iconSize: 28,
      onPressed: done,
    );
  }
}
