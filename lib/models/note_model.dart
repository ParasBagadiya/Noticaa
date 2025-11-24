class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isFavorite; // Add this field
  final String categoryId;
  final String formatType;
  final String folderId;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFavorite = false, // Add default value
    this.categoryId = 'default',
    this.formatType = 'plain',
    this.folderId = 'inbox',
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isFavorite, // Add this
    String? categoryId,
    String? formatType,
    String? folderId,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite, // Add this
      categoryId: categoryId ?? this.categoryId,
      formatType: formatType ?? this.formatType,
      folderId: folderId ?? this.folderId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isPinned': isPinned,
      'isFavorite': isFavorite, // Add to map
      'categoryId': categoryId,
      'formatType': formatType,
      'folderId': folderId,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isPinned: map['isPinned'] ?? false,
      isFavorite: map['isFavorite'] ?? false, // Load from map
      categoryId: map['categoryId'] ?? 'default',
      formatType: map['formatType'] ?? 'plain',
      folderId: map['folderId'] ?? 'inbox',
    );
  }
}