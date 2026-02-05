class Win {
  final int? id;
  final String content;
  final DateTime timestamp;
  final String type;
  final String? tag;
  final bool isFavorite;

  Win({
    this.id,
    required this.content,
    required this.timestamp,
    required this.type,
    this.tag,
    this.isFavorite = false,
  });

  // Convert a win into a Map to store in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'tag': tag,
      'isFavorite': isFavorite ? 1 : 0, // Store as integer (1 for true, 0 for false)
    };
  }

}