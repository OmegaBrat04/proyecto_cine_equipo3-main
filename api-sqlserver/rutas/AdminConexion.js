const express = require('express');
const router = express.Router();
const { connectDB, sql, dbConfig } = require('../db');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

router.use(express.json());
router.use(bodyParser.json());

router.use('/uploads', express.static('uploads'));

// Crear carpeta de uploads si no existe
const uploadPath = 'uploads/';
if (!fs.existsSync(uploadPath)) {
  fs.mkdirSync(uploadPath, { recursive: true });
}

// Configuración de almacenamiento para imágenes
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

/* ---------------------------- RUTAS DE ADMINISTRACIÓN ---------------------------- */

router.post('/login', async (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({ message: 'Usuario y contraseña son requeridos' });
  }
  try {
    const pool = await sql.connect(dbConfig);
    const result = await pool.request()
      .input('usuario', sql.NVarChar, usuario)
      .input('contrasena', sql.NVarChar, contrasena)
      .query('SELECT * FROM Usuarios WHERE usuario = @usuario AND contrasena = @contrasena');
    console.log("📡 Resultado de la consulta:", result.recordset); // ✅ Verificar el resultado de la consulta
    if (result.recordset.length > 0) {
      const usuario = result.recordset[0];
      res.status(200).json({
        valido: true,
        message: 'Autenticación exitosa',
        usuario: {
          nombre: usuario.nombre,
          apellidos: usuario.apellidos,
          usuario: usuario.usuario,
          departamento: usuario.departamento
        }
      });

    }
    else {
      res.status(401).json({ valido: false, message: 'Usuario o contraseña inválidos' });
    }
  } catch (err) {
    console.error('Error en la consulta:', err);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

// ✅ Agregar un usuario
router.post('/addUser', async (req, res) => {
  try {
    const { nombre, apellidos, telefono, rfc, usuario, contrasena, cumpleanos, departamento } = req.body;

    if (!nombre || !apellidos || !telefono || !rfc || !usuario || !contrasena || !cumpleanos || !departamento) {
      return res.status(400).json({ message: 'Todos los campos son necesarios' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('apellidos', sql.NVarChar, apellidos);
    request.input('telefono', sql.NVarChar, telefono);
    request.input('rfc', sql.NVarChar, rfc);
    request.input('usuario', sql.NVarChar, usuario);
    request.input('contrasena', sql.NVarChar, contrasena);
    request.input('cumpleanos', sql.Date, cumpleanos);
    request.input('departamento', sql.NVarChar, departamento);

    await request.query(`
            INSERT INTO Usuarios (nombre, apellidos, telefono, rfc, usuario, contrasena, cumpleanos, departamento)
            VALUES (@nombre, @apellidos, @telefono, @rfc, @usuario, @contrasena, @cumpleanos, @departamento)
        `);

    res.status(201).json({ message: '✅ Usuario agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar usuario:', error);
    res.status(500).json({ message: 'Error al agregar usuario' });
  }
});

// ✅ Obtener usuarios con orden dinámico
router.get('/getUsers', async (req, res) => {
  try {
    const { orderBy, departamento } = req.query;
    let query = `
      SELECT 
        id,
        nombre,
        apellidos, 
        ISNULL(CONCAT(nombre, ' ', apellidos), 'Desconocido') AS nombre_completo, 
        telefono, 
        rfc, 
        usuario, 
        FORMAT(cumpleanos, 'yyyy-MM-dd') AS cumpleanos, 
        departamento 
      FROM Usuarios
    `;

    const request = new sql.Request();

    if (departamento && departamento !== "Todos") {
      query += ' WHERE departamento = @departamento';
      request.input('departamento', sql.NVarChar, departamento);
    }

    switch (orderBy) {
      case 'Cumpleaños':
        query += ' ORDER BY cumpleanos ASC';
        break;
      case 'Fecha Registro':
        query += ' ORDER BY id DESC';
        break;
      case 'Departamento':
        query += ' ORDER BY departamento ASC';
        break;
    }

    const result = await request.query(query);
    console.log("📡 Usuarios obtenidos:", result.recordset);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener usuarios:', error);
    res.status(500).json({ message: 'Error al obtener los usuarios' });
  }
});


// ✅ Eliminar un usuario
router.delete('/deleteUser/:id', async (req, res) => {
  try {
    const userId = parseInt(req.params.id, 10);
    if (isNaN(userId)) {
      return res.status(400).json({ message: 'ID inválido' });
    }

    const request = new sql.Request();
    request.input('id', sql.Int, userId);

    const result = await request.query('DELETE FROM Usuarios WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: '✅ Usuario eliminado con éxito' });
    } else {
      res.status(404).json({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error('❌ Error al eliminar usuario:', error);
    res.status(500).json({ message: 'Error al eliminar usuario' });
  }
});
"TOP"

router.put('/updateUser/:id', async (req, res) => {
  const { id } = req.params;
  const {
    nombre,
    apellidos,
    telefono,
    rfc,
    usuario,
    cumpleanos,
    departamento
  } = req.body;

  try {
    await connectDB();
    await sql.query`
      UPDATE Usuarios
      SET
        nombre = ${nombre},
        apellidos = ${apellidos},
        telefono = ${telefono},
        rfc = ${rfc},
        usuario = ${usuario},
        cumpleanos = ${cumpleanos},
        departamento = ${departamento}
      WHERE id = ${id}
    `;

    res.status(200).send({ message: 'Usuario actualizado correctamente' });
  } catch (error) {
    console.error('❌ Error al actualizar usuario:', error);
    res.status(500).send({ message: 'Error al actualizar usuario' });
  }
});


// -------------------------------- RUTAS DE PELÍCULAS-----------------------------------

// ✅ Agregar una película
router.post('/addMovie', async (req, res) => {
  let {
    titulo,
    director,
    duracion,
    idioma,
    subtitulos,
    genero,
    clasificacion,
    sinopsis,
    poster
  } = req.body;

  if (!titulo || !director || !duracion || !idioma || !genero || !clasificacion || !sinopsis) {
    return res.status(400).json({ message: "Todos los campos son obligatorios." });
  }

  try {
    const request = new sql.Request();

    // Convertir imagen a binario


    request.input('titulo', sql.NVarChar, titulo);
    request.input('director', sql.NVarChar, director);
    request.input('duracion', sql.NVarChar, duracion);
    request.input('idioma', sql.NVarChar, idioma);
    request.input('subtitulos', sql.Bit, subtitulos ? 1 : 0);

    request.input('genero', sql.NVarChar, genero);
    request.input('clasificacion', sql.NVarChar, clasificacion);
    request.input('sinopsis', sql.Text, sinopsis);
    request.input('poster', sql.NVarChar, poster);


    await request.query(`
      INSERT INTO Pelicula (titulo, director, duracion, idioma, subtitulos, genero, clasificacion, sinopsis, poster)
      VALUES (@titulo, @director, @duracion, @idioma, @subtitulos, @genero, @clasificacion, @sinopsis, @poster)
    `);

    console.log("✅ Película registrada con éxito:", titulo);
    res.status(201).json({ message: "Película registrada con éxito" });
  } catch (error) {
    console.error("❌ Error al registrar película:", error);
    res.status(500).json({ message: "Error en el servidor" });
  }
});

// ✅ Obtener todas las películas
router.get('/getMovies', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT * FROM Pelicula ORDER BY ID_Pelicula DESC');

    const mapped = result.recordset.map(p => ({
      id: p.ID_Pelicula,
      titulo: p.Titulo,
      director: p.Director,
      duracion: p.Duracion,
      idioma: p.Idioma,
      subtitulos: p.Subtitulos,
      genero: p.Genero,
      clasificacion: p.Clasificacion,
      sinopsis: p.Sinopsis,
      poster: p.Poster
    }));

    res.status(200).json(mapped);
  } catch (error) {
    console.error("❌ Error al obtener películas:", error);
    res.status(500).json({ message: error.message });
  }
});

// ✅ Borrar una película por ID
router.delete('/deleteMovie/:id', async (req, res) => {
  try {
    const movieId = parseInt(req.params.id, 10);

    if (isNaN(movieId)) {
      return res.status(400).json({ message: 'ID de película inválido' });
    }

    const request = new sql.Request();
    request.input('id', sql.Int, movieId);

    const result = await request.query('DELETE FROM Pelicula WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      console.log(`✅ Película con ID ${movieId} eliminada`);
      res.status(200).json({ message: 'Película eliminada con éxito' });
    } else {
      console.log(`⚠️ No se encontró la película con ID ${movieId}`);
      res.status(404).json({ message: 'Película no encontrada' });
    }
  } catch (error) {
    console.error('❌ Error al eliminar película:', error);
    res.status(500).json({ message: 'Error al eliminar película' });
  }
});


router.put('/updateMovie/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const {
    titulo,
    director,
    duracion,
    idioma,
    subtitulos,
    genero,
    clasificacion,
    sinopsis,
    poster
  } = req.body;

  if (!titulo || !director || !duracion || !idioma || !genero || !clasificacion || !sinopsis) {
    return res.status(400).json({ message: "Todos los campos son obligatorios." });
  }

  try {
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    request.input('titulo', sql.NVarChar, titulo);
    request.input('director', sql.NVarChar, director);
    request.input('duracion', sql.NVarChar, duracion);
    request.input('idioma', sql.NVarChar, idioma);
    request.input('subtitulos', sql.Bit, subtitulos ? 1 : 0);

    request.input('genero', sql.NVarChar, genero);
    request.input('clasificacion', sql.NVarChar, clasificacion);
    request.input('sinopsis', sql.Text, sinopsis);
    request.input('poster', sql.NVarChar, poster);

    const result = await request.query(`
      UPDATE Pelicula
      SET
        titulo = @titulo,
        director = @director,
        duracion = @duracion,
        idioma = @idioma,
        subtitulos = @subtitulos,
        genero = @genero,
        clasificacion = @clasificacion,
        sinopsis = @sinopsis,
        poster = @poster
      WHERE ID_Pelicula = @id
    `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: "Película actualizada correctamente" });
    } else {
      res.status(404).json({ message: "Película no encontrada" });
    }
  } catch (error) {
    console.error("❌ Error al actualizar película:", error);
    res.status(500).json({ message: "Error al actualizar película" });
  }
});



// -------------------------------- RUTAS DE FUNCIONES -----------------------------------

router.post('/addFunction', async (req, res) => {
  try {
    let { id_pelicula, horario, fecha, sala, tipo_sala, idioma } = req.body;

    console.log("📥 Datos recibidos:", { id_pelicula, horario, fecha, sala, tipo_sala, idioma });

    if (!id_pelicula || !horario || !fecha || !sala || !tipo_sala || !idioma) {
      return res.status(400).json({ message: "Todos los campos son obligatorios." });
    }

    // Validar formato de hora
    const horarioValido = /^([01]?\d|2[0-3]):[0-5]\d:[0-5]\d$/.test(horario);
    if (!horarioValido) {
      console.log("⛔ Error: Formato de horario incorrecto →", horario);
      return res.status(400).json({ message: "Formato de horario inválido. Usa HH:mm:ss" });
    }

    const request = new sql.Request();
    request.input('id_pelicula', sql.Int, id_pelicula);
    request.input('horario', sql.NVarChar, horario);
    request.input('fecha', sql.Date, fecha);
    request.input('sala', sql.Int, sala);
    request.input('tipo_sala', sql.NVarChar, tipo_sala);
    request.input('idioma', sql.NVarChar, idioma);

    await request.query(`
      INSERT INTO Funciones (id_pelicula, horario, fecha, sala, tipo_sala, idioma)
      VALUES (@id_pelicula, @horario, @fecha, @sala, @tipo_sala, @idioma)
    `);

    console.log("✅ Función agregada con éxito");
    res.status(201).json({ message: "✅ Función agregada con éxito" });


  } catch (error) {
    console.error("❌ Error al agregar función:", error);
    res.status(500).json({ message: "Error en el servidor" });
  }
});

router.get('/getFunctions', async (req, res) => {
  try {
    console.log("📡 Obteniendo funciones...");
    const request = new sql.Request();
    const result = await request.query('SELECT * FROM Funciones ORDER BY fecha DESC, horario ASC');

    console.log("✅ Funciones obtenidas:", result.recordset.length);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error("❌ Error al obtener funciones:", error);
    res.status(500).json({ message: "Error al obtener funciones" });
  }
});

router.delete('/deleteFunction/:id', async (req, res) => {
  try {
    const functionId = parseInt(req.params.id, 10);
    if (isNaN(functionId)) {
      return res.status(400).json({ message: 'ID inválido' });
    }

    console.log("🗑️ Eliminando función con ID:", functionId);

    const request = new sql.Request();
    request.input('id', sql.Int, functionId);
    const result = await request.query('DELETE FROM Funciones WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      console.log("✅ Función eliminada con éxito:", functionId);
      res.status(200).json({ message: "✅ Función eliminada con éxito" });
    } else {
      console.log("⚠️ Función no encontrada:", functionId);
      res.status(404).json({ message: "Función no encontrada" });
    }
  } catch (error) {
    console.error("❌ Error al eliminar función:", error);
    res.status(500).json({ message: "Error al eliminar función" });
  }
});

router.post('/verificarFuncionExistente', async (req, res) => {
  try {
    const { horario, fecha, sala } = req.body;

    const request = new sql.Request();
    request.input('horario', sql.NVarChar, horario);
    request.input('fecha', sql.Date, fecha);
    request.input('sala', sql.Int, sala);

    const result = await request.query(`
      SELECT COUNT(*) AS total FROM Funciones 
      WHERE fecha = @fecha AND horario = @horario AND sala = @sala
    `);

    const existe = result.recordset[0].total > 0;
    res.status(200).json({ existe });
  } catch (error) {
    console.error('❌ Error al verificar función existente:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});


router.get('/getFuncionesVigentes', async (req, res) => {
  try {
    const request = new sql.Request();

    const result = await request.query(`
      SELECT f.id, f.horario, f.fecha, f.sala, f.tipo_sala, f.idioma,
             p.Titulo AS titulo
      FROM Funciones f
      JOIN Pelicula p ON f.id_pelicula = p.ID_Pelicula
      WHERE 
        (
          f.fecha > CAST(GETDATE() AS DATE)
          OR (f.fecha = CAST(GETDATE() AS DATE) AND f.horario > FORMAT(GETDATE(), 'HH:mm:ss'))
        )
      ORDER BY f.fecha ASC, f.horario ASC
    `);

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error("❌ Error al obtener funciones vigentes:", error);
    res.status(500).json({ message: "Error al obtener funciones vigentes" });
  }
});


router.put('/updateFunction/:id', async (req, res) => {
  const { id } = req.params;
  const { id_pelicula, horario, fecha, sala, tipo_sala, idioma } = req.body;

  try {
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    request.input('id_pelicula', sql.Int, id_pelicula);
    request.input('horario', sql.NVarChar, horario);
    request.input('fecha', sql.Date, fecha);
    request.input('sala', sql.Int, sala);
    request.input('tipo_sala', sql.NVarChar, tipo_sala);
    request.input('idioma', sql.NVarChar, idioma);

    const result = await request.query(`
      UPDATE Funciones
      SET id_pelicula = @id_pelicula,
          horario = @horario,
          fecha = @fecha,
          sala = @sala,
          tipo_sala = @tipo_sala,
          idioma = @idioma
      WHERE id = @id
    `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: '✅ Función actualizada con éxito' });
    } else {
      res.status(404).json({ message: 'Función no encontrada' });
    }
  } catch (error) {
    console.error('❌ Error al actualizar función:', error);
    res.status(500).json({ message: 'Error al actualizar función' });
  }
});



// -------------------------------- RUTAS DE PROVEEDORES Y CONSUMIBLES -----------------------------------
// ✅ Agregar un proveedor con RFC
router.post('/addProveedor', async (req, res) => {
  try {
    const { nombre, correo, telefono, direccion, rfc } = req.body;

    if (!nombre || !correo || !telefono || !direccion || !rfc) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('correo', sql.NVarChar, correo);
    request.input('telefono', sql.NVarChar, telefono);
    request.input('direccion', sql.NVarChar, direccion);
    request.input('rfc', sql.NVarChar, rfc);

    await request.query(`
      INSERT INTO Proveedores (nombre, correo, telefono, direccion, rfc)
      VALUES (@nombre, @correo, @telefono, @direccion, @rfc)
    `);

    res.status(201).json({ message: '✅ Proveedor agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar proveedor:', error);
    res.status(500).json({ message: 'Error al agregar proveedor' });
  }
});

router.put('/updateProveedor/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  const { nombre, correo, telefono, direccion, rfc } = req.body;

  if (!nombre || !correo || !telefono || !direccion || !rfc) {
    return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
  }

  try {
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    request.input('nombre', sql.NVarChar, nombre);
    request.input('correo', sql.NVarChar, correo);
    request.input('telefono', sql.NVarChar, telefono);
    request.input('direccion', sql.NVarChar, direccion);
    request.input('rfc', sql.NVarChar, rfc);

    const result = await request.query(`
      UPDATE Proveedores
      SET nombre = @nombre, correo = @correo, telefono = @telefono, direccion = @direccion, rfc = @rfc
      WHERE id = @id
    `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: '✅ Proveedor actualizado con éxito' });
    } else {
      res.status(404).json({ message: 'Proveedor no encontrado' });
    }
  } catch (error) {
    console.error('❌ Error al actualizar proveedor:', error);
    res.status(500).json({ message: 'Error al actualizar proveedor' });
  }
});


// ✅ Agregar un consumible
router.post('/addConsumible', async (req, res) => {
  try {
    const { nombre, proveedor, stock, unidad, precio_unitario, imagen } = req.body;

    if (!nombre || !proveedor || !stock || !unidad || !precio_unitario) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('proveedor', sql.NVarChar, proveedor);
    request.input('stock', sql.Int, stock);
    request.input('unidad', sql.NVarChar, unidad);
    request.input('precio_unitario', sql.Float, precio_unitario);
    request.input('imagen', sql.NVarChar, imagen || null);

    await request.query(`
      INSERT INTO Consumibles (nombre, proveedor, stock, unidad, precio_unitario, imagen)
      VALUES (@nombre, @proveedor, @stock, @unidad, @precio_unitario, @imagen)
    `);

    res.status(201).json({ message: '✅ Consumible agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar consumible:', error);
    res.status(500).json({ message: 'Error al agregar consumible' });
  }
});

router.put('/updateConsumible/:nombre', async (req, res) => {
  const { nombre } = req.params;
  const { proveedor, stock, precio_unitario, imagen } = req.body;

  try {
    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('proveedor', sql.NVarChar, proveedor);
    request.input('stock', sql.Int, stock);
    request.input('precio_unitario', sql.Float, precio_unitario);
    request.input('imagen', sql.NVarChar, imagen || null);

    await request.query(`
      UPDATE Consumibles
      SET proveedor = @proveedor,
          stock = @stock,
          precio_unitario = @precio_unitario,
          imagen = @imagen
      WHERE nombre = @nombre
    `);

    res.status(200).json({ message: 'Consumible actualizado con éxito' });
  } catch (error) {
    console.error('Error al actualizar consumible:', error);
    res.status(500).json({ message: 'Error al actualizar consumible' });
  }
});



// Obtener todos los consumibles
router.get('/getConsumibles', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT nombre FROM Consumibles');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error al obtener consumibles:', error);
    res.status(500).json({ message: 'Error al obtener consumibles' });
  }
});

router.get('/getConsumiblesParaReceta', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT id, nombre, unidad FROM Consumibles');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error al obtener consumibles:', error);
    res.status(500).json({ message: 'Error al obtener consumibles' });
  }
});


router.delete('/deleteConsumible/:nombre', async (req, res) => {
  try {
    const nombre = req.params.nombre;
    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    const result = await request.query('DELETE FROM Consumibles WHERE nombre = @nombre');
    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: 'Consumible eliminado con éxito' });
    } else {
      res.status(404).json({ message: 'Consumible no encontrado' });
    }
  } catch (error) {
    console.error('Error al eliminar consumible:', error);
    res.status(500).json({ message: 'Error al eliminar consumible' });
  }
});


// Obtener todos los proveedores
router.get('/getProveedores', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT nombre FROM Proveedores');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener proveedores:', error);
    res.status(500).json({ message: 'Error al obtener proveedores' });
  }
});

router.delete('/deleteProveedor/:nombre', async (req, res) => {
  const { nombre } = req.params;
  try {
    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    const result = await request.query('DELETE FROM Proveedores WHERE nombre = @nombre');

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ mensaje: 'Proveedor eliminado con éxito' });
    } else {
      res.status(404).json({ mensaje: 'Proveedor no encontrado' });
    }
  } catch (error) {
    console.error('❌ Error al eliminar proveedor:', error);
    res.status(500).json({ mensaje: 'Error al eliminar el proveedor', error });
  }
});

//--------------------------------- RUTAS DE INTERMEDIOS -----------------------------------

router.post('/addIntermedio', async (req, res) => {
  try {
    const { nombre, imagen, cantidad_producida, unidad, costo_total_estimado, consumibles_usados } = req.body;

    if (!nombre || !cantidad_producida || !unidad || !costo_total_estimado || !consumibles_usados) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
    }

    // Insertar en la tabla Intermedios
    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('imagen', sql.NVarChar, imagen || null);
    request.input('cantidad_producida', sql.Float, cantidad_producida);
    request.input('unidad', sql.NVarChar, unidad);
    request.input('costo_total_estimado', sql.Float, costo_total_estimado);

    const result = await request.query(`
      INSERT INTO Intermedios (nombre, imagen, cantidad_producida, unidad, costo_total_estimado)
      OUTPUT INSERTED.id
      VALUES (@nombre, @imagen, @cantidad_producida, @unidad, @costo_total_estimado)
    `);

    const intermedioId = result.recordset[0].id;

    for (const c of consumibles_usados) {
      const reqInsert = new sql.Request();
      reqInsert.input('intermedio_id', sql.Int, intermedioId);
      reqInsert.input('nombre', sql.NVarChar, c.nombre);
      reqInsert.input('cantidad_usada', sql.Float, c.cantidad_usada);
      await reqInsert.query(`
        INSERT INTO Intermedios_Consumibles (intermedio_id, nombre, cantidad_usada)
        VALUES (@intermedio_id, @nombre, @cantidad_usada)
      `);

      const reqUpdate = new sql.Request();
      reqUpdate.input('nombre', sql.NVarChar, c.nombre);
      reqUpdate.input('cantidad_usada', sql.Float, c.cantidad_usada);
      await reqUpdate.query(`
        UPDATE Consumibles
        SET stock = stock - @cantidad_usada
        WHERE nombre = @nombre
      `);
    }





    res.status(201).json({ message: '✅ Intermedio guardado exitosamente' });
  } catch (error) {
    console.error('❌ Error al guardar intermedio:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

router.get('/getIntermedios', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        I.id,
        I.nombre,
        I.imagen,
        I.cantidad_producida,
        I.unidad,
        I.costo_total_estimado,
        (
          SELECT 
            nombre, 
            cantidad_usada 
          FROM Intermedios_Consumibles IC 
          WHERE IC.intermedio_id = I.id 
          FOR JSON PATH
        ) AS consumibles
      FROM Intermedios I
      ORDER BY I.id DESC
    `);

    // Parsear los campos JSON de consumibles
    const intermedios = result.recordset.map(row => ({
      ...row,
      consumibles: row.consumibles ? JSON.parse(row.consumibles) : []
    }));

    res.status(200).json(intermedios);
  } catch (error) {
    console.error("❌ Error al obtener intermedios:", error);
    res.status(500).json({ message: 'Error al obtener intermedios' });
  }
});

router.delete('/deleteIntermedio/:id', async (req, res) => {
  const intermedioId = parseInt(req.params.id, 10);

  if (isNaN(intermedioId)) {
    return res.status(400).json({ message: 'ID de intermedio inválido' });
  }

  try {
    const request = new sql.Request();
    request.input('id', sql.Int, intermedioId);

    // Primero eliminar los consumibles relacionados
    await request.query('DELETE FROM Intermedios_Consumibles WHERE intermedio_id = @id');

    // Luego eliminar el intermedio
    const result = await request.query('DELETE FROM Intermedios WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: '✅ Intermedio eliminado con éxito' });
    } else {
      res.status(404).json({ message: 'Intermedio no encontrado' });
    }
  } catch (error) {
    console.error('❌ Error al eliminar intermedio:', error);
    res.status(500).json({ message: 'Error al eliminar intermedio' });
  }
});


router.get('/getAllConsumibles', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
  id,
  nombre,
  proveedor,
  stock,
  unidad,
  precio_unitario,
  imagen
FROM Consumibles

      ORDER BY nombre ASC
    `);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener consumibles:', error);
    res.status(500).json({ message: 'Error al obtener consumibles' });
  }
});


router.get('/getAllProveedores', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT id, nombre, correo, telefono, direccion, rfc
      FROM Proveedores
    `);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener proveedores:', error);
    res.status(500).json({ message: 'Error al obtener proveedores' });
  }
});


// 📌 Endpoint para subir imágenes
router.post('/uploadImage', upload.single('poster'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "No se subió ninguna imagen" });
  }

  const imageUrl = `http://localhost:3000/uploads/${req.file.filename}`;
  res.status(200).json({ imageUrl });
});



router.use((err, req, res, next) => {
  console.error('❌ Error inesperado:', err);
  res.status(500).json({ message: 'Error interno del servidor' });
});

//--------------------------------- RUTAS DE RECETAS -----------------------------------

router.post('/addReceta', async (req, res) => {
  const { nombre, porcion, unidad, consumibles } = req.body;

  if (!nombre || !porcion || !unidad || !consumibles || !Array.isArray(consumibles)) {
    return res.status(400).json({ mensaje: 'Datos incompletos o incorrectos' });
  }

  const transaction = new sql.Transaction();

  try {
    await transaction.begin();

    const requestReceta = new sql.Request(transaction);
    requestReceta.input('nombre', sql.NVarChar, nombre);
    requestReceta.input('porcion', sql.Float, porcion);
    requestReceta.input('unidad', sql.NVarChar, unidad);

    const resultReceta = await requestReceta.query(
      'INSERT INTO Recetas (nombre, porcion, unidad) OUTPUT INSERTED.id VALUES (@nombre, @porcion, @unidad)'
    );

    const recetaId = resultReceta.recordset[0].id;

    for (const consumible of consumibles) {
      const requestConsumible = new sql.Request(transaction);
      requestConsumible.input('receta_id', sql.Int, recetaId);
      requestConsumible.input('consumible_id', sql.Int, consumible.id);
      requestConsumible.input('cantidad_usada', sql.Float, consumible.cantidad);

      await requestConsumible.query(
        'INSERT INTO Recetas_Consumibles (receta_id, consumible_id, cantidad_usada) VALUES (@receta_id, @consumible_id, @cantidad_usada)'
      );
    }

    await transaction.commit();
    res.status(201).json({ mensaje: 'Receta creada con éxito' });
  } catch (error) {
    await transaction.rollback();
    console.error('Error al crear la receta:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor', error });
  }
});

// ----------------------------------- RUTAS DE Productos -----------------------------------

router.post('/addProducto', async (req, res) => {
  try {
    const {
      nombre,
      tamano,
      porcionCantidad,
      porcionUnidad,
      stock,
      precio,
      imagen
    } = req.body;

    // Validación básica de campos obligatorios
    if (
      !nombre ||
      !stock ||
      !precio
    ) {
      return res.status(400).json({ message: '🌟 nombre, stock y precio son obligatorios' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('tamano', sql.NVarChar, tamano || null);
    request.input('porcionCantidad', sql.Decimal, porcionCantidad || 0);
    request.input('porcionUnidad', sql.NVarChar, porcionUnidad || null);
    request.input('stock', sql.Int, stock);
    request.input('precio', sql.Decimal, precio);
    request.input('imagen', sql.NVarChar, imagen || null);

    await request.query(`
        INSERT INTO Productos
          (nombre, tamano, porcionCantidad, porcionUnidad, stock, precio, imagen)
        VALUES
          (@nombre, @tamano, @porcionCantidad, @porcionUnidad, @stock, @precio, @imagen)
      `);

    res.status(201).json({ message: '✅ Producto agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar producto:', error);
    res.status(500).json({ message: 'Error al agregar producto' });
  }
});

// 👉 GET para traer todos los productos
router.get('/getAllProductos', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        idProducto,
        nombre,
        stock,
        precio,
        imagen
      FROM dbo.Productos
    `);
    // result.recordset es un array de objetos con tus filas
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener productos:', error);
    res
      .status(500)
      .json({ message: 'Error al obtener productos', error: error.message });
  }
});

// --------------------------- RUTAS DE TIPOS DE BOLETOS ---------------------------

// Agregar boleto
router.post('/addBoleto', async (req, res) => {
  try {
    const { descripcion, precio_2d, precio_3d, fecha_especial } = req.body;

    const request = new sql.Request();
    request.input('descripcion', sql.NVarChar, descripcion);
    request.input('precio_2d', sql.Float, precio_2d);
    request.input('precio_3d', sql.Float, precio_3d);
    request.input('fecha_especial', sql.Date, fecha_especial || null);

    await request.query(`
      INSERT INTO TiposBoletos (descripcion, precio_2d, precio_3d, fecha_especial)
      VALUES (@descripcion, @precio_2d, @precio_3d, @fecha_especial)
    `);

    res.status(201).json({ message: '✅ Boleto agregado correctamente' });
  } catch (error) {
    console.error('❌ Error al agregar boleto:', error);
    res.status(500).json({ message: 'Error al agregar boleto' });
  }
});

// Obtener boletos
router.get('/getBoletos', async (req, res) => {
  try {
    const result = await new sql.Request().query('SELECT * FROM TiposBoletos ORDER BY id_boleto DESC');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener boletos:', error);
    res.status(500).json({ message: 'Error al obtener boletos' });
  }
});

// Eliminar boleto
router.delete('/deleteBoleto/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    await request.query('DELETE FROM TiposBoletos WHERE id_boleto = @id');
    res.status(200).json({ message: '✅ Boleto eliminado con éxito' });
  } catch (error) {
    console.error('❌ Error al eliminar boleto:', error);
    res.status(500).json({ message: 'Error al eliminar boleto' });
  }
});

// --------------------------- RUTAS DE TIPOS DE BOLETOS ---------------------------

// Agregar boleto
router.post('/addBoleto', async (req, res) => {
  try {
    const { nombre, precio_2D, precio_3D, fecha_especial } = req.body;

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('precio_2D', sql.Float, precio_2D);
    request.input('precio_3D', sql.Float, precio_3D);
    request.input('fecha_especial', sql.Date, fecha_especial || null);

    await request.query(`
      INSERT INTO TiposBoletos (nombre, precio_2D, precio_3D, fecha_especial)
      VALUES (@nombre, @precio_2D, @precio_3D, @fecha_especial)
    `);

    res.status(201).json({ message: '✅ Boleto agregado correctamente' });
  } catch (error) {
    console.error('❌ Error al agregar boleto:', error);
    res.status(500).json({ message: 'Error al agregar boleto' });
  }
});

// Obtener boletos
router.get('/getBoletos', async (req, res) => {
  try {
    const result = await new sql.Request().query('SELECT * FROM TiposBoletos ORDER BY id_boleto DESC');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener boletos:', error);
    res.status(500).json({ message: 'Error al obtener boletos' });
  }
});

// Eliminar boleto
router.delete('/deleteBoleto/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    await request.query('DELETE FROM TiposBoletos WHERE id_boleto = @id');
    res.status(200).json({ message: '✅ Boleto eliminado con éxito' });
  } catch (error) {
    console.error('❌ Error al eliminar boleto:', error);
    res.status(500).json({ message: 'Error al eliminar boleto' });
  }
});


// Actualizar boleto
router.put('/updateBoleto/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { nombre, precio_2D, precio_3D, fecha_especial } = req.body;

    const request = new sql.Request();
    request.input('id', sql.Int, id);
    request.input('nombre', sql.NVarChar, nombre);
    request.input('precio_2D', sql.Float, precio_2D);
    request.input('precio_3D', sql.Float, precio_3D);
    request.input('fecha_especial', sql.Date, fecha_especial || null);

    await request.query(`
      UPDATE TiposBoletos
      SET nombre = @nombre,
          precio_2D = @precio_2D,
          precio_3D = @precio_3D,
          fecha_especial = @fecha_especial
      WHERE id_boleto = @id
    `);

    res.status(200).json({ message: '✅ Boleto actualizado correctamente' });
  } catch (error) {
    console.error('❌ Error al actualizar boleto:', error);
    res.status(500).json({ message: 'Error al actualizar boleto' });
  }
});



module.exports = router;




