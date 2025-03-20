import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import 'appointment_form_screen.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);

    return Column(
      children: [
        // Botón para agregar nueva cita
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showAddAppointmentDialog(context, provider),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Agregar Cita'),
          ),
        ),

        // Lista de citas
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.appointments.isEmpty
                  ? const Center(child: Text('No hay citas programadas'))
                  : ListView.builder(
                      itemCount: provider.appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = provider.appointments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              appointment.title,
                              style: TextStyle(
                                decoration: appointment.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.date)}'),
                                Text(appointment.description),
                              ],
                            ),
                            leading: Checkbox(
                              value: appointment.isCompleted,
                              onChanged: (value) {
                                if (value != null) {
                                  final updatedAppointment = Appointment(
                                    id: appointment.id,
                                    title: appointment.title,
                                    date: appointment.date,
                                    description: appointment.description,
                                    isCompleted: value,
                                  );
                                  provider.saveAppointment(updatedAppointment);
                                }
                              },
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditAppointmentDialog(
                                        context, provider, appointment);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    if (appointment.id != null) {
                                      provider
                                          .deleteAppointment(appointment.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              _showEditAppointmentDialog(
                                  context, provider, appointment);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAddAppointmentDialog(
      BuildContext context, AppointmentProvider provider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isCompleted = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nueva Cita'),
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
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Fecha y hora'),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Completada'),
                    value: isCompleted,
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                      });
                    },
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
                    final appointment = Appointment(
                      title: titleController.text,
                      date: selectedDate,
                      description: descriptionController.text,
                      isCompleted: isCompleted,
                    );

                    Navigator.of(context).pop();
                    provider.saveAppointment(appointment);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditAppointmentDialog(BuildContext context,
      AppointmentProvider provider, Appointment appointment) {
    final titleController = TextEditingController(text: appointment.title);
    final descriptionController =
        TextEditingController(text: appointment.description);
    DateTime selectedDate = appointment.date;
    bool isCompleted = appointment.isCompleted;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar Cita'),
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
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Fecha y hora'),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Completada'),
                    value: isCompleted,
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                      });
                    },
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
                    final updatedAppointment = Appointment(
                      id: appointment.id,
                      title: titleController.text,
                      date: selectedDate,
                      description: descriptionController.text,
                      isCompleted: isCompleted,
                    );

                    Navigator.of(context).pop();
                    provider.saveAppointment(updatedAppointment);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
