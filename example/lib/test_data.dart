class Tag {
  int id;
  String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Todo {
  String id;
  String title;
  String description;
  bool completed;
  Tag tag;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.tag,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      tag: Tag.fromJson(json['tag']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'tag': tag.toJson(),
    };
  }
}

final List<Todo> todos = [
  Todo(
    id: "1",
    title: "Reading book",
    description: "Reading a book/week",
    completed: true,
    tag: Tag(id: 1, name: "Work"),
  ),
  Todo(
    id: "2",
    title: "Running",
    description: "Running 3km/day",
    completed: false,
    tag: Tag(id: 2, name: "Sport"),
  ),
  Todo(
    id: "3",
    title: "Swimming",
    description: "Swimming 1km/day",
    completed: false,
    tag: Tag(id: 2, name: "Sport"),
  ),
  Todo(
    id: "4",
    title: "Coding",
    description: "Coding 1h/day",
    completed: false,
    tag: Tag(id: 1, name: "Work"),
  ),
  Todo(
    id: "5",
    title: "Gym",
    description: "Gym 1h/day",
    completed: false,
    tag: Tag(id: 2, name: "Sport"),
  ),
];
