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
    const result = await request.query('SELECT nombre, unidad FROM Consumibles');
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
    const { nombre, imagen, cantidad_producida, unidad, costo_total_estimado, receta_id } = req.body;

    if (!nombre || !cantidad_producida || !unidad || !costo_total_estimado || !receta_id) {
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

    // Relacionar con la receta
    await new sql.Request()
      .input('intermedio_id', sql.Int, intermedioId)
      .input('receta_id', sql.Int, receta_id)
      .query(`
        INSERT INTO Intermedios_Recetas (intermedio_id, receta_id)
        VALUES (@intermedio_id, @receta_id)
      `);

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
        R.ID_Receta AS receta_id,
        R.Nombre AS receta_nombre
      FROM Intermedios I
      JOIN Intermedios_Recetas IR ON IR.intermedio_id = I.id
      JOIN Receta R ON R.ID_Receta = IR.receta_id
      ORDER BY I.id DESC
    `);

    // Para cada intermedio, trae los consumibles de la receta asociada
    const intermedios = [];
    for (const row of result.recordset) {
      const consRes = await new sql.Request()
        .input('receta_id', sql.Int, row.receta_id)
        .query(`
          SELECT c.nombre, ri.Cantidad, ri.Unidad
          FROM RecetaIngrediente ri
          JOIN Consumibles c ON c.id = ri.ID_Consumible
          WHERE ri.ID_Receta = @receta_id
        `);

      intermedios.push({
        ...row,
        consumibles: consRes.recordset
      });
    }

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

router.put('/updateIntermedio/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { cantidad_producida } = req.body;
  if (isNaN(id) || typeof cantidad_producida !== 'number') {
    return res.status(400).json({ message: 'Datos inválidos' });
  }
  try {
    const pool = await sql.connect(dbConfig);

    // Obtener el intermedio actual
    const result = await pool.request()
      .input('id', sql.Int, id)
      .query('SELECT cantidad_producida, costo_total_estimado FROM Intermedios WHERE id = @id');
    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Intermedio no encontrado' });
    }
    const actual = result.recordset[0];
    // Calcula el nuevo costo proporcionalmente
    const factor = cantidad_producida / actual.cantidad_producida;
    const nuevoCosto = actual.costo_total_estimado * factor;

    await pool.request()
      .input('id', sql.Int, id)
      .input('cantidad', sql.Float, cantidad_producida)
      .input('costo', sql.Float, nuevoCosto)
      .query('UPDATE Intermedios SET cantidad_producida = @cantidad, costo_total_estimado = @costo WHERE id = @id');
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ message: 'Error al actualizar intermedio' });
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

// ...existing code...
router.post('/addReceta', async (req, res) => {
  const { nombre, porcion, unidadPorcion, ingredientes } = req.body;
  if (!nombre || !porcion || !unidadPorcion || !Array.isArray(ingredientes) || ingredientes.length === 0) {
    return res.status(400).json({ message: 'Faltan datos de receta, porción o ingredientes' });
  }

  const pool = await sql.connect(dbConfig);
  const transaction = new sql.Transaction(pool);
  try {
    await transaction.begin();

    // 1) Insertar receta
    const insertRec = await transaction.request()
      .input('nombre', sql.NVarChar, nombre)
      .input('porcion', sql.Decimal(10, 2), porcion)
      .input('unidadPorcion', sql.NVarChar, unidadPorcion)
      .query(`
        INSERT INTO Receta (Nombre, Porcion, UnidadPorcion)
        OUTPUT INSERTED.ID_Receta
        VALUES (@nombre, @porcion, @unidadPorcion)
      `);
    const newId = insertRec.recordset[0].ID_Receta;

    // 2) Insertar cada ingrediente
    for (let ing of ingredientes) {
      await transaction.request()
        .input('rid', sql.Int, newId)
        .input('cid', sql.Int, ing.idConsumible)
        .input('cant', sql.Decimal(10, 2), ing.cantidad)
        .input('uni', sql.NVarChar, ing.unidad)
        .query(`
          INSERT INTO RecetaIngrediente (ID_Receta, ID_Consumible, Cantidad, Unidad)
          VALUES (@rid, @cid, @cant, @uni)
        `);
    }

    await transaction.commit();
    res.status(201).json({ success: true, id: newId });
  } catch (err) {
    await transaction.rollback();
    console.error('❌ Error al agregar receta:', err);
    res.status(500).json({ message: 'Error al agregar receta' });
  }
});


router.get('/getRecetas', async (req, res) => {
  try {
    const pool = await sql.connect(dbConfig);
    // Traemos recetas
    const recetasResult = await pool.request().query(`
      SELECT ID_Receta, Nombre, Porcion, UnidadPorcion FROM Receta ORDER BY ID_Receta DESC
    `);

    const recetas = [];
    for (let row of recetasResult.recordset) {
      // Para cada receta, obtenemos sus ingredientes
      const ingrRes = await pool.request()
        .input('id', sql.Int, row.ID_Receta)
        .query(`
    SELECT ri.ID_Consumible, c.nombre AS consumible, ri.Cantidad, ri.Unidad, c.precio_unitario
    FROM RecetaIngrediente ri
    JOIN Consumibles c ON c.id = ri.ID_Consumible
    WHERE ri.ID_Receta = @id
  `);

      recetas.push({
        id: row.ID_Receta,
        nombre: row.Nombre,
        porcion: row.Porcion,
        unidadPorcion: row.UnidadPorcion,
        ingredientes: ingrRes.recordset.map(i => ({
          idConsumible: i.ID_Consumible,
          nombre: i.consumible,
          cantidad: i.Cantidad,
          unidad: i.Unidad,
          precio_unitario: i.precio_unitario
        }))
      });
    }

    res.status(200).json(recetas);
  } catch (err) {
    console.error('❌ Error al obtener recetas:', err);
    res.status(500).json({ message: 'Error al obtener recetas' });
  }
});

router.put('/descontarStock/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { cantidad } = req.body;
  if (isNaN(id) || typeof cantidad !== 'number') {
    return res.status(400).json({ message: 'Datos inválidos' });
  }
  try {
    const pool = await sql.connect(dbConfig);
    await pool.request()
      .input('id', sql.Int, id)
      .input('cantidad', sql.Float, cantidad)
      .query('UPDATE Consumibles SET stock = stock - @cantidad WHERE id = @id');
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ message: 'Error al descontar stock' });
  }
});

router.delete('/deleteReceta/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) return res.status(400).json({ message: 'ID inválido' });

  const pool = await sql.connect(dbConfig);
  const transaction = new sql.Transaction(pool);
  try {
    await transaction.begin();

    // 1) Borrar ingredientes
    await transaction.request()
      .input('rid', sql.Int, id)
      .query('DELETE FROM RecetaIngrediente WHERE ID_Receta = @rid');

    // 2) Borrar receta
    const delRes = await transaction.request()
      .input('rid', sql.Int, id)
      .query('DELETE FROM Receta WHERE ID_Receta = @rid');

    await transaction.commit();

    if (delRes.rowsAffected[0] > 0) {
      res.json({ success: true });
    } else {
      res.status(404).json({ message: 'Receta no encontrada' });
    }
  } catch (err) {
    await transaction.rollback();
    console.error('❌ Error al eliminar receta:', err);
    res.status(500).json({ message: 'Error al eliminar receta' });
  }
});

router.put('/updateReceta/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { nombre, porcion, unidadPorcion, ingredientes } = req.body;
  if (isNaN(id) || !nombre || !porcion || !unidadPorcion || !Array.isArray(ingredientes)) {
    return res.status(400).json({ message: 'Datos inválidos' });
  }

  const pool = await sql.connect(dbConfig);
  const tx = new sql.Transaction(pool);
  try {
    await tx.begin();

    // 1) Actualizar nombre y porcion
    await tx.request()
      .input('rid', sql.Int, id)
      .input('nombre', sql.NVarChar, nombre)
      .input('porcion', sql.Decimal(10, 2), porcion)
      .input('unidadPorcion', sql.NVarChar, unidadPorcion)
      .query('UPDATE Receta SET Nombre = @nombre, Porcion = @porcion, UnidadPorcion = @unidadPorcion WHERE ID_Receta = @rid');

    // 2) Borrar viejos ingredientes
    await tx.request()
      .input('rid', sql.Int, id)
      .query('DELETE FROM RecetaIngrediente WHERE ID_Receta = @rid');

    // 3) Insertar nuevos
    for (let ing of ingredientes) {
      await tx.request()
        .input('rid', sql.Int, id)
        .input('cid', sql.Int, ing.idConsumible)
        .input('cant', sql.Decimal(10, 2), ing.cantidad)
        .input('uni', sql.NVarChar, ing.unidad)
        .query(`
          INSERT INTO RecetaIngrediente (ID_Receta, ID_Consumible, Cantidad, Unidad)
          VALUES (@rid, @cid, @cant, @uni)
        `);
    }

    await tx.commit();
    res.json({ success: true });
  } catch (err) {
    await tx.rollback();
    console.error('❌ Error al actualizar receta:', err);
    res.status(500).json({ message: 'Error al actualizar receta' });
  }
});

router.get('/getConsumible/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) {
    return res.status(400).json({ message: 'ID inválido' });
  }
  try {
    const request = new sql.Request();
    request.input('id', sql.Int, id);
    const result = await request.query('SELECT * FROM Consumibles WHERE id = @id');
    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Consumible no encontrado' });
    }
    res.status(200).json(result.recordset[0]);
  } catch (error) {
    console.error('❌ Error al obtener consumible:', error);
    res.status(500).json({ message: 'Error al obtener consumible' });
  }
});


// ----------------------------------- RUTAS DE Productos -----------------------------------

function convertirUnidad(cantidad, unidadOrigen, unidadDestino) {
  if (!unidadOrigen || !unidadDestino) return cantidad;
  unidadOrigen = unidadOrigen.toLowerCase();
  unidadDestino = unidadDestino.toLowerCase();
  if (unidadOrigen === unidadDestino) return cantidad;
  // Peso
  if (unidadOrigen === 'gr' && unidadDestino === 'kg') return cantidad / 1000;
  if (unidadOrigen === 'kg' && unidadDestino === 'gr') return cantidad * 1000;
  // Volumen
  if (unidadOrigen === 'ml' && unidadDestino === 'l') return cantidad / 1000;
  if (unidadOrigen === 'l' && unidadDestino === 'ml') return cantidad * 1000;
  // Unidades
  if (unidadOrigen === 'u' && unidadDestino === 'u') return cantidad;
  // Incompatibles
  return null;
}

router.post('/addProducto', async (req, res) => {
  try {
    const {
      nombre,
      tamano,
      porcionCantidad,
      porcionUnidad,
      stock,
      precio,
      imagen,
      insumos // [{nombre, cantidad, unidad, tipo}]
    } = req.body;

    if (!nombre || !stock || !precio) {
      return res.status(400).json({ message: '🌟 nombre, stock y precio son obligatorios' });
    }

    // 1. Insertar el producto
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

    // 2. Descontar stock de insumos/intermedios
    if (Array.isArray(insumos)) {
      for (const insumo of insumos) {
        if (insumo.tipo === 'consumible') {
          // Buscar unidad real del consumible
          const result = await new sql.Request()
            .input('nombre', sql.NVarChar, insumo.nombre)
            .query('SELECT unidad, stock FROM Consumibles WHERE nombre = @nombre');
          if (!result.recordset.length) continue;
          const unidadStock = result.recordset[0].unidad;
          const cantidadDescontar = convertirUnidad(insumo.cantidad, insumo.unidad, unidadStock);
          if (cantidadDescontar === null) continue; // Unidades incompatibles
          await new sql.Request()
            .input('nombre', sql.NVarChar, insumo.nombre)
            .input('cantidad', sql.Float, cantidadDescontar)
            .query('UPDATE Consumibles SET stock = stock - @cantidad WHERE nombre = @nombre');
        } else if (insumo.tipo === 'intermedio') {
          // Buscar unidad real del intermedio
          const result = await new sql.Request()
            .input('nombre', sql.NVarChar, insumo.nombre)
            .query('SELECT unidad, cantidad_producida FROM Intermedios WHERE nombre = @nombre');
          if (!result.recordset.length) continue;
          const unidadStock = result.recordset[0].unidad;
          const cantidadDescontar = convertirUnidad(insumo.cantidad, insumo.unidad, unidadStock);
          if (cantidadDescontar === null) continue; // Unidades incompatibles
          await new sql.Request()
            .input('nombre', sql.NVarChar, insumo.nombre)
            .input('cantidad', sql.Float, cantidadDescontar)
            .query('UPDATE Intermedios SET cantidad_producida = cantidad_producida - @cantidad WHERE nombre = @nombre');
        }
      }
    }

    res.status(201).json({ message: '✅ Producto agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar producto:', error);
    res.status(500).json({ message: 'Error al agregar producto' });
  }
});

router.get('/getAllProductos', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        idProducto,
        nombre,
        tamano,
        porcionCantidad,
        porcionUnidad,
        stock,
        precio,
        imagen
      FROM dbo.Productos
    `);
    res.status(200).json(result.recordset);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener productos', error: error.message });
  }
});

router.post('/aumentarStockProducto', async (req, res) => {
  const { idProducto, cantidadAumentar } = req.body;
  if (!idProducto || !cantidadAumentar || cantidadAumentar <= 0) {
    return res.status(400).json({ message: 'Datos inválidos' });
  }
  try {
    const pool = await sql.connect(dbConfig);
    // 1. Obtener receta de insumos/intermedios usados por el producto
    const productoRes = await pool.request()
      .input('id', sql.Int, idProducto)
      .query('SELECT * FROM Productos WHERE idProducto = @id');
    if (!productoRes.recordset.length) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }
    const producto = productoRes.recordset[0];

    // Aquí deberías tener una tabla que relacione producto-insumos/intermedios y cantidades usadas por unidad
    // Por ejemplo: SELECT * FROM ProductoInsumos WHERE idProducto = @id
    // Supongamos que tienes esa tabla:
    const insumosRes = await pool.request()
      .input('id', sql.Int, idProducto)
      .query('SELECT nombre, cantidad, unidad, tipo FROM ProductoInsumos WHERE idProducto = @id');
    for (const insumo of insumosRes.recordset) {
      const cantidadTotal = insumo.cantidad * cantidadAumentar;
      // Descontar del stock/intermedio igual que en addProducto
      if (insumo.tipo === 'consumible') {
        const result = await pool.request()
          .input('nombre', sql.NVarChar, insumo.nombre)
          .query('SELECT unidad, stock FROM Consumibles WHERE nombre = @nombre');
        if (!result.recordset.length) continue;
        const unidadStock = result.recordset[0].unidad;
        const cantidadDescontar = convertirUnidad(cantidadTotal, insumo.unidad, unidadStock);
        if (cantidadDescontar === null) continue;
        await pool.request()
          .input('nombre', sql.NVarChar, insumo.nombre)
          .input('cantidad', sql.Float, cantidadDescontar)
          .query('UPDATE Consumibles SET stock = stock - @cantidad WHERE nombre = @nombre');
      } else if (insumo.tipo === 'intermedio') {
        const result = await pool.request()
          .input('nombre', sql.NVarChar, insumo.nombre)
          .query('SELECT unidad, cantidad_producida FROM Intermedios WHERE nombre = @nombre');
        if (!result.recordset.length) continue;
        const unidadStock = result.recordset[0].unidad;
        const cantidadDescontar = convertirUnidad(cantidadTotal, insumo.unidad, unidadStock);
        if (cantidadDescontar === null) continue;
        await pool.request()
          .input('nombre', sql.NVarChar, insumo.nombre)
          .input('cantidad', sql.Float, cantidadDescontar)
          .query('UPDATE Intermedios SET cantidad_producida = cantidad_producida - @cantidad WHERE nombre = @nombre');
      }
    }
    // 2. Actualizar el stock del producto
    await pool.request()
      .input('id', sql.Int, idProducto)
      .input('cantidad', sql.Int, cantidadAumentar)
      .query('UPDATE Productos SET stock = stock + @cantidad WHERE idProducto = @id');
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: 'Error al aumentar stock', error: error.message });
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

//-----------------------------------------RUTAS DE COMBOS------------------------------------------------

router.post('/addCombo', async (req, res) => {
  const { nombre, precio, imagen, productos } = req.body;
  // productos: [{ idProducto, cantidad }]
  if (!nombre || !precio || !Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({ message: 'Faltan datos del combo o productos' });
  }
  try {
    const pool = await sql.connect(dbConfig);
    // 1. Insertar combo
    const result = await pool.request()
      .input('nombre', sql.NVarChar, nombre)
      .input('precio', sql.Decimal(10, 2), precio)
      .input('imagen', sql.NVarChar, imagen || null)
      .query(`
        INSERT INTO Combos (nombre, precio, imagen)
        OUTPUT INSERTED.idCombo
        VALUES (@nombre, @precio, @imagen)
      `);
    const idCombo = result.recordset[0].idCombo;
    // 2. Insertar productos del combo
    for (const p of productos) {
      await pool.request()
        .input('idCombo', sql.Int, idCombo)
        .input('idProducto', sql.Int, p.idProducto)
        .input('cantidad', sql.Int, p.cantidad)
        .query(`
          INSERT INTO ComboProductos (idCombo, idProducto, cantidad)
          VALUES (@idCombo, @idProducto, @cantidad)
        `);
    }
    res.status(201).json({ message: 'Combo registrado correctamente' });
  } catch (error) {
    console.error('❌ Error al registrar combo:', error);
    res.status(500).json({ message: 'Error al registrar combo' });
  }
});

// AdminConexion.js
router.get('/getAllCombos', async (req, res) => {
  try {
    const request = new sql.Request();
    const combosResult = await request.query(`
      SELECT idCombo, nombre, precio, imagen
      FROM Combos
      ORDER BY idCombo DESC
    `);

    const combos = combosResult.recordset;

    // Para cada combo, trae los productos incluidos con todos sus datos
    for (const combo of combos) {
      const productosRes = await new sql.Request()
        .input('idCombo', sql.Int, combo.idCombo)
        .query(`
          SELECT 
            p.idProducto, p.nombre, p.precio, p.imagen, p.tamano, p.stock, cp.cantidad
          FROM ComboProductos cp
          JOIN Productos p ON p.idProducto = cp.idProducto
          WHERE cp.idCombo = @idCombo
        `);
      combo.productos = productosRes.recordset; // [{idProducto, nombre, precio, imagen, tamano, stock, cantidad}]
    }

    res.status(200).json(combos);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener combos', error: error.message });
  }
});


router.put('/updateCombo/:idCombo', async (req, res) => {
  const idCombo = parseInt(req.params.idCombo, 10);
  const { nombre, precio, imagen, productos } = req.body;
  // productos: [{ idProducto, cantidad }]
  if (!idCombo || !nombre || !precio || !Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({ message: 'Faltan datos del combo o productos' });
  }
  try {
    const pool = await sql.connect(dbConfig);

    // 1. Actualizar datos del combo
    await pool.request()
      .input('idCombo', sql.Int, idCombo)
      .input('nombre', sql.NVarChar, nombre)
      .input('precio', sql.Decimal(10, 2), precio)
      .input('imagen', sql.NVarChar, imagen || null)
      .query(`
        UPDATE Combos
        SET nombre = @nombre, precio = @precio, imagen = @imagen
        WHERE idCombo = @idCombo
      `);

    // 2. Eliminar productos actuales del combo
    await pool.request()
      .input('idCombo', sql.Int, idCombo)
      .query('DELETE FROM ComboProductos WHERE idCombo = @idCombo');

    // 3. Insertar los nuevos productos del combo
    for (const p of productos) {
      await pool.request()
        .input('idCombo', sql.Int, idCombo)
        .input('idProducto', sql.Int, p.idProducto)
        .input('cantidad', sql.Int, p.cantidad)
        .query(`
          INSERT INTO ComboProductos (idCombo, idProducto, cantidad)
          VALUES (@idCombo, @idProducto, @cantidad)
        `);
    }

    res.status(200).json({ message: 'Combo actualizado correctamente' });
  } catch (error) {
    console.error('❌ Error al actualizar combo:', error);
    res.status(500).json({ message: 'Error al actualizar combo' });
  }
});



module.exports = router;




