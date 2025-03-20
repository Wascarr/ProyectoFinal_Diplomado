import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalNote {
  String? id;
  String title;
  String content;
  DateTime date; // Mantener este campo para compatibilidad
  DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;
  List<String> tags;

  MedicalNote({
    this.id,
    required this.title,
    required this.content,
    required this.date, // Mantener para compatibilidad
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.tags = const [],
  })  : this.createdAt = createdAt ?? date,
        this.updatedAt = updatedAt ?? date;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isPinned': isPinned,
      'tags': tags,
    };
  }

  factory MedicalNote.fromMap(Map<String, dynamic> map) {
    // Función para convertir Timestamp a DateTime
    DateTime _parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    final createdAt = map['createdAt'] != null
        ? _parseDateTime(map['createdAt'])
        : DateTime.now();
    final updatedAt =
        map['updatedAt'] != null ? _parseDateTime(map['updatedAt']) : createdAt;

    return MedicalNote(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: createdAt, // Usar createdAt como date para compatibilidad
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: map['isPinned'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}
