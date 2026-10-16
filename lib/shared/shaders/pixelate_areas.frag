#include <flutter/runtime_effect.glsl>

/// Pixelates many censor areas in one pass, each in blocks of its own grid.
///
/// Every area of a pass shares this shader with the same uniforms, so the
/// renderer filters the backdrop once for all of them instead of once per
/// area. Each area then shows the pass only inside its own clip, and a pixel
/// takes the grid of the topmost area that covers it.

#define MAX_AREAS 32

uniform vec2 u_size;        // The size of the input texture.
uniform vec2 u_device_size; // The size of the screen in device pixels.
uniform vec4 u_params;      // x: 1 when the image fits the screen's width,
                            // y: the number of areas.

/// Three vectors per area, from the bottom area to the top one:
/// [0].xyz, [1].xyz: the rows of the map from device pixels to the area's
///                   unit square.
/// [2].xy: the corner where the blocks start, in device pixels.
/// [2].z:  the edge length of a block, in device pixels.
/// [2].w:  1 when the area is an oval.
uniform vec4 u_areas[MAX_AREAS * 3];

uniform sampler2D u_texture_input;

out vec4 frag_color;

void main() {
    vec2 coord = FlutterFragCoord().xy;

    /// Device pixels in the pixels of the input, which is larger than the
    /// screen when the final image renders at another resolution.
    float scale = u_params.x > 0.5
        ? u_size.x / u_device_size.x
        : u_size.y / u_device_size.y;
    vec2 device = coord / scale;
    int count = int(u_params.y);

    frag_color = texture(u_texture_input, coord / u_size);

    for (int i = MAX_AREAS - 1; i >= 0; i--) {
        if (i >= count) {
            continue;
        }
        vec4 row0 = u_areas[i * 3];
        vec4 row1 = u_areas[i * 3 + 1];
        vec4 grid = u_areas[i * 3 + 2];
        vec2 uv = vec2(
            dot(row0.xy, device) + row0.z,
            dot(row1.xy, device) + row1.z
        );
        /// The area's clip is antialiased, so it also partly covers pixels
        /// whose centers lie up to a pixel outside it; those take its grid
        /// as well. A device pixel spans this much of the unit square.
        vec2 pixel = vec2(length(row0.xy), length(row1.xy));
        bool inside = grid.w > 0.5
            ? distance(uv, vec2(0.5)) <= 0.5 + max(pixel.x, pixel.y)
            : all(greaterThanEqual(uv, -pixel)) &&
                all(lessThanEqual(uv, vec2(1.0) + pixel));
        if (inside) {
            float block = grid.z * scale;
            vec2 origin = grid.xy * scale;
            vec2 cell = floor((coord - origin) / block);
            frag_color = texture(
                u_texture_input,
                (origin + (cell + 0.5) * block) / u_size
            );
            break;
        }
    }
}
