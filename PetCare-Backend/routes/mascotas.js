const express = require('express');
const router = express.Router();
const { obtenerMascotas, agregarMascota, eliminarMascota } = require('../controllers/mascotasController');

router.get('/', obtenerMascotas);
router.post('/', agregarMascota);
router.delete('/:id', eliminarMascota);

module.exports = router;