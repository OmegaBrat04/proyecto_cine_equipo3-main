const sql = require('mssql');

const dbConfig = {
    server: 'DESKTOP-I34HH4E', // El nombre de tu servidor
    database: 'CineDB', // Nombre de tu base de datos
    options: {
        trustServerCertificate: true,
        encrypt: false
    },
    authentication: {
        type: 'default', // Autenticación SQL
        options: {
            userName: 'Brandon', // El nombre de usuario SQL
            password: 'hola1234' // La contraseña del usuario SQL
        }
    }
};

async function connectDB() {
    try {
        if (!sql.pool) {
            await sql.connect(dbConfig);
            console.log("✅ Conexión nueva a SQL Server establecida");
        } else {
            console.log("⚠️ Ya hay una conexión activa");
        }
    } catch (error) {
        console.error("❌ Error al conectar a SQL Server:", error);
    }
}


module.exports = { sql, connectDB };
