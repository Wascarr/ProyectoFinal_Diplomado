import 'package:flutter/material.dart';
import '../services/appointment_service.dart';
import '../services/medication_service.dart';
import '../services/medical_note_service.dart';
import '../services/tag_service.dart';
import '../services/migration_service.dart';
import 'appointment/appointment_list_screen.dart';
import 'medication/medication_list_screen.dart';
import 'medical_note/medical_note_list_screen.dart';
// Importaciones para los formulario
import './appointment/appointment_form_screen.dart';
import './medication/medication_form_screen.dart';
import './medical_note/medical_note_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isMigrating = false;

  final List<Widget> _screens = [
    const AppointmentListScreen(),
    const MedicationListScreen(),
    const MedicalNoteListScreen(),
  ];

  final List<String> _titles = [
    'Citas Médicas',
    'Medicamentos',
    'Notas Médicas',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex ==
              2) // Solo mostrar en la pantalla de notas médicas
            IconButton(
              icon: const Icon(Icons.label),
              onPressed: () {
                // Aquí iría la lógica para gestionar etiquetas
                _showTagsDialog(context);
              },
            ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed:
                _isMigrating ? null : () => _showMigrationDialog(context),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notas',
          ),
        ],
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Enfoque simplificado
          Widget formScreen;

          switch (_selectedIndex) {
            case 0:
              formScreen = const AppointmentFormScreen();
              break;
            case 1:
              formScreen = const MedicationFormScreen();
              break;
            case 2:
              formScreen = const MedicalNoteFormScreen();
              break;
            default:
              formScreen = const AppointmentFormScreen();
          }

          // Usar pushReplacement en lugar de push
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => formScreen),
          );
        },
        child: const Icon(Icons.add),
      ),*/
    );
  }

  Future<void> _showMigrationDialog(BuildContext context) async {
    final shouldMigrate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Migrar datos'),
            content: const Text(
              '¿Deseas migrar tus datos locales a la nube? Esto permitirá acceder a tus datos desde cualquier dispositivo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Migrar'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldMigrate) {
      setState(() {
        _isMigrating = true;
      });

      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Migrando datos...'),
            ],
          ),
        ),
      );

      try {
        // Realizar la migración
        final migrationService = MigrationService(
          AppointmentService(),
          MedicationService(),
          MedicalNoteService(),
          TagService(),
        );

        await migrationService.migrateDataToFirebase();

        // Cerrar el diálogo de progreso
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Datos migrados correctamente')),
          );
        }
      } catch (e) {
        // Cerrar el diálogo de progreso
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Mostrar mensaje de error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al migrar datos: ${e.toString()}')),
          );
        }
      } finally {
        setState(() {
          _isMigrating = false;
        });
      }
    }
  }

  void _showTagsDialog(BuildContext context) {
    // Aquí iría la implementación del diálogo para gestionar etiquetas
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionar Etiquetas'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<String>>(
            stream: TagService().getTags(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tags = snapshot.data ?? [];

              if (tags.isEmpty) {
                return const Center(child: Text('No hay etiquetas'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(tags[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        TagService().deleteTag(tags[index]);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              // Mostrar diálogo para agregar nueva etiqueta
              _showAddTagDialog(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Etiqueta'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la etiqueta',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                TagService().saveTag(textController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// Estas clases son referencias a las pantallas de formulario
// que deberían estar definidas en sus respectivos archivos
class AppointmentFormScreen extends StatelessWidget {
  const AppointmentFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Cita')),
      body: const Center(child: Text('Formulario de Cita')),
    );
  }
}

class MedicationFormScreen extends StatelessWidget {
  const MedicationFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Medicamento')),
      body: const Center(child: Text('Formulario de Medicamento')),
    );
  }
}

class MedicalNoteFormScreen extends StatelessWidget {
  const MedicalNoteFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Nota')),
      body: const Center(child: Text('Formulario de Nota Médica')),
    );
  }
}
