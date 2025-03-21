import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de citas
  CollectionReference<Map<String, dynamic>> get _appointmentsCollection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid ?? 'anonymous')
        .collection('appointments');
  }

  // Guardar una cita
  Future<void> saveAppointment(Appointment appointment) async {
    if (appointment.id != null && appointment.id!.isNotEmpty) {
      // Actualizar cita existente
      await _appointmentsCollection
          .doc(appointment.id)
          .update(appointment.toMap());
    } else {
      // Crear nueva cita
      DocumentReference docRef =
          await _appointmentsCollection.add(appointment.toMap());
      // Actualizar el ID de la cita con el ID del documento
      await docRef.update({'id': docRef.id});
    }
  }

  // Obtener todas las citas
  Stream<List<Appointment>> getAppointments() {
    return _appointmentsCollection
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Eliminar una cita
  Future<void> deleteAppointment(String id) async {
    await _appointmentsCollection.doc(id).delete();
  }
}
