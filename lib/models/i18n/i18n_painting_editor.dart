/// Internationalization (i18n) settings for the Painting Editor component.
class I18nPaintingEditor {
  /// Text for the bottom navigation bar item that opens the Painting Editor.
  final String bottomNavigationBarText;

  /// The text used for moving and zooming within the editor.
  ///
  /// This icon appears in the editor bottombar.
  ///
  /// When in the [PaintEditorConfigs] the config [editorIsZoomable] is set to
  /// `true`, this text will be displayed, allowing users to interact with the
  /// editor's zoom and move features. If [editorIsZoomable] is set to `false`,
  /// the text will be hidden.
  final String moveAndZoom;

  /// Text for the "Freestyle" painting mode.
  final String freestyle;

  /// Text for the "Arrow" painting mode.
  final String arrow;

  /// Text for the "Line" painting mode.
  final String line;

  /// Text for the "Rectangle" painting mode.
  final String rectangle;

  /// Text for the "Circle" painting mode.
  final String circle;

  /// Text for the "Dash line" painting mode.
  final String dashLine;

  /// Text for the "Eraser" painting mode.
  final String eraser;

  /// Text for the "Line width" tooltip.
  final String lineWidth;

  /// Text for the "Toggle fill" tooltip.
  final String toggleFill;

  /// Text for the "Change opacity" tooltip.
  final String changeOpacity;

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

  /// Creates an instance of [I18nPaintingEditor] with customizable internationalization settings.
  ///
  /// You can provide translations and messages for various components of the
  /// Painting Editor in the Image Editor. Customize the text for painting modes,
  /// buttons, and messages to suit your application's language and style.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nPaintingEditor(
  ///   bottomNavigationBarText: 'Paint',
  ///   freestyle: 'Freestyle',
  ///   arrow: 'Arrow',
  ///   line: 'Line',
  ///   rectangle: 'Rectangle',
  ///   circle: 'Circle',
  ///   dashLine: 'Dash Line',
  ///   lineWidth: 'Line Width',
  ///   toggleFill: 'Toggle fill',
  ///   changeOpacity = 'Change opacity',
  ///   eraser: 'Eraser',
  ///   undo: 'Undo',
  ///   redo: 'Redo',
  ///   done: 'Done',
  ///   back: 'Back',
  /// )
  /// ```
  const I18nPaintingEditor({
    this.moveAndZoom = 'Zoom',
    this.bottomNavigationBarText = 'Paint',
    this.freestyle = 'Freestyle',
    this.arrow = 'Arrow',
    this.line = 'Line',
    this.rectangle = 'Rectangle',
    this.circle = 'Circle',
    this.dashLine = 'Dash line',
    this.lineWidth = 'Line width',
    this.eraser = 'Eraser',
    this.toggleFill = 'Toggle fill',
    this.changeOpacity = 'Change opacity',
    this.undo = 'Undo',
    this.redo = 'Redo',
    this.done = 'Done',
    this.back = 'Back',
    this.smallScreenMoreTooltip = 'More',
  });
}
