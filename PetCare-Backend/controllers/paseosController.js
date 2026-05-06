const db = require('../db');

const iniciarPaseo = async (req, res) => {
    try {
        const { id_mascota, fecha, hora_inicio } = req.body;
        const [result] = await db.query(
            'INSERT INTO paseo (id_mascota, fecha, hora_inicio) VALUES (?, ?, ?)',
            [id_mascota, fecha, hora_inicio]
        );
        const [nuevo] = await db.query(
            'SELECT * FROM paseo WHERE id_paseo = ?',
            [result.insertId]
        );
        res.status(201).json(nuevo[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al iniciar paseo' });
    }
};

const finalizarPaseo = async (req, res) => {
    try {
        const { id } = req.params;
        const { hora_fin, duracion } = req.body;
        await db.query(
            'UPDATE paseo SET hora_fin = ?, duracion = ? WHERE id_paseo = ?',
            [hora_fin, duracion, id]
        );
        res.json({ mensaje: 'Paseo finalizado' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al finalizar paseo' });
    }
};

module.exports = { iniciarPaseo, finalizarPaseo };