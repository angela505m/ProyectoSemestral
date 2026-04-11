class Paseo {
  final int id;
  final int idMascota;
  final String fecha;
  final String horaInicio;
  final String? horaFin;
  final int? duracion;

  Paseo({
    required this.id,
    required this.idMascota,
    required this.fecha,
    required this.horaInicio,
    this.horaFin,
    this.duracion,
  });

  factory Paseo.fromJson(Map<String, dynamic> json) => Paseo(
        id: json['id_paseo'],
        idMascota: json['id_mascota'],
        fecha: json['fecha'],
        horaInicio: json['hora_inicio'],
        horaFin: json['hora_fin'],
        duracion: json['duracion'],
      );
}
