// filepath: e:\Flutter\Proyecto_Cine_Laptop-main\proyecto_cine_equipo3-main\api-sqlserver\test.js
const express = require('express');
const sql = require('mssql');
const path = require('path');
const { connectDB } = require('./db');
const app = express();
const PORT = 3000;

app.use(express.json());

app.use('/images', express.static(path.join(__dirname, '../images')));

app.get('/funciones', async (req, res) => {
    const fecha = req.query.fecha; // e.g. 2025-04-26
    if (!fecha) return res.status(400).send("Falta la fecha en el query string");

    try {
        await connectDB();
        const result = await sql.query(`
            SELECT 
    P.id_Pelicula,
    P.titulo,
    P.genero,
    P.clasificacion,
    CONVERT(varchar(5), P.duracion, 108) AS duracion,
    P.poster,
    F.idioma,
    CONVERT(varchar(5), F.horario, 108) AS horario,
    CAST(F.sala AS VARCHAR) AS sala,
    F.tipo_sala
FROM Funciones F
INNER JOIN Peliculas P ON F.id_pelicula = P.id_Pelicula
WHERE F.fecha = '${fecha}'
ORDER BY P.id_Pelicula, F.idioma, F.horario

        `);


        const agrupado = {};

        result.recordset.forEach(row => {
            const id = row.id_Pelicula;

            if (!agrupado[id]) {
                agrupado[id] = {
                    titulo: row.titulo,
                    genero: row.genero,
                    clasificacion: row.clasificacion,
                    duracion: row.duracion,
                    poster: row.poster,
                    funciones: {}
                };
            }


            if (!agrupado[id].funciones[row.idioma]) {
                agrupado[id].funciones[row.idioma] = [];
            }

            agrupado[id].funciones[row.idioma].push({
                horario: row.horario,
                sala: row.sala,
                tipo_sala: (row.tipo_sala === null || row.tipo_sala === undefined) ? '2D' : row.tipo_sala
            });



        });


        res.json(Object.values(agrupado));
    } catch (error) {
        console.error("❌ Error al consultar funciones:", error);
        res.status(500).send("Error al obtener funciones");
    }
});

app.get('/tiposboletos', async (req, res) => {
    const fecha = req.query.fecha;
    const tipoSala = req.query.tipoSala;

    if (!fecha || !tipoSala) {
        return res.status(400).send("Falta fecha o tipoSala en el query string");
    }

    try {
        await connectDB();
        const result = await sql.query(`
            SELECT 
                id_boleto,
                nombre,
                CASE 
                    WHEN fecha_especial IS NULL THEN 
                        CASE WHEN '${tipoSala}' = '2D' THEN precio_2D ELSE precio_3D END
                    WHEN fecha_especial = '${fecha}' THEN 
                        CASE WHEN '${tipoSala}' = '2D' THEN precio_2D ELSE precio_3D END
                    ELSE NULL
                END AS precio
            FROM TiposBoletos
        `);

        const boletos = result.recordset.filter(row => row.precio !== null);

        res.json(boletos);
    } catch (error) {
        console.error("❌ Error al consultar tipos de boletos:", error);
        res.status(500).send("Error al obtener tipos de boletos");
    }
});

app.post('/addMiembro', async (req, res) => {
    const { nombre, apellido, telefono, direccion, ine, tipo_membresia } = req.body;

    try {
        await connectDB();
        await sql.query`
        INSERT INTO Miembros (nombre, apellido, telefono, direccion, ine, tipo_membresia)
        VALUES (${nombre}, ${apellido}, ${telefono}, ${direccion}, ${ine}, ${tipo_membresia})
      `;
        res.status(201).send('Miembro agregado exitosamente');
    } catch (error) {
        console.error('Error al agregar miembro:', error);
        res.status(500).send('Error al agregar miembro');
    }
});

app.get('/miembros', async (req, res) => {
    try {
        await connectDB();
        const result = await sql.query(`
            SELECT id_miembro, nombre, apellido, telefono, direccion, ine, tipo_membresia
            FROM Miembros
        `);
        res.json(result.recordset);
    } catch (error) {
        console.error('Error al obtener miembros:', error);
        res.status(500).send('Error al obtener miembros');
    }
});


app.delete('/miembros/:id', async (req, res) => {
    const { id } = req.params;

    try {
        await connectDB();
        await sql.query`
        DELETE FROM Miembros WHERE id_miembro = ${id}
      `;
        res.status(200).send('Miembro eliminado exitosamente');
    } catch (error) {
        console.error('Error al eliminar miembro:', error);
        res.status(500).send('Error al eliminar miembro');
    }
});


app.put('/miembros/:id', async (req, res) => {
    const { id } = req.params;
    const { nombre, apellido, telefono, direccion, ine, tipo_membresia } = req.body;

    try {
        await connectDB();
        await sql.query`
        UPDATE Miembros
        SET
          nombre = ${nombre},
          apellido = ${apellido},
          telefono = ${telefono},
          direccion = ${direccion},
          ine = ${ine},
          tipo_membresia = ${tipo_membresia}
        WHERE id_miembro = ${id}
      `;
        res.status(200).send('Miembro actualizado exitosamente');
    } catch (error) {
        console.error('Error al actualizar miembro:', error);
        res.status(500).send('Error al actualizar miembro');
    }
});

app.get('/miembroTelefono/:telefono', async (req, res) => {
    const { telefono } = req.params;

    try {
        await connectDB();
        const result = await sql.query`
        SELECT id_miembro, nombre, tipo_membresia, cashback_acumulado
        FROM Miembros
        WHERE telefono = ${telefono}
      `;

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('Miembro no encontrado');
        }
    } catch (error) {
        console.error('Error al buscar miembro:', error);
        res.status(500).send('Error al buscar miembro');
    }
});


app.post('/pago', async (req, res) => {
    const {
        id_miembro,
        nombre_cliente,
        monto_total,
        monto_recibido,
        cambio,
        tipo_pago,
        cashback_generado
    } = req.body;

    try {
        await connectDB();
        await sql.query`
            INSERT INTO Pagos (id_miembro, nombre_cliente, monto_total, monto_recibido, cambio, tipo_pago, cashback_generado)
            VALUES (${id_miembro}, ${nombre_cliente}, ${monto_total}, ${monto_recibido}, ${cambio}, ${tipo_pago}, ${cashback_generado})
        `;

        if (id_miembro && cashback_generado > 0) {
            await sql.query`
                UPDATE Miembros
                SET cashback_acumulado = cashback_acumulado + ${cashback_generado}
                WHERE id_miembro = ${id_miembro}
            `;
        }

        res.status(201).send('Pago registrado exitosamente');
    } catch (error) {
        console.error('Error al registrar pago:', error);
        res.status(500).send('Error al registrar pago');
    }
});

app.get('/asientosOcupados', async (req, res) => {
    const { fecha, horario, sala } = req.query;

    try {
        await connectDB();
        const result = await sql.query`
        SELECT asientos_ocupados
        FROM Funciones
        WHERE fecha = ${fecha} AND horario = ${horario} AND sala = ${sala}
      `;

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('No se encontraron asientos ocupados');
        }
    } catch (error) {
        console.error('Error al obtener asientos ocupados:', error);
        res.status(500).send('Error al obtener asientos ocupados');
    }
});


app.put('/actualizarAsientosVendidos', async (req, res) => {
    const { fecha, horario, sala, nuevos_asientos } = req.body;
  
    try {
      await connectDB();
  
      const resultado = await sql.query`
        SELECT asientos_ocupados
        FROM Funciones
        WHERE fecha = ${fecha} AND horario = ${horario} AND sala = ${sala}
      `;
  
      let asientosActuales = '';
      if (resultado.recordset.length > 0) {
        asientosActuales = resultado.recordset[0].asientos_ocupados || '';
      }
  
      let asientosCombinados = asientosActuales
        ? asientosActuales + ',' + nuevos_asientos
        : nuevos_asientos;
  
      await sql.query`
        UPDATE Funciones
        SET asientos_ocupados = ${asientosCombinados}
        WHERE fecha = ${fecha} AND horario = ${horario} AND sala = ${sala}
      `;
  
      res.status(200).send('Asientos actualizados exitosamente');
    } catch (error) {
      console.error('Error al actualizar asientos vendidos:', error);
      res.status(500).send('Error al actualizar asientos vendidos');
    }
  });
  

app.listen(PORT, () => {
    console.log(`✅ Servidor corriendo en http://localhost:${PORT}`);
});

