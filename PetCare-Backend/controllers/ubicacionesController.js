const db = require('../db');

const registrarUbicacion = async (req, res) => {
    try {
        const { id_paseo, latitud, longitud, fecha_hora } = req.body;
        const [result] = await db.query(
            'INSERT INTO ubicacion (id_paseo, latitud, longitud, fecha_hora) VALUES (?, ?, ?, ?)',
            [id_paseo, latitud, longitud, fecha_hora]
        );
        res.status(201).json({ id_ubicacion: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al registrar ubicación' });
    }
};

module.exports = { registrarUbicacion };