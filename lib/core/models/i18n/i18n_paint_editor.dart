/// Internationalization (i18n) settings for the Paint Editor component.
class I18nPaintEditor {
  /// Creates an instance of [I18nPaintEditor] with customizable
  /// internationalization settings.
  ///
  /// You can provide translations and messages for various components of the
  /// Paint Editor in the Image Editor. Customize the text for paint
  /// modes, buttons, and messages to suit your application's language and
  /// style.
  const I18nPaintEditor({
    this.moveAndZoom = 'Zoom',
    this.bottomNavigationBarText = 'Paint',
    this.freestyle = 'Freestyle',
    this.freestyleArrowStart = 'Freestyle arrow start',
    this.freestyleArrowEnd = 'Freestyle arrow end',
    this.freestyleArrowStartEnd = 'Freestyle arrow start-end',
    this.arrow = 'Arrow',
    this.line = 'Line',
    this.rectangle = 'Rectangle',
    this.circle = 'Circle',
    this.dashLine = 'Dash line',
    this.dashDotLine = 'Dash-dot line',
    this.hexagon = 'Hexagon',
    this.polygon = 'Polygon',
    this.blur = 'Blur',
    this.pixelate = 'Pixelate',
    this.lineWidth = 'Line width',
    this.eraser = 'Eraser',
    this.toggleFill = 'Toggle fill',
    this.changeOpacity = 'Change opacity',
    this.undo = 'Undo',
    this.redo = 'Redo',
    this.done = 'Done',
    this.back = 'Back',
    this.smallScreenMoreTooltip = 'More',
    this.opacity = 'Opacity',
    this.color = 'Color',
    this.strokeWidth = 'Stroke Width',
    this.fill = 'Fill',
    this.cancel = 'Cancel',
  });

  /// Text for the bottom navigation bar item that opens the Paint Editor.
  final String bottomNavigationBarText;

  /// The text used for moving and zooming within the editor.
  final String moveAndZoom;

  /// Text for the "Freestyle" paint mode.
  final String freestyle;

  /// Text for the "Freestyle arrow start" paint mode.
  final String freestyleArrowStart;

  /// Text for the "Freestyle arrow end" paint mode.
  final String freestyleArrowEnd;

  /// Text for the "Freestyle arrow start-end" paint mode.
  final String freestyleArrowStartEnd;

  /// Text for the "Arrow" paint mode.
  final String arrow;

  /// Text for the "Line" paint mode.
  final String line;

  /// Text for the "Rectangle" paint mode.
  final String rectangle;

  /// Text for the "Circle" paint mode.
  final String circle;

  /// Text for the "Dash line" paint mode.
  final String dashLine;

  /// Text for the "Dash-dot line" paint mode.
  final String dashDotLine;

  /// Text for the "Hexagon" paint mode.
  final String hexagon;

  /// Text for the "Polygon" paint mode.
  final String polygon;

  /// Text for the "Blur" paint mode.
  final String blur;

  /// Text for the "Pixelate" paint mode.
  final String pixelate;

  /// Text for the "Eraser" paint mode.
  final String eraser;

  /// Text for the "Line width" tooltip.
  final String lineWidth;

  /// Text for the "Toggle fill" tooltip.
  final String toggleFill;

  /// Text for the "Change opacity" tooltip.
  final String changeOpacity;

  /// Label for the opacity slider.
  final String opacity;

  /// Label for the color slider.
  final String color;

  /// Label for the stroke width control.
  final String strokeWidth;

  /// Label for the fill mode.
  final String fill;

  /// Label for the cancel button.
  final String cancel;

  /// Text for the "Undo" button.
  final String undo;

  /// Text for the "Redo" button.
  final String redo;

  /// Text for the "Done" button.
  final String done;

  /// Text for the "Back" button.
  final String back;

  /// The tooltip text displayed for the "More" option on small screens.
  final String smallScreenMoreTooltip;

  /// Creates a copy of this `I18nPaintEditor` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [I18nPaintEditor] with some properties updated while keeping the
  /// others unchanged.
  I18nPaintEditor copyWith({
    String? bottomNavigationBarText,
    String? moveAndZoom,
    String? freestyle,
    String? freestyleArrowStart,
    String? freestyleArrowEnd,
    String? freestyleArrowStartEnd,
    String? arrow,
    String? line,
    String? rectangle,
    String? circle,
    String? dashLine,
    String? dashDotLine,
    String? hexagon,
    String? polygon,
    String? blur,
    String? pixelate,
    String? eraser,
    String? lineWidth,
    String? toggleFill,
    String? changeOpacity,
    String? opacity,
    String? color,
    String? strokeWidth,
    String? fill,
    String? cancel,
    String? undo,
    String? redo,
    String? done,
    String? back,
    String? smallScreenMoreTooltip,
  }) {
    return I18nPaintEditor(
      bottomNavigationBarText:
          bottomNavigationBarText ?? this.bottomNavigationBarText,
      moveAndZoom: moveAndZoom ?? this.moveAndZoom,
      freestyle: freestyle ?? this.freestyle,
      freestyleArrowStart: freestyleArrowStart ?? this.freestyleArrowStart,
      freestyleArrowEnd: freestyleArrowEnd ?? this.freestyleArrowEnd,
      freestyleArrowStartEnd:
          freestyleArrowStartEnd ?? this.freestyleArrowStartEnd,
      arrow: arrow ?? this.arrow,
      line: line ?? this.line,
      rectangle: rectangle ?? this.rectangle,
      circle: circle ?? this.circle,
      dashLine: dashLine ?? this.dashLine,
      dashDotLine: dashDotLine ?? this.dashDotLine,
      hexagon: hexagon ?? this.hexagon,
      polygon: polygon ?? this.polygon,
      blur: blur ?? this.blur,
      pixelate: pixelate ?? this.pixelate,
      eraser: eraser ?? this.eraser,
      lineWidth: lineWidth ?? this.lineWidth,
      toggleFill: toggleFill ?? this.toggleFill,
      changeOpacity: changeOpacity ?? this.changeOpacity,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fill: fill ?? this.fill,
      cancel: cancel ?? this.cancel,
      undo: undo ?? this.undo,
      redo: redo ?? this.redo,
      done: done ?? this.done,
      back: back ?? this.back,
      smallScreenMoreTooltip:
          smallScreenMoreTooltip ?? this.smallScreenMoreTooltip,
    );
  }
}
