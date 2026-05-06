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

// Actualizar mascota (nueva función)
const actualizarMascota = async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, tipo, tipo_otro, edad } = req.body;
        const [result] = await db.query(
            'UPDATE mascota SET nombre = ?, tipo = ?, tipo_otro = ?, edad = ? WHERE id_mascota = ?',
            [nombre, tipo, tipo_otro || null, edad || null, id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Mascota no encontrada' });
        }
        const [rows] = await db.query('SELECT * FROM mascota WHERE id_mascota = ?', [id]);
        res.json(rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar mascota' });
    }
};

module.exports = { obtenerMascotas, agregarMascota, eliminarMascota, actualizarMascota };