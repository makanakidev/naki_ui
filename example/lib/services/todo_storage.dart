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
      isCompleted: true,
      createdAt: DateTime.now().millisecondsSinceEpoch - 120000,
    ),
    TodoItem(
      id: '2',
      title: 'Try out light and dark theme mode toggle',
      isCompleted: false,
      createdAt: DateTime.now().millisecondsSinceEpoch - 60000,
    ),
    TodoItem(
      id: '3',
      title: 'Build something minimalist and beautiful',
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
      window.localStorage.setItem(_storageKey, encoded);
    } catch (_) {
      // Ignore storage quota or access errors
    }
  }
}
