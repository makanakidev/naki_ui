import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'showcase.dart';

/// Dialog, BottomSheet, Drawer, Snackbar, Popover and Tooltip.
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

  String? _popoverVisible;

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
          height: const Dim.px(40),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: Dim.px(20),
          ),
        ),
      ],
    );
  }

  Future<void> _askToDelete() async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        title: 'Delete item?',
        subtitle: 'showDialog completes with the button you pick.',
        barrierDismissible: true,
        actions: [
          Button.text('Cancel', onTap: () => closeDialog(context, false)),
          Button.text(
            'Delete',
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            onTap: () => closeDialog(context, true),
          ),
        ],
      ),
    );

    if (!mounted) return;

    showSnackbar(
      context,
      Snackbar(
        position: SnackbarPosition.top,
        duration: const Duration(seconds: 2),
        content: NakiText(switch (deleted) {
          true => 'Deleted',
          false => 'Kept',
          null => 'Dismissed',
        }),
      ),
    );
  }

  Future<void> _pickShareTarget() async {
    Component option(BuildContext context, String label) => Button.text(
      label,
      onTap: () => closeModalBottomSheet(context, label),
      width: const Dim.px(200),
      height: const Dim.px(40),
      padding: const EdgeInsets.symmetric(horizontal: Dim.px(20)),
    );

    final target = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(Dim.px(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            const Heading('Share to', level: 3),
            option(context, 'Messages'),
            option(context, 'Mail'),
          ],
        ),
      ),
    );

    if (!mounted) return;

    showSnackbar(
      context,
      Snackbar(
        position: SnackbarPosition.top,
        duration: const Duration(seconds: 2),
        content: NakiText(target == null ? 'Dismissed' : 'Shared to $target'),
      ),
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
                    height: const Dim.px(40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(12),
                    ),
                  ),
                  Button.text(
                    'Open glass',
                    onTap: _glassDialog.open,
                    height: const Dim.px(40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(20),
                    ),
                  ),
                  Button.text(
                    'showDialog',
                    onTap: _askToDelete,
                    height: const Dim.px(40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(12),
                    ),
                  ),
                  _dialogFor(_dialog),
                  _dialogFor(_glassDialog, glass: true),
                ],
              ),
            ),
            Demo(
              name: 'BottomSheet',
              child: Row(
                spacing: 8,
                children: [
                  Button.text(
                    'Open',
                    onTap: _sheet.open,
                    height: const Dim.px(40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(20),
                    ),
                  ),
                  Button.text(
                    'showModalBottomSheet',
                    onTap: _pickShareTarget,
                    height: const Dim.px(40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(12),
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
                          Button.text(
                            'Copy link',
                            onTap: _sheet.close,
                            width: const Dim.px(200),
                            height: const Dim.px(40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dim.px(20),
                            ),
                          ),
                          Button.text(
                            'Send by email',
                            onTap: _sheet.close,
                            width: const Dim.px(200),
                            height: const Dim.px(40),
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
                    height: const Dim.px(40),
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
                            height: const Dim.px(40),
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
                mainAxisAlignment: .spaceBetween,
                children: [
                  Popover(
                    position: PopoverPosition.left,
                    visible: _popoverVisible == 'left',
                    content: const NakiText(
                      'Opens left, flips when there is no room',
                    ),
                    onClose: () => setState(() => _popoverVisible = null),
                    child: Button.text(
                      'Left',
                      onTap: () => setState(() => _popoverVisible = 'left'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dim.px(20),
                      ),
                    ),
                  ),
                  Popover(
                    position: PopoverPosition.top,
                    content: const NakiText('Shown on hover or focus'),
                    child: Button.text(
                      'Hover',
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dim.px(20),
                      ),
                    ),
                  ),
                  Popover(
                    position: PopoverPosition.bottom,
                    visible: _popoverVisible == 'bottom',
                    content: const NakiText(
                      'Anchored to its trigger, inside the safe area',
                    ),
                    onClose: () => setState(() => _popoverVisible = null),
                    child: Button.text(
                      'Right',
                      onTap: () => setState(() => _popoverVisible = 'bottom'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dim.px(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Demo(
              name: 'Tooltip',
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Tooltip(
                    text: 'Flips to stay on screen',
                    position: TooltipPosition.left,
                    child: Button.text(
                      'Left',
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dim.px(20),
                      ),
                    ),
                  ),
                  Tooltip(
                    text: 'Shown on hover or focus',
                    position: TooltipPosition.top,
                    child: Button.text(
                      'Top',
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dim.px(20),
                      ),
                    ),
                  ),
                  Tooltip(
                    text: 'Slides to stay on screen',
                    position: TooltipPosition.right,
                    child: Button.text(
                      'Right',
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
