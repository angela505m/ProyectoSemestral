const db = require('../db');

const obtenerRecordatoriosPorMascota = async (req, res) => {
    try {
        const idMascota = req.query.mascota;
        if (!idMascota) {
            return res.status(400).json({ error: 'Se requiere id de mascota' });
        }
        const [rows] = await db.query(
            'SELECT * FROM recordatorio WHERE id_mascota = ?',
            [idMascota]
        );
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener recordatorios' });
    }
};

const agregarRecordatorio = async (req, res) => {
    try {
        const { id_mascota, tipo, hora, dias, activo } = req.body;
        const [result] = await db.query(
            'INSERT INTO recordatorio (id_mascota, tipo, hora, dias, activo) VALUES (?, ?, ?, ?, ?)',
            [id_mascota, tipo, hora, dias || '', activo !== undefined ? activo : true]
        );
        const [nuevo] = await db.query(
            'SELECT * FROM recordatorio WHERE id_recordatorio = ?',
            [result.insertId]
        );
        res.status(201).json(nuevo[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al agregar recordatorio' });
    }
};
const actualizarRecordatorio = async (req, res) => {
    try {
        const { id } = req.params;
        const { tipo, hora, dias, activo } = req.body;
        
        // Construir la consulta dinámicamente
        let query = 'UPDATE recordatorio SET ';
        const params = [];
        
        if (tipo !== undefined) {
            query += 'tipo = ?, ';
            params.push(tipo);
        }
        if (hora !== undefined) {
            query += 'hora = ?, ';
            params.push(hora);
        }
        if (dias !== undefined) {
            query += 'dias = ?, ';
            params.push(dias);
        }
        if (activo !== undefined) {
            query += 'activo = ?, ';
            params.push(activo);
        }
        
        // Eliminar la última coma y espacio
        query = query.slice(0, -2);
        query += ' WHERE id_recordatorio = ?';
        params.push(id);
        
        await db.query(query, params);
        
        // Devolver el recordatorio actualizado
        const [rows] = await db.query('SELECT * FROM recordatorio WHERE id_recordatorio = ?', [id]);
        res.json(rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar recordatorio' });
    }
};
const eliminarRecordatorio = async (req, res) => {
    try {
        const { id } = req.params;
        await db.query('DELETE FROM recordatorio WHERE id_recordatorio = ?', [id]);
        res.json({ mensaje: 'Recordatorio eliminado' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar recordatorio' });
    }
};

module.exports = { obtenerRecordatoriosPorMascota, agregarRecordatorio, actualizarRecordatorio, eliminarRecordatorio };