import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import '../models/todo_item.dart';
import '../services/todo_storage.dart';
import 'empty_state.dart';
import 'todo_filter_bar.dart';
import 'todo_header.dart';
import 'todo_input.dart';
import 'todo_item_tile.dart';

class Content extends StatefulComponent {
  const Content({super.key});

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late final OverlayController _snackbarController;

  String _snackbarMessage = '';
  List<TodoItem> _todos = [];
  TodoFilter _filter = TodoFilter.all;

  List<ScrollPhysics> _scrollPhysics = [
    const ClampingScrollPhysics(),
    const BouncingScrollPhysics(),
  ];

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _todos = TodoStorage.load();
    _snackbarController = OverlayController();
  }

  @override
  void dispose() {
    _snackbarController.dispose();
    super.dispose();
  }

  void _save() => TodoStorage.save(_todos);

  void _showFeedback(String message) {
    setState(() => _snackbarMessage = message);
    _snackbarController.open();
  }

  void _addTodo(String title) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final item = TodoItem(
      id: now.toString(),
      title: title,
      isCompleted: false,
      createdAt: now,
    );

    _todos = [..._todos, item];

    _showFeedback('Task added');
    _save();
  }

  void _toggleTodo(String id, bool completed) {
    _todos = _todos
        .map((t) => t.id == id ? t.copyWith(isCompleted: completed) : t)
        .toList();
    _showFeedback(completed ? 'Task completed' : 'Task marked active');
    _save();
  }

  void _deleteTodo(String id) {
    _todos = _todos.where((t) => t.id != id).toList();
    _showFeedback('Task removed');
    _save();
  }

  void _toggleScrollPhysics() {
    setState(() => _scrollPhysics = _scrollPhysics.reversed.toList());
    _showFeedback(
      '${_scrollPhysics.first.type.name} scroll physics',
    );
  }

  // void _clearCompleted() {
  //   final completedCount = _todos.where((t) => t.isCompleted).length;
  //   if (completedCount == 0) return;

  //   _todos = _todos.where((t) => !t.isCompleted).toList();

  //   _showFeedback(
  //     'Cleared $completedCount completed ${completedCount == 1 ? 'task' : 'tasks'}',
  //   );
  //   _save();
  // }

  @override
  Component build(BuildContext context) {
    return SingleChildScrollView(
      physics: _scrollPhysics.first,
      padding: const EdgeInsets.symmetric(
        horizontal: Dim.px(16),
        vertical: Dim.px(24),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: MediaQueryProvider(
          id: 'todo-container',
          builder: (context) {
            final totalCount = _todos.length;
            final completedCount = _todos.where((t) => t.isCompleted).length;
            final activeCount = totalCount - completedCount;

            final mqHeight = MediaQueryProvider.heightOf(context) ?? 0;

            final filteredTodos = _todos.where((todo) {
              switch (_filter) {
                case TodoFilter.all:
                  return true;
                case TodoFilter.active:
                  return !todo.isCompleted;
                case TodoFilter.completed:
                  return todo.isCompleted;
              }
            }).toList();

            return Container(
              width: const Dim.percent(100),
              constraints: const SizeConstraints(maxWidth: Dim.px(540)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  // header
                  TodoHeader(
                    totalCount: totalCount,
                    completedCount: completedCount,
                  ),

                  // input
                  TodoInput(onAdd: _addTodo),

                  // filter bar
                  if (_todos.isNotEmpty)
                    TodoFilterBar(
                      activeCount: activeCount,
                      currentFilter: _filter,
                      onFilterChanged: (f) => setState(() => _filter = f),
                      hasCompleted: completedCount > 0,
                      toggle: mqHeight > PlatformData().height
                          ? _toggleScrollPhysics
                          : null,
                    ),

                  // items
                  if (filteredTodos.isEmpty)
                    EmptyState(filter: _filter)
                  else
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: filteredTodos
                          .map(
                            (todo) => TodoItemTile(
                              key: ValueKey(todo.id),
                              todo: todo,
                              onToggle: (checked) =>
                                  _toggleTodo(todo.id, checked),
                              onDelete: () => _deleteTodo(todo.id),
                            ),
                          )
                          .toList(),
                    ),

                  // Footer
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dim.px(30)),
                      child: Align(
                        child: NakiText(
                          'Built with Jaspr & Naki UI',
                          style: TextStyle(
                            color: context.subtitleColor,
                            fontSize: const Dim.rem(0.9),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // snackbar
                  Snackbar(
                    controller: _snackbarController,
                    duration: const Duration(seconds: 5),
                    position: SnackbarPosition.top,
                    content: NakiText(_snackbarMessage),
                    showCloseIcon: true,
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    closeIconColor: Colors.black,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
