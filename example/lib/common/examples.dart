import 'package:example/pages/stickers_example.dart';
import 'package:flutter/material.dart';

import '../models/example_model.dart';
import '../pages/crop_to_main_editor.dart';
import '../pages/custom_widgets_example.dart';
import '../pages/default_example.dart';
import '../pages/design_examples/design_example.dart';
import '../pages/firebase_supabase_example.dart';
import '../pages/frame_example.dart';
import '../pages/generation_configs_example.dart';
import '../pages/google_font_example.dart';
import '../pages/image_format_convert_example.dart';
import '../pages/import_export_example.dart';
import '../pages/movable_background_image.dart';
import '../pages/pick_image_example.dart';
import '../pages/reorder_layer_example.dart';
import '../pages/round_cropper_example.dart';
import '../pages/selectable_layer_example.dart';
import '../pages/signature_drawing_example.dart';
import '../pages/standalone_example.dart';
import '../pages/zoom_example.dart';

/// A predefined list of examples for the image editor application.
///
/// Each [Example] in this list contains:
/// - [path]: A unique navigation route for the example.
/// - [name]: A user-friendly name for the example.
/// - [icon]: An [IconData] representing the example visually.
/// - [page]: A [Widget] representing the content of the example.
///
/// These examples showcase various features of the image editor, such as
/// cropping, layering, importing/exporting, and integration with services
/// like Firebase or Supabase.
List<Example> kImageEditorExamples = const [
  Example(
    path: '/default',
    name: 'Default-Editor',
    icon: Icons.dashboard_outlined,
    page: DefaultExample(),
  ),
  Example(
    path: '/designs',
    name: 'Designs',
    icon: Icons.palette_outlined,
    page: DesignExample(),
  ),
  Example(
    path: '/standalone',
    name: 'Standalone-Editors',
    icon: Icons.view_in_ar_outlined,
    page: StandaloneExample(),
  ),
  Example(
    path: '/init-crop-editor',
    name: 'Start with Crop-Editor',
    icon: Icons.crop,
    page: CropToMainEditorExample(),
  ),
  Example(
    path: '/signature-drawing',
    name: 'Signature/ Drawing',
    icon: Icons.draw_outlined,
    page: SignatureDrawingExample(),
  ),
  Example(
    path: '/stickers',
    name: 'Stickers',
    icon: Icons.image_outlined,
    page: StickersExample(),
  ),
  Example(
    path: '/firebase-supabase',
    name: 'Firebase-Supabase',
    icon: Icons.cloud_upload_outlined,
    page: FirebaseSupabaseExample(),
  ),
  Example(
    path: '/reorder',
    name: 'Reorder-Layers',
    icon: Icons.sort,
    page: ReorderLayerExample(),
  ),
  Example(
    path: '/round-cropper',
    name: 'Round-Cropper',
    icon: Icons.supervised_user_circle_outlined,
    page: RoundCropperExample(),
  ),
  Example(
    path: '/selectable-layers',
    name: 'Selectable-Layers',
    icon: Icons.select_all_rounded,
    page: SelectableLayerExample(),
  ),
  Example(
    path: '/generation-configs',
    name: 'Generation-Configurations',
    icon: Icons.memory_outlined,
    page: GenerationConfigsExample(),
  ),
  Example(
    path: '/camera-gallery-picker',
    name: 'Camera-Gallery-Picker',
    icon: Icons.attachment_rounded,
    page: PickImageExample(),
  ),
  Example(
    path: '/google-font',
    name: 'Google-Font',
    icon: Icons.emoji_emotions_outlined,
    page: GoogleFontExample(),
  ),
  Example(
    path: '/custom-widgets',
    name: 'Custom-Widgets',
    icon: Icons.dashboard_customize_outlined,
    page: CustomWidgetsExample(),
  ),
  Example(
    path: '/import-export',
    name: 'Import-Export',
    icon: Icons.import_export_rounded,
    page: ImportExportExample(),
  ),
  Example(
    path: '/movable',
    name: 'Movable-Background',
    icon: Icons.pan_tool_alt_outlined,
    page: MovableBackgroundImageExample(),
  ),
  Example(
    path: '/frame',
    name: 'Frame',
    icon: Icons.filter_frames_outlined,
    page: FrameExample(),
  ),
  Example(
    path: '/zoom',
    name: 'Zoom',
    icon: Icons.zoom_in_outlined,
    page: ZoomExample(),
  ),
  Example(
    path: '/output-format',
    name: 'Output-Format',
    icon: Icons.compare_outlined,
    page: ImageFormatConvertExample(),
  ),
];
