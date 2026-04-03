const db = require('../db');

// Obtener mascotas de un usuario (si viene ?user=id) o todas
const obtenerMascotas = async (req, res) => {
    try {
        const idUsuario = req.query.user;
        let query = 'SELECT * FROM mascota';
        const params = [];
        if (idUsuario) {
            query += ' WHERE id_usuario = ?';
            params.push(idUsuario);
        }
        const [rows] = await db.query(query, params);
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener mascotas' });
    }
};

// Agregar mascota
const agregarMascota = async (req, res) => {
    try {
        const { nombre, tipo, tipo_otro, edad, id_usuario } = req.body;
        const [result] = await db.query(
            'INSERT INTO mascota (nombre, tipo, tipo_otro, edad, id_usuario) VALUES (?, ?, ?, ?, ?)',
            [nombre, tipo, tipo_otro || null, edad || null, id_usuario]
        );
        // Devolvemos el objeto completo para que coincida con el modelo Flutter
        res.status(201).json({
            id_mascota: result.insertId,
            nombre,
            tipo,
            tipo_otro: tipo_otro || null,
            edad: edad || null,
            id_usuario
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al agregar mascota' });
    }
};

// Eliminar mascota
const eliminarMascota = async (req, res) => {
    try {
        const { id } = req.params;
        await db.query('DELETE FROM mascota WHERE id_mascota = ?', [id]);
        res.json({ mensaje: 'Mascota eliminada' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar mascota' });
    }
};

module.exports = { obtenerMascotas, agregarMascota, eliminarMascota };