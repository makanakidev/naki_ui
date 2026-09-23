import 'dart:convert';
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/theme.dart';
import 'package:universal_web/web.dart';

import '../models/todo_item.dart';

class TodoStorage {
  static const String _storageKey = 'naki_ui_todos';

  static List<TodoItem> get defaultTodos => [
    TodoItem(
      id: '1',
      title: 'Explore Naki UI design tokens',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 540000,
    ),
    TodoItem(
      id: '2',
      title: 'Try out light and dark theme mode toggle',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 480000,
    ),
    TodoItem(
      id: '3',
      title: 'Build something minimalist and beautiful',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 420000,
    ),
    TodoItem(
      id: '4',
      title: 'Test responsive layouts on mobile and desktop',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 360000,
    ),
    TodoItem(
      id: '5',
      title: 'Customize theme color schemes and seed palette',
      isCompleted: true,
      createdAt: DateTime.now().millisecondsSinceEpoch - 300000,
    ),
    TodoItem(
      id: '6',
      title: 'Try out scroll physics toggle',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 240000,
    ),
    TodoItem(
      id: '7',
      title: 'Add priority badges and category tags',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 180000,
    ),
    TodoItem(
      id: '8',
      title: 'Review keyboard navigation and accessibility',
      isCompleted: true,
      createdAt: DateTime.now().millisecondsSinceEpoch - 120000,
    ),
    TodoItem(
      id: '9',
      title: 'Export completed tasks to JSON summary',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 60000,
    ),
    TodoItem(
      id: '10',
      title: 'Share feedback and star the repository',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ),
  ];

  static List<TodoItem> load() {
    if (!kIsWeb) return defaultTodos;

    try {
      final data = window.localStorage.getItem(_storageKey);
      if (data.isNullOrEmpty) return defaultTodos;

      final decoded = jsonDecode(data!);
      if (decoded is Iterable) {
        return decoded
            .map(
              (item) => TodoItem.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      }
    } catch (_) {
      // Fallback on any parse error
    }

    return defaultTodos;
  }

  static void save(List<TodoItem> todos) {
    if (!kIsWeb) return;

    try {
      final encoded = jsonEncode(todos.map((t) => t.toJson()).toList());
      window.localStorage.setItem(_storageKey, encoded == '[]' ? '' : encoded);
    } catch (_) {
      // Ignore storage quota or access errors
    }
  }
}
