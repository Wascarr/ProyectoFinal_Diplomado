import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication.dart';
import 'medication_form_screen.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);

    return Column(
      children: [
        // Botón para agregar nuevo medicamento
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showAddMedicationDialog(context, provider),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Agregar Medicamento'),
          ),
        ),

        // Lista de medicamentos
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.medications.isEmpty
                  ? const Center(child: Text('No hay medicamentos registrados'))
                  : ListView.builder(
                      itemCount: provider.medications.length,
                      itemBuilder: (context, index) {
                        final medication = provider.medications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(medication.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dosis: ${medication.dosage}'),
                                Text(
                                    'Instrucciones: ${medication.instructions}'),
                                Text('Doctor: ${medication.doctorName}'),
                                if (medication.isActive)
                                  const Text('Estado: Activo',
                                      style: TextStyle(color: Colors.green))
                                else
                                  const Text('Estado: Inactivo',
                                      style: TextStyle(color: Colors.red)),
                              ],
                            ),
                            leading: const Icon(Icons.medication),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditMedicationDialog(
                                        context, provider, medication);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    if (medication.id != null) {
                                      provider.deleteMedication(medication.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              _showEditMedicationDialog(
                                  context, provider, medication);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAddMedicationDialog(
      BuildContext context, MedicationProvider provider) {
    final nameController = TextEditingController();
    final doctorNameController = TextEditingController();
    final dosageController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Medicamento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del medicamento',
                ),
              ),
              TextField(
                controller: doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del doctor',
                ),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                ),
              ),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instrucciones',
                ),
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
              if (nameController.text.isNotEmpty) {
                final medication = Medication(
                  name: nameController.text,
                  doctorName: doctorNameController.text,
                  dosage: dosageController.text,
                  frequency: instructionsController.text,
                  instructions: instructionsController.text,
                  startDate: DateTime.now(),
                  reminderTimes: [ReminderTime(hour: 8, minute: 0)],
                );

                Navigator.of(context).pop();
                provider.saveMedication(medication);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditMedicationDialog(BuildContext context,
      MedicationProvider provider, Medication medication) {
    final nameController = TextEditingController(text: medication.name);
    final doctorNameController =
        TextEditingController(text: medication.doctorName);
    final dosageController = TextEditingController(text: medication.dosage);
    final instructionsController =
        TextEditingController(text: medication.instructions);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Medicamento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del medicamento',
                ),
              ),
              TextField(
                controller: doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del doctor',
                ),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                ),
              ),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instrucciones',
                ),
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
              if (nameController.text.isNotEmpty) {
                final updatedMedication = Medication(
                  id: medication.id,
                  name: nameController.text,
                  doctorName: doctorNameController.text,
                  dosage: dosageController.text,
                  frequency: instructionsController.text,
                  instructions: instructionsController.text,
                  startDate: medication.startDate,
                  endDate: medication.endDate,
                  notes: medication.notes,
                  isActive: medication.isActive,
                  refills: medication.refills,
                  refillsLeft: medication.refillsLeft,
                  reminderTimes: medication.reminderTimes,
                );

                Navigator.of(context).pop();
                provider.saveMedication(updatedMedication);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
