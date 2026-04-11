const express = require('express');
const router = express.Router();
const { obtenerMascotas, agregarMascota, eliminarMascota, actualizarMascota } = require('../controllers/mascotasController');

router.get('/', obtenerMascotas);
router.post('/', agregarMascota);
router.put('/:id', actualizarMascota);
router.delete('/:id', eliminarMascota);

module.exports = router;