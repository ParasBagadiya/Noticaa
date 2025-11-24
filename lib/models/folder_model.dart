import 'package:flutter/material.dart';

class Folder {
  final String id;
  final String name;
  final String? parentId;
  final Color color;
  final DateTime createdAt;
  int noteCount;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.color,
    required this.createdAt,
    this.noteCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'color': color.toARGB32(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'noteCount': noteCount,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      parentId: map['parentId'],
      color: Color(map['color']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      noteCount: map['noteCount'] ?? 0,
    );
  }

  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    Color? color,
    DateTime? createdAt,
    int? noteCount,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      noteCount: noteCount ?? this.noteCount,
    );
  }
}
