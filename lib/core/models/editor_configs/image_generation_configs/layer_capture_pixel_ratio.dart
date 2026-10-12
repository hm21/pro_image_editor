import 'dart:ui';

import '/core/models/layers/layer.dart';

/// Returns the pixel ratio a layer is captured at.
///
/// [layer] is the layer being captured, [size] its laid-out size in logical
/// pixels before rotation, and [pixelRatio] the ratio the capture would use
/// without this callback. Return [pixelRatio] to keep it, or a lower value
/// for a layer whose image is not needed at full resolution. The result must
/// be greater than 0.
///
/// The memory a capture takes grows with the square of its pixel ratio and of
/// the layer's size, so a large layer captured at full resolution can take
/// hundreds of megabytes while it is encoded.
typedef LayerCapturePixelRatio =
    double Function(Layer layer, Size size, double pixelRatio);
