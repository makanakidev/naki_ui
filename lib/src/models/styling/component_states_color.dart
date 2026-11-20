part of 'index.dart';

/// Color attributes for different states of a component.
class ComponentStatesColor implements NakiStylable {
  /// Color applied to the border of a component when focused.
  final Color? focusBorderColor;

  /// Color applied to the foreground of a component when hovered.
  final Color? hoverColor;

  /// Color applied to the background of a component when hovered.
  final Color? hoverBackgroundColor;

  /// Color applied to a validation text or error message.
  final Color? errorTextColor;

  /// Color applied to the background of a component when disabled.
  final Color? disabledBackgroundColor;

  /// Color applied to the foreground of a component when disabled.
  final Color? disabledColor;

  /// Create a new state color.
  const ComponentStatesColor({
    this.focusBorderColor,
    this.hoverColor,
    this.hoverBackgroundColor,
    this.errorTextColor,
    this.disabledBackgroundColor,
    this.disabledColor,
  });

  /// Create a copy of the state color.
  ComponentStatesColor copyWith({
    Color? focusBorderColor,
    Color? hoverColor,
    Color? hoverBackgroundColor,
    Color? errorTextColor,
    Color? disabledBackgroundColor,
    Color? disabledColor,
  }) => ComponentStatesColor(
    focusBorderColor: focusBorderColor ?? this.focusBorderColor,
    hoverColor: hoverColor ?? this.hoverColor,
    hoverBackgroundColor: hoverBackgroundColor ?? this.hoverBackgroundColor,
    errorTextColor: errorTextColor ?? this.errorTextColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    disabledColor: disabledColor ?? this.disabledColor,
  );

  /// Converts state colors to a CSS style map of global variables.
  @override
  Map<String, String> get props => {
    Tokens.current.focusBorderColor.name: ?focusBorderColor?.value,
    Tokens.current.fieldHoverColor.name: ?hoverColor?.value,
    Tokens.current.hoverColor.name: ?hoverColor?.value,
    Tokens.current.buttonHoverBgColor.name: ?hoverBackgroundColor?.value,
    Tokens.current.errorColor.name: ?errorTextColor?.value,
    Tokens.current.disabledBgColor.name: ?disabledBackgroundColor?.value,
    Tokens.current.disabledColor.name: ?disabledColor?.value,
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentStatesColor &&
          runtimeType == other.runtimeType &&
          focusBorderColor == other.focusBorderColor &&
          hoverColor == other.hoverColor &&
          hoverBackgroundColor == other.hoverBackgroundColor &&
          errorTextColor == other.errorTextColor &&
          disabledBackgroundColor == other.disabledBackgroundColor &&
          disabledColor == other.disabledColor;

  @override
  int get hashCode => Object.hash(
    focusBorderColor,
    hoverColor,
    hoverBackgroundColor,
    errorTextColor,
    disabledBackgroundColor,
    disabledColor,
  );
}
