const express = require('express');
const router = express.Router();
const { login, registrar } = require('../controllers/usuariosController');

router.post('/login', login);
router.post('/registrar', registrar);

module.exports = router;