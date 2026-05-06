class Recordatorio {
  final int id;
  final int idMascota;
  final String tipo;
  final String hora;
  final String dias;
  bool activo;

  Recordatorio({
    required this.id,
    required this.idMascota,
    required this.tipo,
    required this.hora,
    required this.dias,
    this.activo = true,
  });

  factory Recordatorio.fromJson(Map<String, dynamic> json) => Recordatorio(
        id: json['id_recordatorio'],
        idMascota: json['id_mascota'],
        tipo: json['tipo'],
        hora: json['hora'],
        dias: json['dias'] ?? '',
        activo: json['activo'] == 1,
      );
}
