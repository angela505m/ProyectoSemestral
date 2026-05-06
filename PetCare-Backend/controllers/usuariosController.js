const bcrypt = require('bcrypt');
const db = require('../db');
const saltRounds = 10;

const registrar = async (req, res) => {
    try {
        const { nombre, email, password } = req.body;

        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const [result] = await db.query(
            'INSERT INTO usuario (nombre, email, contraseña, es_premium) VALUES (?, ?, ?, false)',
            [nombre, email, hashedPassword]
        );

        res.status(201).json({ 
            id_usuario: result.insertId, 
            nombre, 
            email, 
            es_premium: false 
        });
    } catch (error) {
        console.error(error);
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ error: 'El email ya está registrado' });
        }
        res.status(500).json({ error: 'Error al crear usuario' });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const [rows] = await db.query(
            'SELECT id_usuario, nombre, email, contraseña, es_premium FROM usuario WHERE email = ?',
            [email]
        );

        if (rows.length === 0) {
            return res.status(401).json({ error: 'Email o contraseña incorrectos' });
        }

        const usuario = rows[0];

        const match = await bcrypt.compare(password, usuario.contraseña);

        if (!match) {
            return res.status(401).json({ error: 'Email o contraseña incorrectos' });
        }

        res.json({
            id_usuario: usuario.id_usuario,
            nombre: usuario.nombre,
            email: usuario.email,
            es_premium: usuario.es_premium
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error en el servidor' });
    }
};

const eliminarUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await db.query('DELETE FROM usuario WHERE id_usuario = ?', [id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        res.json({ mensaje: 'Usuario eliminado correctamente' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar usuario' });
    }
};


const actualizarUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, email } = req.body;

       
        const [existing] = await db.query('SELECT id_usuario FROM usuario WHERE email = ? AND id_usuario != ?', [email, id]);
        if (existing.length > 0) {
            return res.status(400).json({ error: 'El email ya está registrado por otro usuario' });
        }

        const [result] = await db.query(
            'UPDATE usuario SET nombre = ?, email = ? WHERE id_usuario = ?',
            [nombre, email, id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        res.json({ mensaje: 'Usuario actualizado correctamente', nombre, email });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar usuario' });
    }
};

module.exports = { login, registrar, eliminarUsuario, actualizarUsuario };