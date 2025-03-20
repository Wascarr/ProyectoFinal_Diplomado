import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medical_note.dart';

class MedicalNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de notas médicas
  CollectionReference<Map<String, dynamic>> get _notesCollection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid ?? 'anonymous')
        .collection('notes');
  }

  // Guardar una nota médica
  Future<void> saveMedicalNote(MedicalNote note) async {
    final now = DateTime.now();
    final noteData = note.toMap();

    if (note.id != null && note.id!.isNotEmpty) {
      // Actualizar nota existente
      noteData['updatedAt'] = now;
      await _notesCollection.doc(note.id).update(noteData);
    } else {
      // Crear nueva nota
      noteData['createdAt'] = now;
      noteData['updatedAt'] = now;
      DocumentReference docRef = await _notesCollection.add(noteData);
      // No es necesario actualizar el ID en el documento, lo manejaremos al recuperar
    }
  }

  // Obtener todas las notas médicas
  Stream<List<MedicalNote>> getMedicalNotes() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalNote.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Obtener notas por etiqueta
  Stream<List<MedicalNote>> getNotesByTag(String tag) {
    return _notesCollection
        .where('tags', arrayContains: tag)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalNote.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Eliminar una nota médica
  Future<void> deleteMedicalNote(String id) async {
    await _notesCollection.doc(id).delete();
  }
}
