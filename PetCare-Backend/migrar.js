const bcrypt = require('bcrypt');
const db = require('./db');

async function migrar() {
    const [users] = await db.query('SELECT id_usuario, contraseña FROM usuario');
    for (const user of users) {
        if (!user.contraseña.startsWith('$2b$')) {
            const hashed = await bcrypt.hash(user.contraseña, 10);
            await db.query('UPDATE usuario SET contraseña = ? WHERE id_usuario = ?', [hashed, user.id_usuario]);
            console.log(`✅ Usuario ${user.id_usuario} migrado`);
        }
    }
    console.log('🎉 Migración completada');
    process.exit();
}


migrar();