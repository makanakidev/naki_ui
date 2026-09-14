import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart' show MaterialIcons;
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'components/empty_state.dart';
import 'components/todo_filter_bar.dart';
import 'components/todo_header.dart';
import 'components/todo_input.dart';
import 'components/todo_item_tile.dart';
import 'models/todo_item.dart';
import 'services/todo_storage.dart';

@client
class TodoApp extends StatefulComponent {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final OverlayController _snackbarController;

  late ValueNotifier<String> _snackbarMessageNotifier;
  late ValueNotifier<List<TodoItem>> _todosNotifier;
  late ValueNotifier<TodoFilter> _filterNotifier;

  @override
  void initState() {
    super.initState();
    final items = TodoStorage.load();
    _todosNotifier = ValueNotifier<List<TodoItem>>(items);
    _filterNotifier = ValueNotifier<TodoFilter>(TodoFilter.all);
    _snackbarMessageNotifier = ValueNotifier<String>('');
    _snackbarController = OverlayController();
  }

  @override
  void dispose() {
    _snackbarController.dispose();
    super.dispose();
  }

  void _save() => TodoStorage.save(_todosNotifier.value);

  void _showFeedback(String message) {
    _snackbarMessageNotifier.value = message;
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

    _showFeedback('Task added');
    _todosNotifier.value = [..._todosNotifier.value, item];
    _save();
  }

  void _toggleTodo(String id, bool completed) {
    _showFeedback(completed ? 'Task completed' : 'Task marked active');
    _todosNotifier.value = _todosNotifier.value
        .map((t) => t.id == id ? t.copyWith(isCompleted: completed) : t)
        .toList();
    _save();
  }

  void _deleteTodo(String id) {
    _showFeedback('Task removed');
    _todosNotifier.value = _todosNotifier.value.where((t) => t.id != id).toList();
    _save();
  }

  void _clearCompleted() {
    final completedCount = _todosNotifier.value.where((t) => t.isCompleted).length;
    if (completedCount == 0) return;
    _showFeedback(
      'Cleared $completedCount completed ${completedCount == 1 ? 'task' : 'tasks'}',
    );
    _todosNotifier.value = _todosNotifier.value.where((t) => !t.isCompleted).toList();
    _save();
  }

  @override
  Component build(BuildContext context) {
    return NakiApp(
      title: 'Minimalist Tasks',
      locale: 'en',
      themeMode: ThemeMode.system,
      cacheThemeMode: true,
      favicon: '/assets/favicon.jpg',
      lightTheme: const LightThemeData(
        colorSeed: ColorSeed(
          primary: Color('#2563eb'),
          backgroundColor: Color('#f8fafc'),
          baseTextColor: Color('#0f172a'),
        ),
        typography: TypographyScheme(
          fontFamily: ['Inter', 'system-ui', 'sans-serif'],
        ),
      ),
      darkTheme: const DarkThemeData(
        colorSeed: ColorSeed(
          primary: Color('#60a5fa'),
          backgroundColor: Color('#090d16'),
          baseTextColor: Color('#f8fafc'),
        ),
        typography: TypographyScheme(
          fontFamily: ['Inter', 'system-ui', 'sans-serif'],
        ),
      ),
      seo: const SEO(
        title: 'Minimalist Tasks — Naki UI',
        description: 'A sleek, minimalist to-do application built with Naki UI.',
      ),
      pageBuilder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            titleText: 'Tasks',
            actions: [
              Button.icon(
                context.themeMode == ThemeMode.dark
                    ? MaterialIcons.icon_round_light_mode
                    : MaterialIcons.icon_round_dark_mode,
                size: 20,
                attributes: const {'aria-label': 'Toggle theme mode'},
                onTap: context.toggleTheme,
              ),
            ],
          ),
          body: SafeArea(
            child: .fragment([
              // main content
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dim.px(16),
                  vertical: Dim.px(24),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ListenableBuilder(
                    listenable: Listenable.merge([
                      _todosNotifier,
                      _filterNotifier,
                    ]),
                    builder: (context) {
                      final todos = _todosNotifier.value;
                      final filter = _filterNotifier.value;

                      final totalCount = todos.length;
                      final completedCount = todos.where((t) => t.isCompleted).length;
                      final activeCount = totalCount - completedCount;

                      final filteredTodos = todos.where((todo) {
                        switch (filter) {
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
                            if (todos.isNotEmpty)
                              TodoFilterBar(
                                activeCount: activeCount,
                                currentFilter: filter,
                                onFilterChanged: (f) => _filterNotifier.value = f,
                                hasCompleted: completedCount > 0,
                                onClearCompleted: _clearCompleted,
                              ),

                            // items
                            if (filteredTodos.isEmpty)
                              EmptyState(filter: filter)
                            else
                              Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: filteredTodos
                                    .map(
                                      (todo) => TodoItemTile(
                                        key: ValueKey(todo.id),
                                        todo: todo,
                                        onToggle: (checked) => _toggleTodo(todo.id, checked),
                                        onDelete: () => _deleteTodo(todo.id),
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // snackbar
              ValueListenableBuilder(
                listenable: _snackbarMessageNotifier,
                builder: (context, message) {
                  return Snackbar(
                    controller: _snackbarController,
                    duration: const Duration(seconds: 3),
                    position: SnackbarPosition.bottom,
                    content: NakiText(message),
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                  );
                },
              ),
            ]),
          ),
          footer: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Dim.px(16)),
              child: NakiText(
                'Built with Naki UI & Jaspr',
                style: TextStyle(
                  color: context.subtitleColor,
                  fontSize: const Dim.rem(0.85),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
