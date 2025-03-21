import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TagService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Referencia a la colección de etiquetas
  CollectionReference<Map<String, dynamic>> get _tagsCollection {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid ?? 'anonymous')
        .collection('tags');
  }

  // Guardar una etiqueta
  Future<void> saveTag(String tag) async {
    await _tagsCollection.doc(tag).set({'name': tag});
  }

  // Obtener todas las etiquetas
  Stream<List<String>> getTags() {
    return _tagsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()['name'] as String).toList());
  }

  // Eliminar una etiqueta
  Future<void> deleteTag(String tag) async {
    await _tagsCollection.doc(tag).delete();
  }
}
