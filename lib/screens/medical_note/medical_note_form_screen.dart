import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medical_note.dart';
import '../../providers/medical_note_provider.dart';

class MedicalNoteFormScreen extends StatefulWidget {
  final MedicalNote? note;

  const MedicalNoteFormScreen({Key? key, this.note}) : super(key: key);

  @override
  State<MedicalNoteFormScreen> createState() => _MedicalNoteFormScreenState();
}

class _MedicalNoteFormScreenState extends State<MedicalNoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _selectedTags = [];
  final _newTagController = TextEditingController();
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedTags.addAll(widget.note!.tags);
      _isPinned = widget.note!.isPinned;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
    _newTagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nueva Nota' : 'Editar Nota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el contenido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Destacar nota'),
                value: _isPinned,
                onChanged: (value) {
                  setState(() {
                    _isPinned = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Etiquetas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<MedicalNoteProvider>(
                builder: (context, provider, child) {
                  final tags = provider.tags;

                  return Wrap(
                    spacing: 8,
                    children: [
                      ...tags.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newTagController,
                      decoration: const InputDecoration(
                        labelText: 'Nueva etiqueta',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addTag(_newTagController.text),
                    child: const Text('Agregar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedTags.isNotEmpty) ...[
                const Text(
                  'Etiquetas seleccionadas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: _selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMedicalNote,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMedicalNote() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final note = MedicalNote(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        date: now,
        createdAt: widget.note?.createdAt ?? now,
        updatedAt: now,
        isPinned: _isPinned,
        tags: _selectedTags,
      );

      try {
        Provider.of<MedicalNoteProvider>(context, listen: false)
            .saveMedicalNote(note);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}
