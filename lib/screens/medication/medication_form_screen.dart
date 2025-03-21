import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/medication.dart';
import '../../providers/medication_provider.dart';

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;

  const MedicationFormScreen({Key? key, this.medication}) : super(key: key);

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();
  final _refillsController = TextEditingController();
  final _refillsLeftController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<ReminderTime> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _frequencyController.text = widget.medication!.frequency;
      _doctorNameController.text = widget.medication!.doctorName;
      _instructionsController.text = widget.medication!.instructions;
      _notesController.text = widget.medication!.notes;
      _refillsController.text = widget.medication!.refills.toString();
      _refillsLeftController.text = widget.medication!.refillsLeft.toString();
      _startDate = widget.medication!.startDate;
      _endDate = widget.medication!.endDate;
      _reminderTimes.addAll(widget.medication!.reminderTimes);
    } else {
      // Valores por defecto para un nuevo medicamento
      _reminderTimes.add(ReminderTime(hour: 8, minute: 0));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _doctorNameController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    _refillsController.dispose();
    _refillsLeftController.dispose();
    super.dispose();
  }

  // Resto del código del formulario...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication == null
            ? 'Nuevo Medicamento'
            : 'Editar Medicamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del medicamento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del doctor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la dosis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instrucciones',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Tomar 1 cada 8 horas',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Cada 8 horas, Diario, etc.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la frecuencia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _refillsController,
                      decoration: const InputDecoration(
                        labelText: 'Recargas totales',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _refillsLeftController,
                      decoration: const InputDecoration(
                        labelText: 'Recargas restantes',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              // Resto del formulario...
            ],
          ),
        ),
      ),
    );
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final medication = Medication(
        id: widget.medication?.id,
        name: _nameController.text,
        doctorName: _doctorNameController.text,
        dosage: _dosageController.text,
        frequency: _frequencyController.text,
        instructions: _instructionsController.text,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text,
        isActive: true,
        refills: int.tryParse(_refillsController.text) ?? 0,
        refillsLeft: int.tryParse(_refillsLeftController.text) ?? 0,
        reminderTimes: _reminderTimes,
      );

      try {
        Provider.of<MedicationProvider>(context, listen: false)
            .saveMedication(medication);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}
