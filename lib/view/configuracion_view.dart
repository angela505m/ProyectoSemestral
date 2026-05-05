import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodel/mascotaviewmodel.dart';
import '../viewmodel/usuarioviewmodel.dart';
import '../viewmodel/recordatorioviewmodel.dart';
import '../viewmodel/theme_viewmodel.dart';
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
        Navigator.pop(context); // cerrar configuración
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
            child: const Text('Cancelar'),
          ),
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
    final themeVM = Provider.of<ThemeViewModel>(context);
    final notificationService = NotificationService();

    return Scaffold(
      backgroundColor:
          const Color(0xFF96C9F2), // fondo celeste igual que el resto
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
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(28),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título (opcional, pero queda bien)
                        const Text(
                          'Configuración',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF96C9F2),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Información de la cuenta
                        const Text(
                          'Información de la cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingrese su nombre'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Ingrese su email'
                              : null,
                        ),
                        const SizedBox(height: 30),

                        // Preferencias
                        const Text(
                          'Preferencias',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Switch de notificaciones
                        SwitchListTile(
                          title: const Text('Notificaciones'),
                          subtitle:
                              const Text('Recibir recordatorios de mascotas'),
                          value: _notificacionesGlobal,
                          onChanged: (valor) async {
                            if (valor && !_notificacionesGlobal) {
                              final granted =
                                  await notificationService.requestPermission();
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

                        // Switch de modo oscuro
                        SwitchListTile(
                          title: const Text('Modo oscuro'),
                          subtitle: const Text(
                              'Activar tema oscuro en la aplicación'),
                          value: themeVM.isDarkMode,
                          onChanged: (_) => themeVM.toggleTheme(),
                          activeColor: const Color(0xFF96C9F2),
                          contentPadding: EdgeInsets.zero,
                        ),

                        const SizedBox(height: 30),

                        // Botón guardar cambios
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _guardarCambios,
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar cambios'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB7E3F6),
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botón eliminar cuenta
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _eliminarCuenta,
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.red),
                            label: const Text('Eliminar cuenta'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
