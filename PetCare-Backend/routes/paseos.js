const express = require('express');
const router = express.Router();
const { iniciarPaseo, finalizarPaseo } = require('../controllers/paseosController');

router.post('/', iniciarPaseo);
router.put('/:id', finalizarPaseo);

module.exports = router;