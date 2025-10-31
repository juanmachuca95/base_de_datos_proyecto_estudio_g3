/* -------------------------------------
   TEMA 1 - Procedimientos y funciones almacenadas
   GRUPO 3
   -------------------------------------
   En este archivo dejo dos procedimientos y dos funciones
   simples del modelo GestorFranquicias:
   - listar_sucursales
   - listar_ventas_con_sucursal
   - fn_total_ventas_global()         (función que devuelve un solo valor que se le dice escalar)
   - fn_top10_productos()             (función con valor de tabla)
   ------------------------------------- */
/* =====================================
   PROCEDIMIENTO 1) Listar sucursales con su ciudad
   -------------------------------------
   Qué hace: trae todas las sucursales con dirección, teléfono
   y el nombre de la ciudad (unido por id_ciudad).
   Ordeno por ciudad, calle y número para que quede prolijo.
   ===================================== */
CREATE PROCEDURE listar_sucursales
AS
BEGIN
    -- Eesto evita que se devuelva "N filas afectadas" en cada SELECT
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
   PROCEDIMIENTO 2) Listar ventas con sucursal y cliente
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


/* =====================================
   FUNCIÓN 3) fn_total_ventas_global()  
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
