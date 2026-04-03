require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Rutas
const mascotasRoutes = require('./routes/mascotas');
const usuariosRoutes = require('./routes/usuarios');

app.use('/mascotas', mascotasRoutes);
app.use('/usuarios', usuariosRoutes);

const PORT = 3000;
app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));