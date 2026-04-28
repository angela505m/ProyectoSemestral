import 'package:flutter/material.dart';
import '../model/recordatorio.dart';
import '../viewmodel/recordatorioviewmodel.dart';

class EditarRecordatorioView extends StatefulWidget {
  final int idMascota;
  final Recordatorio recordatorio;
  final RecordatorioViewModel viewModel;

  const EditarRecordatorioView({
    super.key,
    required this.idMascota,
    required this.recordatorio,
    required this.viewModel,
  });

  @override
  State<EditarRecordatorioView> createState() => _EditarRecordatorioViewState();
}

class _EditarRecordatorioViewState extends State<EditarRecordatorioView> {
  late String _selectedTipo;
  late TimeOfDay _selectedHora;
  late String _selectedDias;

  @override
  void initState() {
    super.initState();
    _selectedTipo = widget.recordatorio.tipo;
    final horaParts = widget.recordatorio.hora.split(':');
    _selectedHora = TimeOfDay(
      hour: int.parse(horaParts[0]),
      minute: int.parse(horaParts[1]),
    );
    _selectedDias = widget.recordatorio.dias;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SizedBox(
        width: 400,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Editar recordatorio",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF96C9F2),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedTipo,
                decoration: const InputDecoration(
                  labelText: "Tipo",
                  labelStyle: TextStyle(color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF96C9F2)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'comida', child: Text('Comida')),
                  DropdownMenuItem(value: 'paseo', child: Text('Paseo')),
                  DropdownMenuItem(
                      value: 'medicamento', child: Text('Medicamento')),
                ],
                onChanged: (v) => setState(() => _selectedTipo = v!),
              ),
              const SizedBox(height: 15),
              ListTile(
                title: const Text("Hora"),
                subtitle: Text(_selectedHora.format(context)),
                trailing:
                    const Icon(Icons.access_time, color: Color(0xFF96C9F2)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedHora,
                  );
                  if (picked != null) {
                    setState(() => _selectedHora = picked);
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedDias,
                decoration: const InputDecoration(
                  labelText: "Días",
                  labelStyle: TextStyle(color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF96C9F2)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Lunes,Martes,Miércoles,Jueves,Viernes',
                    child: Text('Lun a Vie'),
                  ),
                  DropdownMenuItem(
                    value:
                        'Lunes,Martes,Miércoles,Jueves,Viernes,Sábado,Domingo',
                    child: Text('Todos los días'),
                  ),
                  DropdownMenuItem(
                    value: 'Sábado,Domingo',
                    child: Text('Solo fines de semana'),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedDias = v!),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar",
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7E3F6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      final novaHora =
                          '${_selectedHora.hour.toString().padLeft(2, '0')}:${_selectedHora.minute.toString().padLeft(2, '0')}:00';
                      await widget.viewModel.actualizarRecordatorio(
                        widget.idMascota,
                        widget.recordatorio.id,
                        _selectedTipo,
                        novaHora,
                        _selectedDias,
                        widget.recordatorio.activo,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Guardar",
                        style: TextStyle(color: Colors.black87)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
