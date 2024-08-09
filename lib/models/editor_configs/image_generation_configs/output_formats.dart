/// Enumeration of image output formats.
enum OutputFormat {
  /// JPG (JPEG)
  ///
  /// - `Compression`: Lossy
  /// - `Quality`: Lower quality due to lossy compression, but high enough for
  ///    most photographic images.
  /// - `File Size`: Generally small due to compression.
  /// - `Use Case`: Web images, digital photos, where small file size is
  ///    important and some quality loss is acceptable.
  jpg,

  /// PNG (Portable Network Graphics)
  ///
  /// - `Compression`: Lossless
  /// - `Quality`: High quality with no loss of data, supports transparency
  ///    (alpha channel).
  /// - `File Size`: Larger than JPG due to lossless compression.
  /// - `Use Case`: Images requiring transparency, web graphics, icons, and
  ///    images where quality is important.
  png,

  /// TIFF (Tagged Image File Format)
  ///
  /// - `Compression`: Both lossless and lossy (usually lossless).
  /// - `Quality`: Very high quality, suitable for professional photography and
  ///    printing.
  /// - `File Size`: Very large, especially with lossless compression.
  /// - `Use Case`: Professional photography, desktop publishing, scanning, and
  ///    archival storage.
  tiff,

  /// BMP (Bitmap)
  ///
  /// - `Compression`: None or lossless
  /// - `Quality`: Very high quality with no loss of data.
  /// - `File Size`: Very large, as it stores image data without compression.
  /// - `Use Case`: Simple graphics and images on Windows platforms, where file
  ///   size is not a concern.
  bmp,

  /// CUR (Cursor)
  ///
  /// - `Compression`: Typically none
  /// - `Quality`: Varies, usually optimized for small size and simplicity.
  /// - `File Size`: Small, designed for cursors.
  /// - `Use Case`: Mouse pointers/cursors in Windows operating systems.
  cur,

  /// PVR (PowerVR Texture)
  ///
  /// - `Compression`: Lossy and specialized for texture compression
  /// - `Quality`: Varies based on compression level; optimized for use in
  ///   graphics rendering, especially in games.
  /// - `File Size`: Generally small, efficient for textures.
  /// - `Use Case`: Texture maps in 3D graphics, especially in mobile and
  ///   console games.
  pvr,

  /// TGA (Targa)
  ///
  /// - `Compression`: None or lossless
  /// - `Quality`: High quality, supports alpha channels.
  /// - `File Size`: Larger due to optional compression.
  /// - `Use Case`: Video game textures, simple animations, and image
  ///   processing where alpha channel is needed.
  tga,

  /// ICO (Icon)
  ///
  /// - `Compression`: Typically none or simple RLE (Run-Length Encoding)
  /// - `Quality`: Varies; can include multiple sizes and bit depths.
  /// - `File Size`: Small, optimized for icons.
  /// - `Use Case`: Icons for software applications and operating systems.
  ico
}
