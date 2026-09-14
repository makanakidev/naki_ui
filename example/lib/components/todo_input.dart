import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart' show MaterialIcons;
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

class TodoInput extends StatefulComponent {
  final ValueChanged<String> onAdd;

  const TodoInput({super.key, required this.onAdd});

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  String _currentText = '';
  int _inputKeyVersion = 0;

  void _submit() {
    final trimmed = _currentText.trim();
    if (trimmed.isNotEmpty) {
      component.onAdd(trimmed);
      setState(() {
        _currentText = '';
        _inputKeyVersion++;
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return Card.outlined(
      borderRadius: BorderRadiusData.all(const Dim.px(14)),
      padding: const EdgeInsets.symmetric(
        horizontal: Dim.px(10),
        vertical: Dim.px(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Expanded(
            child: TextField(
              key: ValueKey(_inputKeyVersion),
              id: 'todo-text-input-$_inputKeyVersion',
              type: InputType.text,
              decoration: const InputDecoration(
                placeholderText: 'What needs to be done?',
              ),
              onTyping: (value) => _currentText = value,
              onSubmit: (_) => _submit(),
            ),
          ),
          Button.filled(
            context.primaryColor,
            id: 'add-task-submit-button',
            hoverColor: context.primaryColor.withOpacity(0.8),
            border: BorderData.only(radius: BorderRadiusData.all(const Dim.px(8))),
            attributes: const {'aria-label': 'Add new task'},
            onTap: _submit,
            height: const Dim.px(45),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(
                  MaterialIcons.icon_round_add,
                  size: 18,
                  color: Colors.white,
                ),
                NakiText(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
