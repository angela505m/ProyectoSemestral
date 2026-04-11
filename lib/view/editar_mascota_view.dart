import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mascotaviewmodel.dart';
import '../model/mascota.dart';

class EditarMascotaView extends StatefulWidget {
  final Mascota mascota;
  final VoidCallback? onUpdate;

  const EditarMascotaView({super.key, required this.mascota, this.onUpdate});

  @override
  State<EditarMascotaView> createState() => _EditarMascotaViewState();
}

class _EditarMascotaViewState extends State<EditarMascotaView> {
  late TextEditingController _nombreController;
  late String _selectedTipo;
  late TextEditingController _tipoOtroController;
  late TextEditingController _edadController;
  bool _mostrarCampoOtro = false;

  final Map<String, IconData> tipoIconos = {
    'perro': Icons.pets,
    'gato': Icons.pets,
    'ave': Icons.flutter_dash,
    'otro': Icons.help_outline,
  };

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.mascota.nombre);
    _selectedTipo = widget.mascota.tipo;
    _tipoOtroController =
        TextEditingController(text: widget.mascota.tipoOtro ?? '');
    _edadController =
        TextEditingController(text: widget.mascota.edad?.toString() ?? '');
    _mostrarCampoOtro = (_selectedTipo == 'otro');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoOtroController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewModel>(context, listen: false);

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
              Center(
                child: Image.asset('assets/logo.png', height: 100),
              ),
              const SizedBox(height: 10),
              const Text(
                "Editar mascota",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF96C9F2),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                cursorColor: const Color(0xFF96C9F2),
                decoration: InputDecoration(
                  labelText: "Nombre",
                  floatingLabelStyle: const TextStyle(color: Color(0xFF96C9F2)),
                  prefixIcon: const Icon(Icons.badge, color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFF96C9F2), width: 2),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: InputDecoration(
                  labelText: "Tipo",
                  floatingLabelStyle: const TextStyle(color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFF96C9F2), width: 2),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'perro',
                      child: Row(children: [
                        Icon(Icons.pets, color: Color(0xFF96C9F2)),
                        SizedBox(width: 8),
                        Text('Perro')
                      ])),
                  DropdownMenuItem(
                      value: 'gato',
                      child: Row(children: [
                        Icon(Icons.pets, color: Color(0xFF96C9F2)),
                        SizedBox(width: 8),
                        Text('Gato')
                      ])),
                  DropdownMenuItem(
                      value: 'ave',
                      child: Row(children: [
                        Icon(Icons.flutter_dash, color: Color(0xFF96C9F2)),
                        SizedBox(width: 8),
                        Text('Ave')
                      ])),
                  DropdownMenuItem(
                      value: 'otro',
                      child: Row(children: [
                        Icon(Icons.help_outline, color: Color(0xFF96C9F2)),
                        SizedBox(width: 8),
                        Text('Otro')
                      ])),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTipo = value!;
                    _mostrarCampoOtro = (value == 'otro');
                    if (!_mostrarCampoOtro) _tipoOtroController.clear();
                  });
                },
              ),
              if (_mostrarCampoOtro) ...[
                const SizedBox(height: 15),
                TextField(
                  controller: _tipoOtroController,
                  cursorColor: const Color(0xFF96C9F2),
                  decoration: InputDecoration(
                    labelText: "Especificar",
                    floatingLabelStyle:
                        const TextStyle(color: Color(0xFF96C9F2)),
                    prefixIcon:
                        const Icon(Icons.edit, color: Color(0xFF96C9F2)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: Color(0xFF96C9F2), width: 2),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              TextField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                cursorColor: const Color(0xFF96C9F2),
                decoration: InputDecoration(
                  labelText: "Edad (años)",
                  floatingLabelStyle: const TextStyle(color: Color(0xFF96C9F2)),
                  prefixIcon: const Icon(Icons.cake, color: Color(0xFF96C9F2)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        const BorderSide(color: Color(0xFF96C9F2), width: 2),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
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
                      if (_nombreController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("El nombre es obligatorio")),
                        );
                        return;
                      }
                      if (_selectedTipo == 'otro' &&
                          _tipoOtroController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Especifica el tipo")),
                        );
                        return;
                      }
                      final edad = _edadController.text.isNotEmpty
                          ? int.tryParse(_edadController.text)
                          : null;
                      await vm.actualizarMascota(
                        widget.mascota.id,
                        _nombreController.text,
                        _selectedTipo,
                        _selectedTipo == 'otro'
                            ? _tipoOtroController.text
                            : null,
                        edad,
                      );
                      Navigator.pop(context);
                      widget.onUpdate?.call();
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
