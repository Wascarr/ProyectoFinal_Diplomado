import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  // Agregar un flag para evitar duplicados
  bool _isListening = false;

  AppointmentProvider() {
    _loadAppointments();
  }

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  // Cargar citas
  Future<void> _loadAppointments() async {
    if (_isListening) return; // Evitar múltiples listeners

    _isLoading = true;
    notifyListeners();

    try {
      _isListening = true;
      _appointmentService.getAppointments().listen((appointmentsList) {
        _appointments = appointmentsList;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print("Error al cargar citas: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar una cita
  Future<void> saveAppointment(Appointment appointment) async {
    try {
      // No actualizar la lista local aquí, dejar que el listener lo haga
      await _appointmentService.saveAppointment(appointment);
    } catch (e) {
      print("Error al guardar cita: $e");
      // Si hay un error, podemos actualizar manualmente
      if (appointment.id == null) {
        final newAppointment = Appointment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: appointment.title,
          date: appointment.date,
          description: appointment.description,
          isCompleted: appointment.isCompleted,
        );
        _appointments.add(newAppointment);
      } else {
        final index = _appointments.indexWhere((a) => a.id == appointment.id);
        if (index >= 0) {
          _appointments[index] = appointment;
        }
      }
      notifyListeners();
    }
  }

  // Eliminar una cita
  Future<void> deleteAppointment(String id) async {
    try {
      // No actualizar la lista local aquí, dejar que el listener lo haga
      await _appointmentService.deleteAppointment(id);
    } catch (e) {
      print("Error al eliminar cita: $e");
      // Si hay un error, podemos actualizar manualmente
      _appointments.removeWhere((appointment) => appointment.id == id);
      notifyListeners();
    }
  }
}
