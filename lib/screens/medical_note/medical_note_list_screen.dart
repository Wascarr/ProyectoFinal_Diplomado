import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path_lib;
import '../../providers/medical_note_provider.dart';
import '../../models/medical_note.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalNoteListScreen extends StatefulWidget {
  const MedicalNoteListScreen({Key? key}) : super(key: key);

  @override
  State<MedicalNoteListScreen> createState() => _MedicalNoteListScreenState();
}

class _MedicalNoteListScreenState extends State<MedicalNoteListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicalNoteProvider>(context);
    final filteredNotes = provider.notes.where((note) {
      final lowerQuery = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar notas...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddNoteDialog(context, provider),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label:
                const Text('Agregar Nota Médica', style: TextStyle(fontSize: 16)),
          ),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredNotes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note,
                              size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('No hay notas médicas',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: note.isPinned ? Colors.amber.shade50 : null,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(note.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                if (note.isPinned)
                                  const Icon(Icons.push_pin,
                                      size: 16, color: Colors.amber),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 16,
                                        color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(note.date),
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (note.tags.isNotEmpty)
                                  Wrap(
                                    spacing: 4,
                                    children: note.tags.map((tag) {
                                      return Chip(
                                        label: Text(tag),
                                        labelStyle:
                                            const TextStyle(fontSize: 10),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: -2),
                                      );
                                    }).toList(),
                                  ),
                                if (note.imagePaths != null &&
                                    note.imagePaths!.isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: note.imagePaths!.map((url) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Image.network(
                                            url,
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                if (note.audioPath != null)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow),
                                        onPressed: () async {
                                          final player = FlutterSoundPlayer();
                                          await player.openPlayer();
                                          await player.startPlayer(
                                              fromURI: note.audioPath);
                                        },
                                      ),
                                      const Text('Escuchar nota de voz'),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share,
                                      color: Colors.green),
                                  onPressed: () {
                                    final textToShare =
                                        '${note.title}\n\n${note.content}';
                                    Share.share(textToShare);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red.shade300),
                                  onPressed: () {
                                    if (note.id != null) {
                                      _showDeleteConfirmationDialog(
                                        context,
                                        'Eliminar nota',
                                        '¿Estás seguro de que deseas eliminar esta nota?',
                                        () => provider
                                            .deleteMedicalNote(note.id!),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAddNoteDialog(
      BuildContext context, MedicalNoteProvider provider) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final List<String> selectedTags = [];
    List<XFile> selectedImages = [];
    bool isPinned = false;
    String? localAudioPath;
    final recorder = FlutterSoundRecorder();
    bool isRecording = false;

    await recorder.openRecorder();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        Future<void> pickImages() async {
          final picker = ImagePicker();
          final images = await picker.pickMultiImage();
          if (images.isNotEmpty) {
            setState(() {
              selectedImages = images;
            });
          }
        }

        Future<void> toggleRecording() async {
          if (!isRecording) {
            final path = '${Directory.systemTemp.path}/note_audio.aac';
            await recorder.startRecorder(toFile: path);
            setState(() {
              isRecording = true;
              localAudioPath = path;
            });
          } else {
            await recorder.stopRecorder();
            setState(() {
              isRecording = false;
            });
          }
        }

        Future<String> uploadFile(File file, String path) async {
          final ref = FirebaseStorage.instance.ref().child(path);
          await ref.putFile(file);
          return await ref.getDownloadURL();
        }

        return AlertDialog(
          title: const Text('Nueva Nota Médica'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Destacar nota'),
                  value: isPinned,
                  onChanged: (value) {
                    setState(() {
                      isPinned = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                ElevatedButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Adjuntar imágenes'),
                ),
                if (selectedImages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: selectedImages
                        .map((img) => Image.file(
                              File(img.path),
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: toggleRecording,
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(isRecording
                      ? 'Detener grabación'
                      : 'Agregar nota de voz'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  List<String> imageUrls = [];
                  String? audioUrl;

                  for (var img in selectedImages) {
                    final file = File(img.path);
                    final filename = path_lib.basename(img.path);
                    final url = await uploadFile(
                        file, 'users/${user!.uid}/notes/images/$filename');
                    imageUrls.add(url);
                  }

                  if (localAudioPath != null) {
                    final file = File(localAudioPath!);
                    final filename = path_lib.basename(localAudioPath!);
                    audioUrl = await uploadFile(
                        file, 'users/${user!.uid}/notes/audio/$filename');
                  }

                  final newNote = MedicalNote(
                    title: titleController.text,
                    content: contentController.text,
                    date: DateTime.now(),
                    isPinned: isPinned,
                    tags: selectedTags,
                    imagePaths: imageUrls,
                    audioPath: audioUrl,
                  );

                  await provider.saveMedicalNote(newNote);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String title,
      String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}