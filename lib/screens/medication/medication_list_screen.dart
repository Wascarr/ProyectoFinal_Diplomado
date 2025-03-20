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
          child: ElevatedButton.icon(
            onPressed: () => _showAddMedicationDialog(context, provider),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Medicamento',
                style: TextStyle(fontSize: 16)),
          ),
        ),

        // Lista de medicamentos
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.medications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay medicamentos registrados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.medications.length,
                      itemBuilder: (context, index) {
                        final medication = provider.medications[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(
                              medication.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.medical_services,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dosis: ${medication.dosage}',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Instrucciones: ${medication.instructions}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 16, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text('Doctor: ${medication.doctorName}'),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                medication.isActive
                                    ? Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              size: 16, color: Colors.green),
                                          const SizedBox(width: 4),
                                          const Text('Estado: Activo',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          const Icon(Icons.cancel,
                                              size: 16, color: Colors.red),
                                          const SizedBox(width: 4),
                                          const Text('Estado: Inactivo',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                              ],
                            ),
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.medication,
                                color: Theme.of(context).colorScheme.primary,
                              ),
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
                                    _showEditMedicationDialog(
                                        context, provider, medication);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red.shade300),
                                  onPressed: () {
                                    if (medication.id != null) {
                                      _showDeleteConfirmationDialog(
                                        context,
                                        'Eliminar medicamento',
                                        '¿Estás seguro de que deseas eliminar este medicamento?',
                                        () => provider
                                            .deleteMedication(medication.id!),
                                      );
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
              const SizedBox(height: 12),
              TextField(
                controller: doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del doctor',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextField(
                controller: doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del doctor',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosis',
                ),
              ),
              const SizedBox(height: 12),
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
