/* =======================================================
   TEMA 1 - PRUEBAS DE PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
   GRUPO 3
   Base de datos: GestorFranquiciasDB
   -------------------------------------------------------
 
   ======================================================= */

-- Primero y mas importante verifico que estoy trabajando en la bd correcta
USE GestorFranquiciasDB;
GO

/* =======================================================
   SECCIÓN A - PROCEDIMIENTOS ALMACENADOS
   -------------------------------------------------------
   Los procedimientos se ejecutan con EXEC.
   No devuelven un valor único, sino un conjunto de filas
   (como si fueran consultas guardadas).
   ======================================================= */

-- 1) Listar todas las sucursales con su ciudad
-- Muestra: id_sucursal, calle, número, teléfono y nombre de la ciudad.
EXEC listar_sucursales;
GO

-- 2) Listar todas las ventas con información de la sucursal y el cliente
-- Muestra: id_venta, fecha_venta, sucursal (calle y nro),
-- ciudad y nombre del cliente formateado "Apellido, Nombre".
EXEC listar_ventas_con_sucursal;
GO


/* =======================================================
   SECCIÓN B - FUNCIONES ALMACENADAS
   -------------------------------------------------------
   Las funciones se ejecutan dentro de un SELECT.
   - Las escalares devuelven un solo valor.
   - Las que retornan tabla se consultan con SELECT * FROM.
   ======================================================= */

-- 3) Total global de ventas (valor único)
-- Función escalar: calcula la suma total (cantidad * precio) de toda la base.
-- Devuelve un solo número (DECIMAL 10,2).
SELECT dbo.fn_total_ventas_global() AS total_global;
GO


-- 4) Top 10 productos más vendidos (tabla)
-- Función con valor de tabla: devuelve los 10 productos más vendidos
-- con su cantidad total e importe acumulado.
SELECT *
FROM dbo.fn_top10_productos();
GO
