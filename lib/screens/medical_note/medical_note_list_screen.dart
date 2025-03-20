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
          child: ElevatedButton.icon(
            onPressed: () => _showAddNoteDialog(context, provider),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Nota Médica',
                style: TextStyle(fontSize: 16)),
          ),
        ),

        // Filtro de etiquetas (si hay etiquetas)
        if (provider.tags.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      label: const Text('Todas'),
                      selected: provider.selectedTag == null,
                      onSelected: (_) {
                        provider.filterByTag(null);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
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
                        backgroundColor: Colors.white,
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay notas médicas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.notes.length,
                      itemBuilder: (context, index) {
                        final note = provider.notes[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: note.isPinned ? Colors.amber.shade50 : null,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
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
                                        size: 16, color: Colors.grey.shade600),
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
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  onPressed: () {
                                    _showEditNoteDialog(
                                        context, provider, note);
                                  },
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
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                  ),
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
                const SizedBox(height: 8),
                const Text(
                  'Etiquetas disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
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
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                  ),
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
                const SizedBox(height: 8),
                const Text(
                  'Etiquetas disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
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
              onConfirm();
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
