import 'package:flutter/foundation.dart';
import '../models/medical_note.dart';
import '../services/medical_note_service.dart';
import '../services/tag_service.dart';

class MedicalNoteProvider with ChangeNotifier {
  final MedicalNoteService _noteService = MedicalNoteService();
  final TagService _tagService = TagService();
  List<MedicalNote> _notes = [];
  List<String> _tags = [];
  String? _selectedTag;
  bool _isLoading = true;
  bool _isListeningNotes = false;
  bool _isListeningTags = false;

  MedicalNoteProvider() {
    _loadData();
  }

  List<MedicalNote> get notes => _notes;
  List<String> get tags => _tags;
  String? get selectedTag => _selectedTag;
  bool get isLoading => _isLoading;

  // Inicializar el provider
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar notas
      if (!_isListeningNotes) {
        _isListeningNotes = true;
        _noteService.getMedicalNotes().listen((notesList) {
          _notes = notesList;
          _isLoading = false;
          notifyListeners();
        });
      }

      // Cargar etiquetas
      if (!_isListeningTags) {
        _isListeningTags = true;
        _tagService.getTags().listen((tagsList) {
          _tags = tagsList;
          notifyListeners();
        });
      }
    } catch (e) {
      print("Error al cargar datos: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrar notas por etiqueta
  void filterByTag(String? tag) {
    _selectedTag = tag;
    _isLoading = true;
    notifyListeners();

    try {
      _isListeningNotes = false;

      if (tag == null) {
        _isListeningNotes = true;
        _noteService.getMedicalNotes().listen((notesList) {
          _notes = notesList;
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _isListeningNotes = true;
        _noteService.getNotesByTag(tag).listen((notesList) {
          _notes = notesList;
          _isLoading = false;
          notifyListeners();
        });
      }
    } catch (e) {
      print("Error al filtrar por etiqueta: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar una nota
  Future<void> saveMedicalNote(MedicalNote note) async {
    try {
      await _noteService.saveMedicalNote(note);

      // Guardar nuevas etiquetas si existen
      for (var tag in note.tags) {
        if (!_tags.contains(tag)) {
          await _tagService.saveTag(tag);
        }
      }
    } catch (e) {
      print("Error al guardar nota: $e");
      // Si hay un error, actualizar manualmente
      if (note.id == null) {
        final now = DateTime.now();
        final newNote = MedicalNote(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: note.title,
          content: note.content,
          date: now,
          createdAt: now,
          updatedAt: now,
          isPinned: note.isPinned,
          tags: note.tags,
        );
        _notes.add(newNote);
      } else {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index >= 0) {
          _notes[index] = note;
        }
      }
      notifyListeners();
    }
  }

  // Eliminar una nota
  Future<void> deleteMedicalNote(String id) async {
    try {
      await _noteService.deleteMedicalNote(id);
    } catch (e) {
      print("Error al eliminar nota: $e");
      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    }
  }

  // Agregar una nueva etiqueta
  Future<void> addTag(String tag) async {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      try {
        await _tagService.saveTag(tag);
      } catch (e) {
        print("Error al agregar etiqueta: $e");
        _tags.add(tag);
        notifyListeners();
      }
    }
  }

  // Eliminar una etiqueta
  Future<void> deleteTag(String tag) async {
    try {
      await _tagService.deleteTag(tag);
    } catch (e) {
      print("Error al eliminar etiqueta: $e");
      _tags.remove(tag);
      notifyListeners();
    }
  }
}
