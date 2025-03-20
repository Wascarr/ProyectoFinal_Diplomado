import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/medical_note_provider.dart';
import '../../models/medical_note.dart';
import 'medical_note_form_screen.dart';

class MedicalNoteListScreen extends StatelessWidget {
  const MedicalNoteListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicalNoteProvider>(context);

    return Column(
      children: [
        // Botón para agregar nueva nota
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showAddNoteDialog(context, provider),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Agregar Nota Médica'),
          ),
        ),

        // Filtro de etiquetas (si hay etiquetas)
        if (provider.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: const Text('Todas'),
                      selected: provider.selectedTag == null,
                      onSelected: (_) {
                        provider.filterByTag(null);
                      },
                    ),
                  ),
                  ...provider.tags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text(tag),
                        selected: provider.selectedTag == tag,
                        onSelected: (_) {
                          provider.filterByTag(tag);
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

        // Lista de notas
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.notes.isEmpty
                  ? const Center(child: Text('No hay notas médicas'))
                  : ListView.builder(
                      itemCount: provider.notes.length,
                      itemBuilder: (context, index) {
                        final note = provider.notes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          color: note.isPinned ? Colors.amber.shade100 : null,
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(child: Text(note.title)),
                                if (note.isPinned)
                                  const Icon(Icons.push_pin,
                                      size: 16, color: Colors.amber),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
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
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditNoteDialog(
                                        context, provider, note);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    if (note.id != null) {
                                      provider.deleteMedicalNote(note.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              _showEditNoteDialog(context, provider, note);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAddNoteDialog(BuildContext context, MedicalNoteProvider provider) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final List<String> selectedTags = [];
    bool isPinned = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Nueva Nota Médica'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                  ),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                  ),
                  maxLines: 3,
                ),
                SwitchListTile(
                  title: const Text('Destacar nota'),
                  value: isPinned,
                  onChanged: (value) {
                    setState(() {
                      isPinned = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text('Etiquetas disponibles:'),
                Wrap(
                  spacing: 8,
                  children: provider.tags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
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
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final now = DateTime.now();
                  final note = MedicalNote(
                    title: titleController.text,
                    content: contentController.text,
                    date: now,
                    createdAt: now,
                    updatedAt: now,
                    isPinned: isPinned,
                    tags: selectedTags,
                  );

                  Navigator.of(context).pop();
                  provider.saveMedicalNote(note);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      }),
    );
  }

  void _showEditNoteDialog(
      BuildContext context, MedicalNoteProvider provider, MedicalNote note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    final List<String> selectedTags = List.from(note.tags);
    bool isPinned = note.isPinned;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Editar Nota Médica'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                  ),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                  ),
                  maxLines: 3,
                ),
                SwitchListTile(
                  title: const Text('Destacar nota'),
                  value: isPinned,
                  onChanged: (value) {
                    setState(() {
                      isPinned = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text('Etiquetas disponibles:'),
                Wrap(
                  spacing: 8,
                  children: provider.tags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
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
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final updatedNote = MedicalNote(
                    id: note.id,
                    title: titleController.text,
                    content: contentController.text,
                    date: note.date,
                    createdAt: note.createdAt,
                    updatedAt: DateTime.now(),
                    isPinned: isPinned,
                    tags: selectedTags,
                  );

                  Navigator.of(context).pop();
                  provider.saveMedicalNote(updatedNote);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      }),
    );
  }
}
