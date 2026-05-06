const express = require('express');
const router = express.Router();
const { obtenerRecordatoriosPorMascota, agregarRecordatorio, actualizarRecordatorio, eliminarRecordatorio } = require('../controllers/recordatoriosController.js');

router.get('/', obtenerRecordatoriosPorMascota);
router.post('/', agregarRecordatorio);
router.put('/:id', actualizarRecordatorio);
router.delete('/:id', eliminarRecordatorio);

module.exports = router;