-----------------------------------
-- VISTAS SQL
-----------------------------------

USE GestorFranquiciasDB;
GO

-- =================================================================
-- VISTA ESTÁNDAR: Vw_Detalle_Factura
-- Propósito: Simplificar la consulta de ventas mostrando el detalle
-- completo de la transacción, incluyendo cliente, vendedor y sucursal.
-- Esto ayuda a proveer informes detallados y optimizar la búsqueda.
-- Tablas involucradas: Venta, Detalle_Venta, Producto, Cliente, Empleado, Persona, Sucursal.
-- =================================================================
CREATE VIEW Vw_Detalle_Factura
AS
SELECT
    V.id_venta,
    V.date_create AS Fecha_Venta, -- Indica la fecha y hora de la venta
    P_C.nombre AS Nombre_Cliente,
    P_C.apellido AS Apellido_Cliente,
    P_E.nombre AS Nombre_Vendedor,
    P_E.apellido AS Apellido_Vendedor,
    SUC.calle + ' ' + CAST(SUC.nro_calle AS VARCHAR(10)) AS Domicilio_Sucursal,
    PROD.nombre AS Nombre_Producto,
    DV.cantidad, -- Indica la cantidad de productos vendidos
    DV.precio_producto AS Precio_Unitario, -- Indica el precio del producto al momento de la venta
    (DV.cantidad * DV.precio_producto) AS Subtotal_Linea
FROM
    Venta V
JOIN
    Detalle_Venta DV ON V.id_venta = DV.id_venta -- Relación de Venta y su Detalle
JOIN
    Producto PROD ON DV.id_producto = PROD.id_producto -- Productos vendidos
JOIN
    Cliente C ON V.id_cliente = C.id_cliente -- Cliente que realizó la compra
JOIN
    Persona P_C ON C.id_persona = P_C.id_persona -- Información de la Persona del Cliente
JOIN
    Empleado E ON V.id_empleado = E.id_empleado -- Empleado que realizó la venta
JOIN
    Persona P_E ON E.id_persona = P_E.id_persona -- Información de la Persona del Empleado
JOIN
    Sucursal SUC ON E.id_sucursal = SUC.id_sucursal; -- Sucursal donde trabaja el Empleado
GO

-- Ejemplo de vista
SELECT * FROM Vw_Detalle_Factura;
GO

-- =================================================================
-- VISTA INDEXADA: VwIdx_Ventas_Agregadas_Sucursal
-- Propósito: Precalcular el total de ingresos (suma de subtotales) por cada sucursal.
-- Esto optimiza la generación de informes consolidados de rendimiento gerencial.
-- ==================================================================

-- 1. Crear la Vista con SCHEMABINDING (Obligatorio para Indexación)
IF OBJECT_ID ('VwIdx_Ventas_Agregadas_Sucursal') IS NOT NULL
    DROP VIEW VwIdx_Ventas_Agregadas_Sucursal;
GO

CREATE VIEW VwIdx_Ventas_Agregadas_Sucursal
WITH SCHEMABINDING
AS
SELECT
    E.id_sucursal, -- Identificación única de la Sucursal
    S.calle,       -- Nombre de la calle de la sucursal
    COUNT_BIG(*) AS Cantidad_Total_Ventas, -- Conteo total de ventas (requiere COUNT_BIG para indexación)
    SUM(DV.cantidad * DV.precio_producto) AS Total_Ingresos -- Cálculo de Ingresos Totales
FROM
    dbo.Venta V -- Se requiere prefijo de esquema con SCHEMABINDING
JOIN
    dbo.Detalle_Venta DV ON V.id_venta = DV.id_venta -- Detalle de productos vendidos
JOIN
    dbo.Empleado E ON V.id_empleado = E.id_empleado -- Empleado que realizó la venta
JOIN
    dbo.Sucursal S ON E.id_sucursal = S.id_sucursal -- Sucursal a la que pertenece el empleado
GROUP BY
    E.id_sucursal,
    S.calle;
GO

-- 2. Crear el Índice Único Clustered (Obligatorio para Materialización)
-- Esto materializa la vista y la convierte en una Vista Indexada.
CREATE UNIQUE CLUSTERED INDEX IX_Ventas_Sucursal
ON VwIdx_Ventas_Agregadas_Sucursal (id_sucursal);
GO

-- Script de Ejecución de Ejemplo (No genera datos, solo muestra cómo consultarla)
SELECT
    calle,
    Total_Ingresos,
    Cantidad_Total_Ventas
FROM
    VwIdx_Ventas_Agregadas_Sucursal
WHERE
    id_sucursal = 1;
GO