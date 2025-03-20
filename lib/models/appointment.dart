import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String? id;
  String title;
  DateTime date;
  String description;
  bool isCompleted;

  Appointment({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date, // Firestore convertirá esto a Timestamp
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    // Manejar diferentes tipos de datos para la fecha
    DateTime dateTime;
    final dateValue = map['date'];

    if (dateValue is Timestamp) {
      dateTime = dateValue.toDate();
    } else if (dateValue is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      dateTime = DateTime.now();
    }

    return Appointment(
      id: map['id'],
      title: map['title'] ?? '',
      date: dateTime,
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
