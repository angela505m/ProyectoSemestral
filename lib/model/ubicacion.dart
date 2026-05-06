class Ubicacion {
  final int id;
  final int idPaseo;
  final double latitud;
  final double longitud;
  final String fechaHora;

  Ubicacion({
    required this.id,
    required this.idPaseo,
    required this.latitud,
    required this.longitud,
    required this.fechaHora,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        id: json['id_ubicacion'],
        idPaseo: json['id_paseo'],
        latitud: double.parse(json['latitud'].toString()),
        longitud: double.parse(json['longitud'].toString()),
        fechaHora: json['fecha_hora'],
      );
}
