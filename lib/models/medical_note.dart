import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalNote {
  String? id;
  String title;
  String content;
  DateTime date; 
  DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;
  List<String> tags;
  List<String> imagePaths;
  String? audioPath;

  MedicalNote({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.tags = const [],
    this.imagePaths = const [],
    this.audioPath,
  })  : this.createdAt = createdAt ?? date,
        this.updatedAt = updatedAt ?? date;

  /// Serialización a Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
      'tags': tags,
      'imagePaths': imagePaths,
      'audioPath': audioPath,
    };
  }

  /// Deserialización desde Firestore
  factory MedicalNote.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime _parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        return DateTime.now();
      }
    }

    return MedicalNote(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: _parseDateTime(map['date']),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      isPinned: map['isPinned'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
      audioPath: map['audioPath'],
    );
  }
}
