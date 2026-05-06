const db = require('./db');

async function testDB() {
    try {
        const [result] = await db.query('SELECT 1');
        console.log('Conexión a MySQL exitosa');
    } catch (error) {
        console.error('Error de conexión a MySQL:', error.message);
        process.exit(1);
    }
}
testDB();

require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Rutas
const mascotasRoutes = require('./routes/mascotas');
const usuariosRoutes = require('./routes/usuarios');
const recordatoriosRoutes = require('./routes/recordatorios');
const paseosRoutes = require('./routes/paseos');
const ubicacionesRoutes = require('./routes/ubicaciones');

app.use('/mascotas', mascotasRoutes);
app.use('/usuarios', usuariosRoutes);
app.use('/recordatorios', recordatoriosRoutes);
app.use('/paseos', paseosRoutes);
app.use('/ubicaciones', ubicacionesRoutes);

const PORT = 3000;
app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));