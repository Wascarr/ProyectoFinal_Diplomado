import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import '../services/notification_service.dart';

class MedicationProvider with ChangeNotifier {
  final MedicationService _medicationService = MedicationService();
  final NotificationService _notificationService;
  List<Medication> _medications = [];
  bool _isLoading = true;
  bool _isListening = false;

  MedicationProvider(this._notificationService) {
    _loadMedications();
  }

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  // Cargar medicamentos
  Future<void> _loadMedications() async {
    if (_isListening) return;

    _isLoading = true;
    notifyListeners();

    try {
      _isListening = true;
      _medicationService.getMedications().listen((medicationsList) {
        _medications = medicationsList;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print("Error al cargar medicamentos: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // Guardar un medicamento
  Future<void> saveMedication(Medication medication) async {
    try {
      await _medicationService.saveMedication(medication);
    } catch (e) {
      print("Error al guardar medicamento: $e");
      // Si hay un error, actualizar manualmente
      if (medication.id == null) {
        final newMedication = Medication(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: medication.name,
          dosage: medication.dosage,
          frequency: medication.frequency,
          doctorName: medication.doctorName,
          instructions: medication.instructions,
          startDate: medication.startDate,
          endDate: medication.endDate,
          notes: medication.notes,
          isActive: medication.isActive,
          refills: medication.refills,
          refillsLeft: medication.refillsLeft,
          reminderTimes: medication.reminderTimes,
        );
        _medications.add(newMedication);
      } else {
        final index = _medications.indexWhere((m) => m.id == medication.id);
        if (index >= 0) {
          _medications[index] = medication;
        }
      }
      notifyListeners();
    }
  }

  // Eliminar un medicamento
  Future<void> deleteMedication(String id) async {
    try {
      await _medicationService.deleteMedication(id);
    } catch (e) {
      print("Error al eliminar medicamento: $e");
      _medications.removeWhere((medication) => medication.id == id);
      notifyListeners();
    }
  }
}
