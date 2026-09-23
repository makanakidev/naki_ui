import 'package:jaspr/dom.dart' hide Filter;
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

  void _submit() {
    final trimmed = _currentText.trim();
    if (trimmed.isNotEmpty) {
      component.onAdd(trimmed);
      _currentText = '';
    }
  }

  @override
  Component build(BuildContext context) {
    return Card.outlined(
      borderRadius: BorderRadiusData.all(const Dim.px(20)),
      border: BorderData(color: context.borderColor.withOpacity(0.5)),
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
              id: 'todo-text-input',
              type: InputType.text,
              decoration: InputDecoration(
                border: BorderData(
                  color: context.borderColor.withOpacity(0.3),
                ),
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
            attributes: const {'aria-label': 'Add new task'},
            onTap: _submit,
            height: const Dim.px(45),
            foregroundColor: Colors.white,
            child: const Icon(MaterialIcons.icon_round_add),
          ),
        ],
      ),
    );
  }
}
