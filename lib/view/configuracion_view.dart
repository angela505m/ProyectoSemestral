import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodel/mascotaviewmodel.dart';
import '../viewmodel/usuarioviewmodel.dart';
import '../viewmodel/recordatorioviewmodel.dart';
import 'login_view.dart';
import '../services/notification_service.dart';

class ConfiguracionView extends StatefulWidget {
  const ConfiguracionView({super.key});

  @override
  State<ConfiguracionView> createState() => _ConfiguracionViewState();
}

class _ConfiguracionViewState extends State<ConfiguracionView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;

  bool _notificacionesGlobal = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userVM = Provider.of<UsuarioViewModel>(context, listen: false);
    _nombreController = TextEditingController(text: userVM.usuarioNombre ?? '');
    _emailController = TextEditingController(text: userVM.usuarioEmail ?? '');
    _cargarPreferencia();
  }

  Future<void> _cargarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificacionesGlobal = prefs.getBool('notificaciones_global') ?? true;
    });
  }

  Future<void> _guardarPreferencia(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificaciones_global', valor);
    final recordatorioVM =
        Provider.of<RecordatorioViewModel>(context, listen: false);
    await recordatorioVM.actualizarEstadoGlobal();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final error = await userVM.actualizarPerfil(
      _nombreController.text.trim(),
      _emailController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _eliminarCuenta() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro? Esta acción es irreversible y borrará todas tus mascotas y recordatorios.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    setState(() => _isLoading = true);

    final userVM = Provider.of<UsuarioViewModel>(context, listen: false);
    final recordatorioVM =
        Provider.of<RecordatorioViewModel>(context, listen: false);

    try {
      final userId = userVM.usuarioId;
      if (userId == null) throw Exception('Usuario no identificado');

      final response = await http.delete(
        Uri.parse('${userVM.baseUrl}/usuarios/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200)
        throw Exception('Error al eliminar cuenta');

      userVM.cerrarSesion();
      recordatorioVM.limpiarRecordatorios();
      Provider.of<MascotaViewModel>(context, listen: false).limpiarMascotas();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    final screenSize = MediaQuery.of(context).size;
    final isSmall = screenSize.width < 400;
    final logoSize = isSmall ? 180.0 : 220.0;
    final containerPadding = isSmall ? 24.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFF96C9F2),
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Color(0xFF96C9F2)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/logo.png',
                        height: logoSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: EdgeInsets.all(containerPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Configuración",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF96C9F2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Campo Nombre
                            TextFormField(
                              controller: _nombreController,
                              cursorColor: const Color(0xFF96C9F2),
                              decoration: InputDecoration(
                                labelText: "Nombre",
                                floatingLabelStyle:
                                    const TextStyle(color: Color(0xFF96C9F2)),
                                prefixIcon: const Icon(Icons.person,
                                    color: Color(0xFF96C9F2)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF96C9F2), width: 2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Ingrese su nombre"
                                      : null,
                            ),
                            const SizedBox(height: 15),
                            // Campo Email
                            TextFormField(
                              controller: _emailController,
                              cursorColor: const Color(0xFF96C9F2),
                              decoration: InputDecoration(
                                labelText: "Email",
                                floatingLabelStyle:
                                    const TextStyle(color: Color(0xFF96C9F2)),
                                prefixIcon: const Icon(Icons.email,
                                    color: Color(0xFF96C9F2)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF96C9F2), width: 2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Ingrese su email"
                                      : null,
                            ),
                            const SizedBox(height: 25),
                            // Switch de notificaciones
                            SwitchListTile(
                              title: const Text(
                                'Notificaciones',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: const Text(
                                  'Recibir recordatorios de mascotas'),
                              value: _notificacionesGlobal,
                              onChanged: (valor) async {
                                if (valor && !_notificacionesGlobal) {
                                  final granted = await notificationService
                                      .requestPermission();
                                  if (!granted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Permiso de notificaciones denegado'),
                                      ),
                                    );
                                    return;
                                  }
                                }
                                setState(() => _notificacionesGlobal = valor);
                                await _guardarPreferencia(valor);
                              },
                              activeColor: const Color(0xFF96C9F2),
                              contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 30),
                            // Botón Guardar cambios
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB7E3F6),
                                  foregroundColor: Colors.black87,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: _guardarCambios,
                                child: const Text(
                                  "Guardar cambios",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Botón Eliminar cuenta
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: _eliminarCuenta,
                                child: const Text(
                                  "Eliminar cuenta",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
