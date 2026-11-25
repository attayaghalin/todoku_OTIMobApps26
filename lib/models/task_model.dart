enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromString(String? value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted; 

  const TaskModel ({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false, 
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel (
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Tugas Tanpa Judul',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate'] != null 
      ? DateTime.tryParse(json['dueDate'].toString())
      : null,
      priority: TaskPriority.fromString(json['priority']?.toString()),
      isCompleted: json['isCompleted'] is bool ? json['isCompleted'] as bool : false
      );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      dueDate,
      priority,
      isCompleted,
    );
  }

}