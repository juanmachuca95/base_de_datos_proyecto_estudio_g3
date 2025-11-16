----------------------------------------------------
-- Tema: Procedimientos y funciones almacenadas   --
----------------------------------------------------

/*
    En este script se implementan:

    1) Procedimientos almacenados para:
       - Alta (INSERT) de productos.
       - Modificación (UPDATE) de productos.
       - Baja física (DELETE).
       - Baja lógica y alta lógica usando el campo "activo".
       - Listar_sucursales.
       - Listar_ventas_con_sucursal.

    2) Funciones almacenadas para:
       - Calcular un precio con descuento.
       - Verificar si el stock de un producto está por debajo del mínimo.
       - Verificar si un producto está activo (Alta Lógica).
       - Obtener el nombre de la categoría de un producto.
       - Contar la cantidad de productos activos en la base.
       - Total de ventas.
       - 10 productos mas vendidos. 

    3) Un lote de datos de prueba insertado:
       - Directamente con INSERT.
       - A través del procedimiento insertarProducto.

    El objetivo es:
    - Demostrar el uso práctico de procedimientos y funciones almacenadas.
    - Comparar operaciones directas vs encapsuladas.
    - Controlar las operaciones de ABM para evitar errores y pérdidas de datos.
*/


----------------- SECCIÓN: PROCEDIMIENTOS -------------------
-------------------------------------------------------------
-- Los procedimientos almacenados encapsulan operaciones de
-- ABM sobre la tabla Producto. De esta manera:
-- - Se centraliza la lógica de negocio.
-- - Se pueden otorgar permisos solo para EXEC y no sobre tablas.
-- - Se evitan "fatalidades" (ej. un DELETE sin WHERE).
-------------------------------------------------------------


-------------------------------------------------------------
-- Procedimiento: insertarProducto
-- Propósito: realizar el ALTA (INSERT) de un nuevo producto.
-- Uso típico: desde una aplicación o script que registra productos.
--
-- Parámetros:
--   @nombre        -> Nombre del producto.
--   @descripcion   -> Descripción breve.
--   @precio        -> Precio unitario del producto.
--   @stock         -> Stock actual.
--   @stock_minimo  -> Stock mínimo recomendado.
--   @imagen        -> Nombre del archivo de imagen.
--   @id_categoria  -> Categoría a la cual pertenece el producto.
-------------------------------------------------------------
CREATE PROCEDURE insertarProducto
(
   @nombre        VARCHAR(100),
   @descripcion   VARCHAR(200),
   @precio        FLOAT,
   @stock         INT,
   @stock_minimo  INT,
   @imagen        VARCHAR(200),
   @id_categoria  INT
)
AS
BEGIN
   INSERT INTO Producto (nombre, descripcion, precio, stock, stock_minimo, imagen, id_categoria)
   VALUES (@nombre, @descripcion, @precio, @stock, @stock_minimo, @imagen, @id_categoria);
END;
GO


-------------------------------------------------------------
-- Procedimiento: modificarProducto
-- Propósito: realizar la MODIFICACIÓN (UPDATE) de un producto
--            ya existente, identificado por su id_producto.
--
-- Parámetros:
--   @id_producto   -> Identificador del producto a modificar.
--   @nombre        -> Nuevo nombre.
--   @descripcion   -> Nueva descripción.
--   @precio        -> Nuevo precio.
--   @stock         -> Nuevo stock.
--   @stock_minimo  -> Nuevo stock mínimo.
--   @imagen        -> Nueva imagen.
--   @id_categoria  -> Nueva categoría.
--
-- Comentario:
--   El WHERE id_producto = @id_producto es fundamental para
--   actualizar solo el registro deseado.
-------------------------------------------------------------
CREATE PROCEDURE modificarProducto
(
   @id_producto   INT,
   @nombre        VARCHAR(100),
   @descripcion   VARCHAR(200),
   @precio        FLOAT,
   @stock         INT,
   @stock_minimo  INT,
   @imagen        VARCHAR(200),
   @id_categoria  INT
)
AS
BEGIN
   UPDATE Producto
   SET nombre        = @nombre, 
       descripcion   = @descripcion, 
       precio        = @precio, 
       stock         = @stock, 
       stock_minimo  = @stock_minimo, 
       imagen        = @imagen, 
       id_categoria  = @id_categoria
   WHERE id_producto = @id_producto;
END;
GO


-------------------------------------------------------------
-- Procedimiento: borrarProducto
-- Propósito: realizar la BAJA FÍSICA de un producto (DELETE).
--
-- Parámetros:
--   @id_producto -> Producto que se quiere eliminar.
--
-- Comentario:
--   Este tipo de baja elimina el registro de la tabla. En muchos
--   sistemas reales se prefiere la baja lógica para no perder
--   historial, pero aquí se muestra también el caso de DELETE.
-------------------------------------------------------------
CREATE PROCEDURE borrarProducto
(
   @id_producto INT
)
AS
BEGIN
   DELETE FROM Producto 
   WHERE id_producto = @id_producto;
END;
GO


-------------------------------------------------------------
-- Procedimiento: bajaLogicaProducto
-- Propósito: realizar una BAJA LÓGICA sobre un producto,
--            es decir, marcarlo como inactivo en lugar de borrarlo.
--
-- Parámetros:
--   @id_producto -> Producto que se quiere desactivar.
--
-- Lógica:
--   1) Se verifica que el producto exista.
--   2) Si existe, se actualiza el campo activo = 0.
--   3) Se muestra un mensaje con PRINT para indicar el resultado.
-------------------------------------------------------------
CREATE PROCEDURE bajaLogicaProducto
(
   @id_producto INT
)
AS
BEGIN
   -- Verificar si el producto existe
   IF EXISTS (SELECT 1 FROM Producto WHERE id_producto = @id_producto)
   BEGIN
       -- Realizar la baja lógica, poniendo activo en 0
       UPDATE Producto
       SET activo = 0
       WHERE id_producto = @id_producto;
       
       PRINT 'Producto desactivado correctamente.';
   END
   ELSE
   BEGIN
       PRINT 'Producto no encontrado.';
   END
END;
GO


-------------------------------------------------------------
-- Procedimiento: altaLogicaProducto
-- Propósito: realizar la ALTA LÓGICA de un producto previamente
--            desactivado (activo = 0).
--
-- Parámetros:
--   @id_producto -> Producto que se quiere reactivar.
--
-- Lógica:
--   1) Se verifica que el producto exista.
--   2) Si existe, se actualiza el campo activo = 1.
--   3) Se muestra un mensaje con PRINT para indicar el resultado.
-------------------------------------------------------------
CREATE PROCEDURE altaLogicaProducto
(
   @id_producto INT
)
AS
BEGIN
   -- Verificar si el producto existe
   IF EXISTS (SELECT 1 FROM Producto WHERE id_producto = @id_producto)
   BEGIN
       -- Realizar la alta lógica, poniendo activo en 1
       UPDATE Producto
       SET activo = 1
       WHERE id_producto = @id_producto;
       
       PRINT 'Producto activado correctamente.';
   END
   ELSE
   BEGIN
       PRINT 'Producto no encontrado.';
   END
END;
GO

/* =====================================
   Listar sucursales con su ciudad
   -------------------------------------
   Qué hace: trae todas las sucursales con dirección, teléfono
   y el nombre de la ciudad (unido por id_ciudad).
   Ordeno por ciudad, calle y número para que quede prolijo.
   ===================================== */

CREATE PROCEDURE listar_sucursales
AS
BEGIN
    -- Esto evita que se devuelva "N filas afectadas" en cada SELECT
    SET NOCOUNT ON;

    SELECT
        s.id_sucursal,       -- PK de la sucursal
        s.calle,             -- calle de la sucursal
        s.nro_calle,         -- altura
        s.telefono,          -- teléfono de contacto
        c.nombre AS ciudad   -- nombre de la ciudad (desde tabla Ciudad)
    FROM Sucursal s
    JOIN Ciudad   c ON c.id_ciudad = s.id_ciudad   -- relación sucursal -> ciudad
    ORDER BY ciudad, calle, nro_calle;             -- salida ordenada 
END;

/* =====================================
   PROCEDIMIENTO Listar ventas con sucursal y cliente
   -------------------------------------
   Que hace:
   - Muestra ventas reales (fecha_venta).
   - Resuelve la sucursal de la venta vía Empleado:
   - Para saber en qué sucursal y ciudad se hizo cada venta,
     primero miro qué empleado la hizo (Venta),
     luego en qué sucursal trabaja ese empleado (Empleado → Sucursal),
     y por último, en qué ciudad está esa sucursal (Sucursal → Ciudad).
   - Trae el cliente formateado "Apellido, Nombre"
     usando Cliente -> Persona.
   - Ordena por fecha (desc), ciudad y dirección.
   ===================================== */
CREATE PROCEDURE listar_ventas_con_sucursal
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.id_venta,                  -- PK de la venta
        v.fecha_venta,               -- fecha real de la venta
        s.id_sucursal,               -- sucursal donde trabaja el empleado que vendió
        s.calle       AS sucursal_calle,
        s.nro_calle   AS sucursal_nro,
        c.nombre      AS ciudad,     -- ciudad de esa sucursal
        cli.id_cliente,
        p.apellido + ', ' + p.nombre AS cliente  -- "Apellido, Nombre"
    FROM Venta     v
    JOIN Empleado  e   ON e.id_empleado = v.id_empleado  -- quien vendio
    JOIN Sucursal  s   ON s.id_sucursal = e.id_sucursal  -- su sucursal
    JOIN Ciudad    c   ON c.id_ciudad   = s.id_ciudad    -- ciudad de la sucursal
    JOIN Cliente   cli ON cli.id_cliente = v.id_cliente  -- cliente
    JOIN Persona   p   ON p.id_persona   = cli.id_persona -- datos del cliente
    ORDER BY v.fecha_venta DESC, ciudad, sucursal_calle, sucursal_nro;
END;





----------------- SECCIÓN: FUNCIONES ------------------------
-------------------------------------------------------------
-- Las funciones almacenadas devuelven SIEMPRE un valor.
-- A diferencia de los procedimientos:
--   - No están pensadas para modificar datos.
--   - Se usan en SELECT, WHERE, ORDER BY, etc.
--   - Son ideales para encapsular cálculos o lógicas de verificación.
-------------------------------------------------------------


-------------------------------------------------------------
-- Función: calcularDescuento
-- Propósito: devolver el precio del producto aplicando
--            un porcentaje de descuento.
--
-- Parámetros:
--   @id_producto -> Producto al que se le quiere aplicar el descuento.
--   @porcentaje  -> Porcentaje de descuento (ej: 10 para 10%).
--
-- Retorna:
--   FLOAT con el precio final luego del descuento.
-------------------------------------------------------------
CREATE FUNCTION calcularDescuento (@id_producto INT, @porcentaje FLOAT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @precio FLOAT;

    -- Obtener el precio del producto
    SELECT @precio = precio 
    FROM Producto 
    WHERE id_producto = @id_producto;
    
    -- Retornar el precio con descuento
    RETURN @precio - (@precio * @porcentaje / 100);
END;
GO


-------------------------------------------------------------
-- Función: esStockBajo
-- Propósito: indicar si el stock actual de un producto está
--            por debajo de su stock mínimo.
--
-- Parámetros:
--   @id_producto -> Producto a evaluar.
--
-- Retorna:
--   BIT:
--     1 -> El stock es menor que el mínimo (stock bajo).
--     0 -> El stock es suficiente.
-------------------------------------------------------------
CREATE FUNCTION esStockBajo (@id_producto INT)
RETURNS BIT
AS
BEGIN
    DECLARE @stock INT, 
            @stock_minimo INT;

    -- Obtener los valores de stock y stock_minimo
    SELECT @stock = stock, 
           @stock_minimo = stock_minimo 
    FROM Producto 
    WHERE id_producto = @id_producto;
    
    -- Comparar stock con stock_minimo
    IF @stock < @stock_minimo
        RETURN 1;

    RETURN 0;
END;
GO


-------------------------------------------------------------
-- Función: esProductoActivo
-- Propósito: devolver el estado de un producto en forma de texto.
--
-- Parámetros:
--   @id_producto -> Producto a evaluar.
--
-- Retorna:
--   VARCHAR(10):
--     'Activo'   -> si activo = 1
--     'Inactivo' -> si activo = 0 o NULL
-------------------------------------------------------------
CREATE FUNCTION esProductoActivo (@id_producto INT)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @activo BIT;

    -- Obtener el estado activo del producto
    SELECT @activo = activo 
    FROM Producto 
    WHERE id_producto = @id_producto;
    
    -- Retornar si es activo o inactivo
    IF @activo = 1
        RETURN 'Activo';

    RETURN 'Inactivo';
END;
GO


-------------------------------------------------------------
-- Función: obtenerCategoriaProducto
-- Propósito: obtener el nombre de la categoría a la que
--            pertenece un producto.
--
-- Parámetros:
--   @id_producto -> Producto cuyo nombre de categoría se desea conocer.
--
-- Retorna:
--   VARCHAR(100) con el nombre de la categoría.
-------------------------------------------------------------
CREATE FUNCTION obtenerCategoriaProducto (@id_producto INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @id_categoria      INT;
    DECLARE @nombre_categoria  VARCHAR(100);
    
    -- Obtener id_categoria del producto
    SELECT @id_categoria = id_categoria 
    FROM Producto 
    WHERE id_producto = @id_producto;
    
    -- Obtener el nombre de la categoría
    SELECT @nombre_categoria = nombre 
    FROM Categoria 
    WHERE id_categoria = @id_categoria;
    
    RETURN @nombre_categoria;
END;
GO


-------------------------------------------------------------
-- Función: contarProductosActivos
-- Propósito: devolver la cantidad total de productos
--            que están activos en la base de datos.
--
-- Parámetros:
--   (ninguno)
--
-- Retorna:
--   INT con la cantidad de productos donde activo = 1.
-------------------------------------------------------------
CREATE FUNCTION contarProductosActivos ()
RETURNS INT
AS
BEGIN
    DECLARE @total INT;

    SELECT @total = COUNT(*) 
    FROM Producto 
    WHERE activo = 1;

    RETURN @total;
END;
GO

/* =====================================
   FUNCIÓN fn_total_ventas_global()  
   -------------------------------------
   Qué hace:
   - Devuelve UN solo número (DECIMAL 10,2) con el total global
     de ventas calculado desde el detalle (cantidad * precio_producto).
   - Si no hay ventas, devuelve 0 (ISNULL).
   Notas:
   - Es función escalar, por eso se usa en un SELECT.
   ===================================== */
CREATE FUNCTION fn_total_ventas_global()
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);  -- acumulador

    SELECT
        @total = ISNULL(SUM(dv.cantidad * dv.precio_producto), 0)
    FROM Detalle_Venta dv;          -- sumo todo el detalle (no hay columna "total" en Venta)

    RETURN @total;
END;

/* =====================================
   FUNCIÓN 4) fn_top10_productos()  (TABLA)
   -------------------------------------
   Qué hace:
   - Devuelve una TABLA con el Top 10 de productos por cantidad vendida.
   - Incluye además el importe (cantidad * precio_producto) como referencia.
   - Se usa en FROM, como si fuera una vista: SELECT * FROM fn_top10_productos();
   ===================================== */
CREATE FUNCTION fn_top10_productos()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 10
           p.id_producto,
           p.nombre                               AS producto,
           SUM(dv.cantidad)                       AS cantidad_vendida,
           SUM(dv.cantidad * dv.precio_producto)  AS importe
    FROM Detalle_Venta dv
    JOIN Producto     p ON p.id_producto = dv.id_producto
    GROUP BY p.id_producto, p.nombre
    ORDER BY cantidad_vendida DESC, importe DESC, producto
);

------------------- SECCIÓN: LOTE DE DATOS ------------------
-------------------------------------------------------------
-- En esta sección se cargan datos de prueba de dos maneras:
--
-- 1) INSERT directo sobre las tablas (Categoría y Producto).
-- 2) Inserciones realizadas mediante el procedimiento
--    insertarProducto.
--
-- Esto permite:
--   - Probar el funcionamiento de los procedimientos.
--   - Comparar operaciones directas vs encapsuladas.
-------------------------------------------------------------


-------------------------------------------------------------
-- Carga de categorías de ejemplo.
-- En un trabajo real, estos valores se adaptarían al negocio.
-------------------------------------------------------------
INSERT INTO Categoria (nombre) VALUES 
('Electrónica'),
('Cocina'),
('Baño'),
('Juguetes'),
('Herramientas'),
('Decoración');
GO


-------------------------------------------------------------
-- ALTAS directas de productos con INSERT.
-- Sirven como lote inicial de datos para hacer pruebas
-- con las funciones y procedimientos.
-------------------------------------------------------------
INSERT INTO Producto (nombre, descripcion, precio, stock, stock_minimo, imagen, id_categoria)
VALUES 
('Laptop Gamer', 'Laptop de alto rendimiento para gaming', 1500.00, 10, 2, 'laptop_gamer.jpg', 1),
('Tablet Pro', 'Tablet con pantalla de alta resolución y gran capacidad', 300.00, 25, 5, 'tablet_pro.jpg', 1),
('Microondas Digital', 'Microondas con pantalla táctil y múltiples funciones', 120.00, 15, 3, 'microondas.jpg', 2),
('Juguete Educativo', 'Juego didáctico para niños', 40.00, 100, 20, 'juguete_educativo.jpg', 4),
('Termo Acero Inoxidable', 'Termo resistente al desgaste', 25.00, 50, 10, 'termo.jpg', 2),
('Auriculares Bluetooth', 'Auriculares inalámbricos de alta calidad', 80.00, 30, 5, 'auriculares.jpg', 1),
('Plancha de Ropa', 'Plancha a vapor con sistema antical', 35.00, 20, 5, 'plancha.jpg', 2),
('Set de Ollas', 'Juego de ollas antiadherentes', 90.00, 15, 3, 'ollas.jpg', 2),
('Reproductor MP3', 'Reproductor compacto y portátil', 50.00, 60, 10, 'mp3.jpg', 1),
('Peluche Gigante', 'Peluche de gran tamaño y suavidad', 25.00, 40, 5, 'peluche.jpg', 4),
('Cámara de Seguridad', 'Cámara IP con visión nocturna', 110.00, 10, 2, 'camara_seguridad.jpg', 1),
('Batidora Manual', 'Batidora con múltiples velocidades', 20.00, 35, 8, 'batidora.jpg', 2),
('Teléfono Inalámbrico', 'Teléfono fijo inalámbrico con pantalla digital', 45.00, 12, 4, 'telefono.jpg', 1),
('Taza Personalizada', 'Taza de cerámica con diseño único', 10.00, 80, 10, 'taza.jpg', 2),
('Lámpara LED', 'Lámpara de alta eficiencia energética', 15.00, 70, 15, 'lampara.jpg', 1),
('Cuchillos Profesionales', 'Set de cuchillos de chef', 75.00, 25, 4, 'cuchillos.jpg', 2),
('Robot de Cocina', 'Electrodoméstico multifunción', 200.00, 8, 2, 'robot_cocina.jpg', 2),
('Juego de Cubiertos', 'Cubiertos de acero inoxidable', 20.00, 50, 8, 'cubiertos.jpg', 2),
('Consola Retro', 'Consola con juegos clásicos', 130.00, 15, 3, 'consola.jpg', 1),
('Bolso Deportivo', 'Bolso amplio y resistente', 30.00, 40, 6, 'bolso.jpg', 3),
('Calculadora Científica', 'Calculadora de múltiples funciones', 25.00, 50, 8, 'calculadora.jpg', 1),
('Bicicleta Infantil', 'Bicicleta con ruedas de entrenamiento', 150.00, 20, 5, 'bicicleta.jpg', 4),
('Estufa Eléctrica', 'Estufa de bajo consumo', 45.00, 25, 5, 'estufa.jpg', 2),
('Reloj Deportivo', 'Reloj con medición de actividad física', 35.00, 30, 10, 'reloj.jpg', 1),
('Teclado Mecánico', 'Teclado gamer de alto rendimiento', 75.00, 20, 4, 'teclado.jpg', 1);
GO


-------------------------------------------------------------
-- ALTAS a través del procedimiento insertarProducto.
-- Demuestran cómo encapsular el INSERT en un procedimiento
-- en lugar de escribir la sentencia directamente.
-------------------------------------------------------------
EXEC insertarProducto 'Monitor 4K', 'Monitor de alta resolución con 4K UHD', 300.00, 15, 3, 'monitor_4k.jpg', 1;
EXEC insertarProducto 'Cafetera Espresso', 'Cafetera automática de última generación', 150.00, 25, 4, 'cafetera.jpg', 2;
EXEC insertarProducto 'Zapatillas Running', 'Calzado deportivo de alto rendimiento', 80.00, 50, 10, 'zapatillas.jpg', 3;
EXEC insertarProducto 'Juego de Sartenes', 'Sartenes con recubrimiento antiadherente', 50.00, 30, 5, 'sartenes.jpg', 2;
EXEC insertarProducto 'Parlante Bluetooth', 'Parlante portátil con sonido estéreo', 60.00, 40, 10, 'parlante.jpg', 1;
EXEC insertarProducto 'Impresora Multifunción', 'Impresora con función de escaneo y copia', 120.00, 10, 2, 'impresora.jpg', 1;
EXEC insertarProducto 'Cámara Reflex', 'Cámara fotográfica de lentes intercambiables', 450.00, 5, 1, 'camara_reflex.jpg', 1;
EXEC insertarProducto 'Tenedor y Cuchara XXL', 'Set de cubiertos grandes para asado', 35.00, 40, 8, 'cubiertos_xxl.jpg', 2;
EXEC insertarProducto 'Termómetro Digital', 'Termómetro infrarrojo para adultos y niños', 20.00, 60, 15, 'termometro.jpg', 2;
EXEC insertarProducto 'Almohada Viscoelástica', 'Almohada ergonómica y adaptable', 25.00, 30, 5, 'almohada.jpg', 4;
EXEC insertarProducto 'Mochila Escolar', 'Mochila con múltiples compartimientos', 40.00, 50, 10, 'mochila.jpg', 3;
EXEC insertarProducto 'Grill Eléctrico', 'Parrilla portátil para interiores', 70.00, 20, 5, 'grill.jpg', 2;
EXEC insertarProducto 'Cargador Rápido', 'Cargador para dispositivos móviles', 15.00, 80, 20, 'cargador.jpg', 1;
EXEC insertarProducto 'Toalla de Playa', 'Toalla grande y absorbente', 20.00, 35, 5, 'toalla.jpg', 4;
EXEC insertarProducto 'Sillón Reclinable', 'Sillón ergonómico y cómodo', 200.00, 5, 1, 'sillon.jpg', 4;
EXEC insertarProducto 'Estuche para Gafas', 'Estuche rígido y protector', 10.00, 100, 25, 'estuche_gafas.jpg', 4;
EXEC insertarProducto 'Set de Herramientas', 'Herramientas para el hogar y el auto', 85.00, 15, 3, 'herramientas.jpg', 2;
EXEC insertarProducto 'Tarjeta de Memoria', 'Memoria microSD con gran capacidad', 25.00, 70, 15, 'tarjeta_sd.jpg', 1;
EXEC insertarProducto 'Linterna LED', 'Linterna recargable de larga duración', 30.00, 60, 10, 'linterna.jpg', 1;
EXEC insertarProducto 'Kit de Limpieza', 'Kit completo para limpieza del hogar', 45.00, 40, 10, 'kit_limpieza.jpg', 2;
EXEC insertarProducto 'Gafas de Sol', 'Gafas polarizadas para exteriores', 35.00, 50, 12, 'gafas.jpg', 3;
EXEC insertarProducto 'Balón de Fútbol', 'Balón profesional de alta resistencia', 50.00, 20, 5, 'balon.jpg', 4;
EXEC insertarProducto 'Mesa de Camping', 'Mesa plegable y ligera', 75.00, 10, 2, 'mesa.jpg', 4;
EXEC insertarProducto 'Cuchillo Santoku', 'Cuchillo japonés multiuso', 45.00, 25, 5, 'cuchillo_santoku.jpg', 2;
EXEC insertarProducto 'Botella Reutilizable', 'Botella de acero inoxidable', 20.00, 30, 8, 'botella.jpg', 4;
GO


-------------------------------------------------------------
-- Ejemplos de uso de procedimientos para UPDATE y DELETE
-------------------------------------------------------------

-- MODIFICACIÓN a través del procedimiento
EXEC modificarProducto 1, 'Laptop Gamer Nueva', 'Laptop de alto rendimiento para gaming', 1600.00, 10, 2, 'laptop_gamer.jpg', 1;

EXEC modificarProducto 2, 'Tablet Pro Nueva', 'Tablet con pantalla de alta resolución y gran capacidad', 350.00, 25, 5, 'tablet_pro.jpg', 1;

-- BAJA FÍSICA a través del procedimiento
EXEC borrarProducto 3;

-- BAJA LÓGICA y ALTA LÓGICA a través de los procedimientos
EXEC bajaLogicaProducto 2; -- Desactiva el producto con id_producto = 2
EXEC altaLogicaProducto 2; -- Reactiva el producto con id_producto = 2
GO


-------------------------------------------------------------
-- CONSULTAS DE APOYO / LISTADOS
-------------------------------------------------------------

-- Listar todas las categorías
SELECT * FROM Categoria;

-- Listar todos los productos
SELECT * FROM Producto;

-- Listar procedimientos creados en la base
SELECT * FROM sys.procedures;

-- Listar funciones definidas por el usuario (escalares, de tabla, etc.)
SELECT name, type_desc 
FROM sys.objects 
WHERE type IN ('FN', 'TF', 'IF');
GO


-------------------------------------------------------------
-- Ejemplos de ejecución de funciones almacenadas
-------------------------------------------------------------

-- Aplicar un 10% de descuento al producto con id_producto = 1
SELECT precio,
       dbo.calcularDescuento(1, 10) AS PrecioConDescuento
FROM Producto 
WHERE id_producto = 1;

-- Verificar si el stock del producto con id_producto = 1 es bajo
SELECT dbo.esStockBajo(1) AS EsStockBajo; -- Resultado esperado: 0 o 1 según datos
SELECT dbo.esStockBajo(2) AS EsStockBajo; -- Segundo ejemplo

-- Verificar si el producto con id_producto = 1 está activo
SELECT dbo.esProductoActivo(1) AS EstadoProducto;

-- Obtener la categoría del producto con id_producto = 1
SELECT dbo.obtenerCategoriaProducto(1) AS CategoriaProducto;

-- Obtener el total de productos activos
SELECT dbo.contarProductosActivos() AS CantidadProductos;
GO


-------------------------------------------------------------
-- COMENTARIO FINAL 
-- Las funciones se pueden utilizar dentro de un SELECT porque
-- devuelven un valor (igual que SUM(), AVG(), etc).
-- Los procedimientos, en cambio, se ejecutan con EXEC y están
-- pensados para realizar acciones (INSERT, UPDATE, DELETE).
--
-- El objetivo de crear procedimientos de ABM es:
--   - Encapsular la lógica de acceso a datos.
--   - Controlar permisos a nivel de procedimiento.
--   - Evitar errores graves, como borrar o actualizar registros
--     sin un criterio correcto.
-------------------------------------------------------------






