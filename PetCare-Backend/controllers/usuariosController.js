const db = require('../db');

const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const [rows] = await db.query(
            'SELECT id_usuario, nombre, email FROM usuario WHERE email = ? AND password = ?',
            [email, password]
        );
        if (rows.length === 0) {
            return res.status(401).json({ error: 'Email o contraseña incorrectos' });
        }
        res.json(rows[0]); // { id_usuario, nombre, email }
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error en el servidor' });
    }
};

const registrar = async (req, res) => {
    try {
        const { nombre, email, password } = req.body;
        const [result] = await db.query(
            'INSERT INTO usuario (nombre, email, password) VALUES (?, ?, ?)',
            [nombre, email, password]
        );
        res.status(201).json({ id_usuario: result.insertId, nombre, email });
    } catch (error) {
        console.error(error);
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ error: 'El email ya está registrado' });
        }
        res.status(500).json({ error: 'Error al crear usuario' });
    }
};

module.exports = { login, registrar };