// Flutter imports:
import 'package:flutter/material.dart';

/// Customizable icons for Main-Editor component.
class MainEditorIcons {
  /// Creates an instance of [MainEditorIcons] with customizable icon settings.
  const MainEditorIcons({
    this.closeEditor = Icons.clear,
    this.doneIcon = Icons.done,
    this.applyChanges = Icons.done,
    this.backButton = Icons.arrow_back,
    this.undoAction = Icons.undo,
    this.redoAction = Icons.redo,
    this.removeElementZone = Icons.delete_outline_rounded,
  });

  /// The icon for closing the editor without saving.
  final IconData closeEditor;

  /// The icon for applying changes and closing the editor.
  final IconData doneIcon;

  /// The icon for the back button.
  final IconData backButton;

  /// The icon for applying changes in the editor.
  final IconData applyChanges;

  /// The icon for undoing the last action.
  final IconData undoAction;

  /// The icon for redoing the last undone action.
  final IconData redoAction;

  /// The icon for removing an element/ layer like an emoji.
  final IconData removeElementZone;

  /// Creates a copy of this `MainEditorIcons` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [MainEditorIcons] with some properties updated while keeping the
  /// others unchanged.
  MainEditorIcons copyWith({
    IconData? doneIcon,
    IconData? closeEditor,
    IconData? backButton,
    IconData? applyChanges,
    IconData? undoAction,
    IconData? redoAction,
    IconData? removeElementZone,
  }) {
    return MainEditorIcons(
      doneIcon: doneIcon ?? this.doneIcon,
      closeEditor: closeEditor ?? this.closeEditor,
      backButton: backButton ?? this.backButton,
      applyChanges: applyChanges ?? this.applyChanges,
      undoAction: undoAction ?? this.undoAction,
      redoAction: redoAction ?? this.redoAction,
      removeElementZone: removeElementZone ?? this.removeElementZone,
    );
  }
}
