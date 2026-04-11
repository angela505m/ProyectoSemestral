import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mascotaviewmodel.dart';
import '../viewmodel/usuarioviewmodel.dart';
import '../viewmodel/recordatorioviewmodel.dart';
import 'agregar_view.dart';
import 'editar_mascota_view.dart';
import 'editar_recordatorio_view.dart';
import 'login_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MascotaViewModel>(context);
    final usuarioVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final recordatorioVM = Provider.of<RecordatorioViewModel>(context);
    final String nombreUsuario = usuarioVM.usuarioNombre ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idUsuario = usuarioVM.usuarioId;
      if (idUsuario != null) {
        vm.cargarMascotas(idUsuario);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF96C9F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (usuarioVM.esPremium)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.star, color: Colors.amber, size: 20),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                nombreUsuario,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () =>
                _confirmarCerrarSesion(context, usuarioVM, recordatorioVM),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenido, $nombreUsuario",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Cuida a tus amigos peludos",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildUbicacionCard(vm),
              const SizedBox(height: 25),
              if (vm.paseoActivo != null) _buildPaseoActivoCard(vm),
              if (vm.paseoActivo != null) const SizedBox(height: 25),
              _buildMascotasSection(
                  context, vm, recordatorioVM, usuarioVM.usuarioId!),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Color(0xFF96C9F2)),
        onPressed: () {
          final idUsuario = usuarioVM.usuarioId;
          if (idUsuario != null) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AgregarView(
                  idUsuario: idUsuario,
                  onClose: () {
                    Navigator.pop(context);
                    vm.cargarMascotas(idUsuario);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUbicacionCard(MascotaViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.location_on, color: Color(0xFF96C9F2)),
            SizedBox(width: 8),
            Text("Ubicación actual",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Text(vm.ubicacionActual),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB7E3F6),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: vm.obtenerUbicacion,
            icon: const Icon(Icons.gps_fixed),
            label: const Text("Obtener ubicación"),
          ),
        ],
      ),
    );
  }

  Widget _buildPaseoActivoCard(MascotaViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.directions_walk, color: Color(0xFF96C9F2)),
            SizedBox(width: 8),
            Text("Paseo en curso",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Text("Iniciado: ${vm.paseoActivo!.horaInicio}"),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => vm.finalizarPaseo(),
            icon: const Icon(Icons.stop),
            label: const Text("Finalizar paseo"),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotasSection(
    BuildContext context,
    MascotaViewModel vm,
    RecordatorioViewModel recordatorioVM,
    int idUsuario,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.pets, color: Color(0xFF96C9F2)),
            SizedBox(width: 8),
            Text("Mis mascotas", style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          if (vm.mascotas.isEmpty)
            const Center(
                child: Text("No hay mascotas",
                    style: TextStyle(color: Colors.grey)))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.mascotas.length,
              itemBuilder: (ctx, index) {
                final m = vm.mascotas[index];
                IconData icono;
                switch (m.tipo) {
                  case 'perro':
                  case 'gato':
                    icono = Icons.pets;
                    break;
                  case 'ave':
                    icono = Icons.flutter_dash;
                    break;
                  default:
                    icono = Icons.help_outline;
                }
                String tipoTexto =
                    m.tipo == 'otro' ? (m.tipoOtro ?? 'Mascota') : m.tipo;
                String subtitulo = tipoTexto;
                if (m.edad != null) {
                  subtitulo += ' • ${m.edad} ${m.edad == 1 ? 'año' : 'años'}';
                }
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: const Color(0xFF96C9F2),
                      collapsedIconColor: const Color(0xFF96C9F2),
                      leading: Icon(icono, color: const Color(0xFF96C9F2)),
                      title: Text(m.nombre),
                      subtitle: Text(subtitulo),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (vm.paseoActivo == null)
                                    ElevatedButton.icon(
                                      onPressed: () => vm.iniciarPaseo(m.id),
                                      icon: const Icon(Icons.directions_walk,
                                          color: Colors.black87),
                                      label: const Text("Iniciar paseo",
                                          style:
                                              TextStyle(color: Colors.black87)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFB7E3F6),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Color(0xFF96C9F2)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => EditarMascotaView(
                                          mascota: m,
                                          onUpdate: () =>
                                              vm.cargarMascotas(idUsuario),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => vm.eliminarMascota(m.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.notifications,
                                      size: 18, color: Color(0xFF96C9F2)),
                                  const SizedBox(width: 5),
                                  const Text("Recordatorios",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _mostrarDialogoRecordatorio(
                                            context, m.id, recordatorioVM),
                                    icon: const Icon(Icons.add,
                                        size: 18, color: Color(0xFF96C9F2)),
                                    label: const Text("Agregar",
                                        style: TextStyle(
                                            color: Color(0xFF96C9F2))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _RecordatoriosList(
                                idMascota: m.id,
                                recordatorioVM: recordatorioVM,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Diálogo para NUEVO recordatorio (estilo idéntico al de edición)
  void _mostrarDialogoRecordatorio(
      BuildContext context, int idMascota, RecordatorioViewModel vm) {
    String selectedTipo = 'comida';
    TimeOfDay selectedHora = TimeOfDay.now();
    String selectedDias = 'Lunes,Martes,Miércoles,Jueves,Viernes';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              elevation: 8,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
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
                        "Nuevo recordatorio",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF96C9F2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedTipo,
                        decoration: const InputDecoration(
                          labelText: "Tipo",
                          labelStyle: TextStyle(color: Color(0xFF96C9F2)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF96C9F2)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'comida', child: Text('Comida')),
                          DropdownMenuItem(
                              value: 'paseo', child: Text('Paseo')),
                          DropdownMenuItem(
                              value: 'medicamento', child: Text('Medicamento')),
                        ],
                        onChanged: (v) => setState(() => selectedTipo = v!),
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        title: const Text("Hora"),
                        subtitle: Text(selectedHora.format(context)),
                        trailing: const Icon(Icons.access_time,
                            color: Color(0xFF96C9F2)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedHora,
                          );
                          if (picked != null) {
                            setState(() => selectedHora = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedDias,
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
                        onChanged: (v) => setState(() => selectedDias = v!),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
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
                            onPressed: () {
                              final novaHora =
                                  '${selectedHora.hour.toString().padLeft(2, '0')}:${selectedHora.minute.toString().padLeft(2, '0')}:00';
                              vm.agregarRecordatorio(
                                idMascota,
                                selectedTipo,
                                novaHora,
                                selectedDias,
                              );
                              Navigator.pop(ctx);
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
          },
        );
      },
    );
  }

  void _confirmarCerrarSesion(
    BuildContext context,
    UsuarioViewModel usuarioVM,
    RecordatorioViewModel recordatorioVM,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Estás seguro?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              usuarioVM.cerrarSesion();
              Provider.of<MascotaViewModel>(context, listen: false)
                  .limpiarMascotas();
              recordatorioVM.limpiarRecordatorios();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );
  }
}

// Widget separado para los recordatorios (con botón de editar)
class _RecordatoriosList extends StatefulWidget {
  final int idMascota;
  final RecordatorioViewModel recordatorioVM;

  const _RecordatoriosList(
      {required this.idMascota, required this.recordatorioVM});

  @override
  State<_RecordatoriosList> createState() => _RecordatoriosListState();
}

class _RecordatoriosListState extends State<_RecordatoriosList> {
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    await widget.recordatorioVM.cargarRecordatoriosPorMascota(widget.idMascota);
    if (mounted) setState(() => _cargado = true);
  }

  @override
  Widget build(BuildContext context) {
    final recordatorios =
        widget.recordatorioVM.getRecordatorios(widget.idMascota);
    if (!_cargado) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (recordatorios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("Sin recordatorios",
            style: TextStyle(color: Colors.grey, fontSize: 14)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recordatorios.length,
      itemBuilder: (ctx, i) {
        final r = recordatorios[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  r.activo ? Icons.alarm_on : Icons.alarm_off,
                  size: 24,
                  color: const Color(0xFF96C9F2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${r.tipo} - ${r.hora}",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    if (r.dias.isNotEmpty)
                      Text(
                        r.dias,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: r.activo,
                    onChanged: (val) => widget.recordatorioVM
                        .toggleRecordatorio(widget.idMascota, r.id, val),
                    activeColor: const Color(0xFF96C9F2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        size: 24, color: Color(0xFF96C9F2)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => EditarRecordatorioView(
                          idMascota: widget.idMascota,
                          recordatorio: r,
                          viewModel: widget.recordatorioVM,
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        size: 28, color: Colors.redAccent),
                    onPressed: () => widget.recordatorioVM
                        .eliminarRecordatorio(widget.idMascota, r.id),
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
