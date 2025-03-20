import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  String? id;
  String name; // Mantener este campo para compatibilidad
  String dosage;
  String frequency; // Mantener este campo para compatibilidad
  String doctorName;
  String instructions;
  DateTime startDate;
  DateTime? endDate;
  String notes;
  bool isActive;
  int refills;
  int refillsLeft;
  List<ReminderTime> reminderTimes;

  Medication({
    this.id,
    required this.name, // Mantener para compatibilidad
    required this.dosage,
    required this.frequency, // Mantener para compatibilidad
    this.doctorName = '',
    this.instructions = '',
    required this.startDate,
    this.endDate,
    this.notes = '',
    this.isActive = true,
    this.refills = 0,
    this.refillsLeft = 0,
    required this.reminderTimes,
  });

  // Método para convertir ReminderTime a DateTime
  List<DateTime> get reminderDateTimes {
    final now = DateTime.now();
    return reminderTimes
        .map((time) =>
            DateTime(now.year, now.month, now.day, time.hour, time.minute))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationName': name, // Mapear name a medicationName
      'doctorName': doctorName,
      'dosage': dosage,
      'instructions': instructions,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
      'isActive': isActive,
      'refills': refills,
      'refillsLeft': refillsLeft,
      'reminderTimes': reminderTimes.map((time) => time.toMap()).toList(),
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    // Función para convertir Timestamp a DateTime
    DateTime _parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    // Convertir lista de reminderTimes
    List<ReminderTime> _parseReminderTimes(List<dynamic>? times) {
      if (times == null || times.isEmpty) {
        return [ReminderTime(hour: 8, minute: 0)]; // Valor por defecto
      }
      return times.map((time) {
        if (time is Map<String, dynamic>) {
          return ReminderTime.fromMap(time);
        }
        return ReminderTime(hour: 8, minute: 0);
      }).toList();
    }

    return Medication(
      id: map['id'],
      name: map['medicationName'] ?? '', // Mapear medicationName a name
      doctorName: map['doctorName'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['instructions'] ?? '', // Mapear instructions a frequency
      instructions: map['instructions'] ?? '',
      startDate: map['startDate'] != null
          ? _parseDateTime(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null ? _parseDateTime(map['endDate']) : null,
      notes: map['notes'] ?? '',
      isActive: map['isActive'] ?? true,
      refills: map['refills'] ?? 0,
      refillsLeft: map['refillsLeft'] ?? 0,
      reminderTimes:
          _parseReminderTimes(map['reminderTimes'] as List<dynamic>?),
    );
  }
}

class ReminderTime {
  final int hour;
  final int minute;

  ReminderTime({
    required this.hour,
    required this.minute,
  });

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  factory ReminderTime.fromMap(Map<String, dynamic> map) {
    return ReminderTime(
      hour: map['hour'] ?? 0,
      minute: map['minute'] ?? 0,
    );
  }

  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
