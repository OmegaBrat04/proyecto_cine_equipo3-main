const express = require('express');
const { connectDB } = require('./db');
const app = express();
const PORT = 3000;

app.use(express.json());

const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


connectDB();


app.use('/api/admin', require('./rutas/AdminConexion'));
app.use('/api/taquilla', require('./rutas/TaquillaConexion'));

app.get('/', (req, res) => res.send('🎬 API del Cine funcionando'));

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});
