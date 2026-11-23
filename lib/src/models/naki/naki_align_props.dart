import '../../utilities/enums/index.dart';

/// Used internally by Naki components to map alignment
/// properties to CSS values.
class NakiAlignProps {
  /// Maps [MainAxisAlignment] to its CSS equivalent.
  static String mapMainAxisAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return 'flex-start';
      case MainAxisAlignment.end:
        return 'flex-end';
      case MainAxisAlignment.center:
        return 'center';
      case MainAxisAlignment.spaceBetween:
        return 'space-between';
      case MainAxisAlignment.spaceAround:
        return 'space-around';
      case MainAxisAlignment.spaceEvenly:
        return 'space-evenly';
    }
  }

  /// Maps [CrossAxisAlignment] to its CSS equivalent.
  static String mapCrossAxisAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return 'flex-start';
      case CrossAxisAlignment.end:
        return 'flex-end';
      case CrossAxisAlignment.center:
        return 'center';
      case CrossAxisAlignment.stretch:
        return 'stretch';
      case CrossAxisAlignment.baseline:
        return 'baseline';
    }
  }

  /// Maps [Alignment] to its CSS equivalent.
  static Map<String, String> mapAlignment(Alignment alignment) {
    switch (alignment) {
      case Alignment.topLeft:
        return {'justify-content': 'flex-start', 'align-items': 'flex-start'};
      case Alignment.topCenter:
        return {'justify-content': 'center', 'align-items': 'flex-start'};
      case Alignment.topRight:
        return {'justify-content': 'flex-end', 'align-items': 'flex-start'};
      case Alignment.centerLeft:
        return {'justify-content': 'flex-start', 'align-items': 'center'};
      case Alignment.center:
        return {'justify-content': 'center', 'align-items': 'center'};
      case Alignment.centerRight:
        return {'justify-content': 'flex-end', 'align-items': 'center'};
      case Alignment.bottomLeft:
        return {'justify-content': 'flex-start', 'align-items': 'flex-end'};
      case Alignment.bottomCenter:
        return {'justify-content': 'center', 'align-items': 'flex-end'};
      case Alignment.bottomRight:
        return {'justify-content': 'flex-end', 'align-items': 'flex-end'};
    }
  }

  /// Maps [Alignment] to its CSS `transform-origin` equivalent.
  static String mapTransformOrigin(Alignment alignment) {
    switch (alignment) {
      case Alignment.topLeft:
        return 'top left';
      case Alignment.topCenter:
        return 'top center';
      case Alignment.topRight:
        return 'top right';
      case Alignment.centerLeft:
        return 'center left';
      case Alignment.center:
        return 'center';
      case Alignment.centerRight:
        return 'center right';
      case Alignment.bottomLeft:
        return 'bottom left';
      case Alignment.bottomCenter:
        return 'bottom center';
      case Alignment.bottomRight:
        return 'bottom right';
    }
  }

  /// Maps [Alignment] and [StackFit] to its CSS Grid equivalent (`place-items`).
  static Map<String, String> mapGridAlignment(
    Alignment alignment, [
    StackFit fit = StackFit.loose,
  ]) {
    if (fit == StackFit.expand) {
      return {
        'place-items': 'stretch stretch',
        'width': '100%',
        'height': '100%',
      };
    }

    if (fit == StackFit.passthrough) {
      return {
        'place-items': 'normal normal',
        'width': 'inherit',
        'height': 'inherit',
      };
    }

    switch (alignment) {
      case Alignment.topLeft:
        return {'place-items': 'start start'};
      case Alignment.topCenter:
        return {'place-items': 'start center'};
      case Alignment.topRight:
        return {'place-items': 'start end'};
      case Alignment.centerLeft:
        return {'place-items': 'center start'};
      case Alignment.center:
        return {'place-items': 'center center'};
      case Alignment.centerRight:
        return {'place-items': 'center end'};
      case Alignment.bottomLeft:
        return {'place-items': 'end start'};
      case Alignment.bottomCenter:
        return {'place-items': 'end center'};
      case Alignment.bottomRight:
        return {'place-items': 'end end'};
    }
  }
}
