import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de medicamentos
  CollectionReference<Map<String, dynamic>> get _medicationsCollection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid ?? 'anonymous')
        .collection('prescriptions');
  }

  // Guardar un medicamento
  Future<void> saveMedication(Medication medication) async {
    if (medication.id != null && medication.id!.isNotEmpty) {
      // Actualizar medicamento existente
      await _medicationsCollection
          .doc(medication.id)
          .update(medication.toMap());
    } else {
      // Crear nuevo medicamento
      DocumentReference docRef =
          await _medicationsCollection.add(medication.toMap());
      // No es necesario actualizar el ID en el documento, lo manejaremos al recuperar
    }
  }

  // Obtener todos los medicamentos
  Stream<List<Medication>> getMedications() {
    return _medicationsCollection
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Eliminar un medicamento
  Future<void> deleteMedication(String id) async {
    await _medicationsCollection.doc(id).delete();
  }
}
