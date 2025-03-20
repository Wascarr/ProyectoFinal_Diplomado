import 'package:flutter/material.dart';

class AppointmentFormScreen extends StatelessWidget {
  final dynamic appointment;

  const AppointmentFormScreen({Key? key, this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appointment == null ? 'Nueva Cita' : 'Editar Cita'),
      ),
      body: Center(
        child: Text('Formulario de Cita'),
      ),
    );
  }
}
