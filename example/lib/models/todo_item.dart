enum TodoFilter {
  all('All'),
  active('Active'),
  completed('Completed');

  const TodoFilter(this.label);
  final String label;
}

class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;
  final int createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  TodoItem copyWith({String? title, bool? isCompleted}) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }
}
