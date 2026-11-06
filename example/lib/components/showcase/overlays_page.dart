import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'showcase.dart';

/// Dialog, BottomSheet, Drawer, Snackbar and Popover.
class OverlaysPage extends StatefulComponent {
  const OverlaysPage({super.key});

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage> {
  final _dialog = OverlayController();
  final _glassDialog = OverlayController();
  final _sheet = OverlayController();
  final _drawer = OverlayController();
  final _snackbar = OverlayController();

  @override
  void dispose() {
    _dialog.dispose();
    _glassDialog.dispose();
    _sheet.dispose();
    _drawer.dispose();
    _snackbar.dispose();
    super.dispose();
  }

  Component _dialogFor(OverlayController controller, {bool glass = false}) {
    return Dialog(
      controller: controller,
      glass: glass,
      barrierDismissible: true,
      title: glass ? 'Glass dialog' : 'Dialog',
      subtitle: 'Tap outside to dismiss.',
      actions: [
        Button.text(
          'Close',
          onTap: controller.close,
          width: const Dim.px(150),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: Dim.px(20),
          ),
        ),
      ],
    );
  }

  @override
  Component build(BuildContext context) {
    return ShowcasePage(
      groups: [
        ShowcaseGroup(
          title: 'Overlays',
          subtitle: 'Controller driven, with focus and Escape handled for you.',
          demos: [
            Demo(
              name: 'Dialog',
              child: Row(
                spacing: 8,
                children: [
                  Button.text(
                    'Open',
                    onTap: _dialog.open,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(12),
                    ),
                  ),
                  Button.text(
                    'Open glass',
                    onTap: _glassDialog.open,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(20),
                    ),
                  ),
                  _dialogFor(_dialog),
                  _dialogFor(_glassDialog, glass: true),
                ],
              ),
            ),
            Demo(
              name: 'BottomSheet',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button.text(
                    'Open',
                    onTap: _sheet.open,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(20),
                    ),
                  ),
                  BottomSheet(
                    controller: _sheet,
                    child: Padding(
                      padding: const EdgeInsets.all(Dim.px(24)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          const Heading('Share', level: 3),
                          const SizedBox.height(Dim.px(20)),
                          Button.text(
                            'Copy link',
                            onTap: _sheet.close,
                            width: const Dim.px(200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dim.px(20),
                            ),
                          ),
                          Button.text(
                            'Send by email',
                            onTap: _sheet.close,
                            width: const Dim.px(200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dim.px(20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Demo(
              name: 'Drawer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button.text(
                    'Open',
                    onTap: _drawer.open,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(20),
                    ),
                  ),
                  Drawer(
                    controller: _drawer,
                    position: DrawerPosition.left,
                    width: const Dim.px(280),
                    child: Padding(
                      padding: const EdgeInsets.all(Dim.px(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          const Heading('Menu', level: 3),
                          Button.text(
                            'Close',
                            onTap: _drawer.close,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            width: const Dim.px(200),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Demo(
              name: 'Snackbar',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button.text(
                    'Show',
                    onTap: _snackbar.open,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(20),
                    ),
                  ),
                  Snackbar(
                    controller: _snackbar,
                    position: SnackbarPosition.top,
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.green,
                    content: const NakiText('Changes saved'),
                    foregroundColor: Colors.white,
                    closeIconColor: Colors.white.withOpacity(80),
                    showCloseIcon: true,
                  ),
                ],
              ),
            ),
            Demo(
              name: 'Popover',
              child: Row(
                children: [
                  Popover(
                    position: PopoverPosition.bottomLeft,
                    content: const NakiText('Anchored to its trigger'),
                    child: Button.text(
                      'Options',
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dim.px(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
