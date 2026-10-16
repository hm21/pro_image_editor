/// The file path to the pixelate shader used in the image editor.
///
/// This constant defines the location of the fragment shader file
/// that is used to apply a pixelation effect to images within the
/// image editor package.
const kImageEditorPixelateShaderPath =
    'packages/pro_image_editor/lib/shared/shaders/pixelate.frag';

/// The file path to the shader that pixelates many censor areas in one pass,
/// each in blocks of its own grid.
const kImageEditorPixelateAreasShaderPath =
    'packages/pro_image_editor/lib/shared/shaders/pixelate_areas.frag';
