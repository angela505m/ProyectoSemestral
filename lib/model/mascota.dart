class Mascota {
  final int id;
  final String nombre;
  final String tipo;
  final String? tipoOtro;
  final int? edad;
  final int? idUsuario;

  Mascota({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.tipoOtro,
    this.edad,
    this.idUsuario,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) => Mascota(
        id: json['id_mascota'],
        nombre: json['nombre'],
        tipo: json['tipo'],
        tipoOtro: json['tipo_otro'],
        edad: json['edad'],
        idUsuario: json['id_usuario'],
      );

  Map<String, dynamic> toJson() => {
        'id_mascota': id,
        'nombre': nombre,
        'tipo': tipo,
        'tipo_otro': tipoOtro,
        'edad': edad,
        'id_usuario': idUsuario,
      };
}
