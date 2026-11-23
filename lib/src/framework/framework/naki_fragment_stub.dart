import 'package:jaspr/jaspr.dart';

/// Creates the platform-appropriate [RenderFragment] for [parent].
RenderFragment createNakiRenderFragment(RenderObject parent) =>
    parent.createChildRenderFragment();
