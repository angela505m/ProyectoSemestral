const express = require('express');
const router = express.Router();
const { login, registrar, eliminarUsuario, actualizarUsuario } = require('../controllers/usuariosController');

router.post('/login', login);
router.post('/registrar', registrar);
router.delete('/:id', eliminarUsuario);
router.put('/:id', actualizarUsuario);   

module.exports = router;