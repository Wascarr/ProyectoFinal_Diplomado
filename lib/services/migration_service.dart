import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'appointment_service.dart';
import 'medication_service.dart';
import 'medical_note_service.dart';
import 'tag_service.dart';
import '../models/appointment.dart';
import '../models/medication.dart';
import '../models/medical_note.dart';

class MigrationService {
  final AppointmentService _appointmentService;
  final MedicationService _medicationService;
  final MedicalNoteService _medicalNoteService;
  final TagService _tagService;

  MigrationService(
    this._appointmentService,
    this._medicationService,
    this._medicalNoteService,
    this._tagService,
  );

  Future<void> migrateDataToFirebase() async {
    final prefs = await SharedPreferences.getInstance();

    // Migrar citas
    final appointmentsJson = prefs.getStringList('appointments') ?? [];
    for (String json in appointmentsJson) {
      final appointment = Appointment.fromMap(jsonDecode(json));
      await _appointmentService.saveAppointment(appointment);
    }

    // Migrar medicamentos
    final medicationsJson = prefs.getStringList('medications') ?? [];
    for (String json in medicationsJson) {
      final medication = Medication.fromMap(jsonDecode(json));
      await _medicationService.saveMedication(medication);
    }

    // Migrar notas médicas
    final notesJson = prefs.getStringList('medicalNotes') ?? [];
    for (String json in notesJson) {
      final note = MedicalNote.fromMap(jsonDecode(json),'');
      await _medicalNoteService.saveMedicalNote(note);
    }

    // Migrar etiquetas
    final tags = prefs.getStringList('tags') ?? [];
    for (String tag in tags) {
      await _tagService.saveTag(tag);
    }

    // Opcional: marcar que la migración se ha completado
    await prefs.setBool('migrationCompleted', true);
  }
}
