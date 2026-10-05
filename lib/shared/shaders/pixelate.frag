#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;                // Layer size
uniform float u_pixel_block_size;   // The pixelation block size
uniform vec2 u_device_size;         // The device size
uniform float u_fit_to_width;       // If the image fits the device, it is 1, if not, it is 0.
uniform vec2 u_origin;              // Layer space: where the blocks start, in device pixels.
uniform float u_layer_space;        // 1 when the block size and origin are in device pixels of the layer space.
uniform sampler2D u_texture_input;

out vec4 frag_color;

void main() {   
    /// Flutter rerender the shader when we read the raw rgb data.
    /// To ensure the pixelation will not be reduced we need to calculate 
    /// that difference to the rendered image in the screen.
    float generationHelper = u_fit_to_width == 1
        ? u_size.x / u_device_size.x
        : u_size.y / u_device_size.y;

    if (u_layer_space > 0.5) {
        /// Blocks of the layer's own size, starting at its corner, each
        /// filled with the color at its center.
        float block = u_pixel_block_size * generationHelper;
        vec2 origin = u_origin * generationHelper;
        vec2 cell = floor((FlutterFragCoord().xy - origin) / block);
        frag_color = texture(u_texture_input, (origin + (cell + 0.5) * block) / u_size);
        return;
    }

    /// Normalize coordinates
    vec2 uv = FlutterFragCoord().xy / u_size; 

    /// Calculate the real pixel block size
	float pixelBlockSize = u_pixel_block_size * generationHelper;

    /// Calculate the pixelated UV by snapping to the grid
    vec2 pixelated_uv = floor(uv * u_size / pixelBlockSize) * pixelBlockSize / u_size;

    /// Sample the texture using the pixelated coordinates
    frag_color = texture(u_texture_input, pixelated_uv);
}
