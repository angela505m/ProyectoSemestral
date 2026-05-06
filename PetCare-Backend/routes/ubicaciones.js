const express = require('express');
const router = express.Router();
const { registrarUbicacion } = require('../controllers/ubicacionesController');

router.post('/', registrarUbicacion);

module.exports = router;