/*import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/prescription.dart';
import '../models/note.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService({required this.uid});

  // Colecciones
  CollectionReference get _appointmentsCollection =>
      _db.collection('users').doc(uid).collection('appointments');

  CollectionReference get _prescriptionsCollection =>
      _db.collection('users').doc(uid).collection('prescriptions');

  CollectionReference get _notesCollection =>
      _db.collection('users').doc(uid).collection('notes');

  // CRUD para citas
  Stream<List<Appointment>> get appointments {
    return _appointmentsCollection.orderBy('date').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Appointment.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addAppointment(Appointment appointment) async {
    await _appointmentsCollection.add(appointment.toMap());
  }

  Future<void> updateAppointment(Appointment appointment) async {
    return await _appointmentsCollection
        .doc(appointment.id)
        .update(appointment.toMap());
  }

  Future<void> deleteAppointment(String id) async {
    return await _appointmentsCollection.doc(id).delete();
  }

  // CRUD para recetas
  Stream<List<Prescription>> get prescriptions {
    return _prescriptionsCollection
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Prescription.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addPrescription(Prescription prescription) async {
    await _prescriptionsCollection.add(prescription.toMap());
  }

  Future<void> updatePrescription(Prescription prescription) async {
    return await _prescriptionsCollection
        .doc(prescription.id)
        .update(prescription.toMap());
  }

  Future<void> deletePrescription(String id) async {
    return await _prescriptionsCollection.doc(id).delete();
  }

  // CRUD para notas médicas
  Stream<List<MedicalNote>> get notes {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicalNote.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String> addNote(MedicalNote note) async {
    DocumentReference docRef = await _notesCollection.add(note.toMap());
    return docRef.id;
  }

  Future<void> updateNote(MedicalNote note) async {
    return await _notesCollection.doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String id) async {
    return await _notesCollection.doc(id).delete();
  }

  // Obtener citas futuras para recordatorios
  Future<List<Appointment>> getFutureAppointments() async {
    final now = DateTime.now();
    final snapshot = await _appointmentsCollection
        .where('date', isGreaterThan: Timestamp.fromDate(now))
        .where('hasReminder', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
  }
}
*/
