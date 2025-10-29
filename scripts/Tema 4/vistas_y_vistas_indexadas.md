# Vistas y Vistas Indexadas

## 1. Contexto General (Vistas y Vistas Indexadas)

### 1.1 Vistas (Views)

Una Vista es una **tabla virtual** cuyo contenido está definido por una consulta (una sentencia `SELECT`). Las vistas no almacenan datos por sí mismas; en su lugar, la base de datos ejecuta la consulta subyacente cada vez que se hace referencia a la vista, presentando el resultado como si fuera una tabla.

Las vistas son fundamentales para:
1.  **Seguridad:** Permiten a los administradores restringir el acceso a ciertas columnas o filas de las tablas base, mostrando solo la información necesaria para un usuario o perfil específico (como el perfil de `vendedor` o `gerente` en **Gestor Franquicias**).

2.  **Simplificación:** Ocultan la complejidad de las uniones (`JOINs`) o cálculos complejos, permitiendo a los desarrolladores o usuarios consultar datos complejos con una sintaxis simple.
3.  **Consistencia:** Aseguran que las consultas utilizadas con frecuencia mantengan una lógica uniforme.

### 1.2 Vistas Indexadas (Indexed Views)

Una Vista Indexada (también conocidas como *Vistas Materializadas* en algunos sistemas de gestión de bases de datos, como Oracle o PostgreSQL, o implementadas con `WITH SCHEMABINDING` y un índice *clustered* en SQL Server) es una vista que **almacena físicamente el resultado de su consulta subyacente** en la base de datos.

Al igual que un índice en una tabla, el resultado almacenado se mantiene automáticamente a medida que se modifican los datos en las tablas base. Esto permite que la base de datos acceda a los resultados precalculados de la vista en lugar de reejecutar la consulta, lo que proporciona una **mejora drástica en el rendimiento** para consultas intensivas en recursos.

## 2. Aplicaciones y Ejemplos en el Mundo Real

El uso de vistas y vistas indexadas es vital en sistemas diseñados para manejar informes detallados y optimizar consultas, como es el caso de **Gestor Franquicias**, cuyo objetivo es proveer informes detallados que permitan analizar el rendimiento de ventas y el comportamiento del inventario, y optimizar la búsqueda de facturas de venta.

### 2.1 Casos de Aplicación de Vistas

#### A. Simplificación y Seguridad en Reportes Gerenciales
El sistema **Gestor Franquicias** debe permitir que el gerente general supervise el rendimiento de las ventas y acceda a informes detallados. Sin embargo, la información de ventas involucra múltiples tablas (`Venta`, `Detalle_Venta`, `Producto`, `Cliente`, `Empleado`, `Persona`, `Sucursal`).

*   **Uso de Vista:** Se puede crear una vista que consolide todos estos *JOINs* complejos en una sola "tabla virtual" fácil de consultar. Esta vista puede incluir solo los campos relevantes para el gerente (nombre del vendedor, monto total, producto vendido, sucursal), sin exponer campos sensibles de otras tablas, como las claves (`clave`) de los empleados o la información de auditoría no relevante para el informe.

### 2.2 Casos de Aplicación de Vistas Indexadas

#### A. Optimización de Búsqueda y Reportes Consolidados
Uno de los problemas identificados en el proyecto es la dificultad para obtener **reportes consolidados y precisos a nivel de franquicia**. Además, se busca optimizar los procesos de búsqueda y recuperación de facturas de venta y asegurar que la búsqueda sea **eficiente y rápida**.

*   **Uso de Vista Indexada (Ejemplo del Mundo Real):** Para consolidar el rendimiento general, se puede crear una vista indexada que **precalcule el monto total de ventas por sucursal y por mes**. Si la gerencia consulta esta métrica diariamente, una vista indexada evita que la base de datos tenga que recalcular billones de filas en las tablas `Venta` y `Detalle_Venta` cada vez. La vista indexada almacena el resultado final agregado, logrando una respuesta *casi instantánea*, cumpliendo así con el objetivo de optimizar las consultas.

## 3. Script SQL para Implementación de Vistas

Para el sistema **Gestor Franquicias**, se propone una vista estándar para facilitar los reportes de ventas y una vista indexada para optimizar los reportes de rendimiento total por sucursal.

El modelo relacional incluye tablas como `Venta`, `Detalle_Venta`, `Producto`, `Cliente`, `Empleado`, `Persona`, `Sucursal`, y `Ciudad`.

***Aviso Importante:*** El script asume la sintaxis T-SQL (SQL Server) ya que el término "Vista Indexada" y su implementación específica (como el uso de `SCHEMABINDING`) es característico de ese entorno, y es común en el desarrollo de sistemas con énfasis en la optimización de rendimiento.

### 3.1 Vista Estándar: `Vw_Detalle_Factura`

Esta vista está diseñada para **optimizar los procesos de búsqueda y recuperación de facturas de venta**, combinando la información clave de la venta, el cliente y el empleado que la realizó, así como la ubicación de la sucursal.

```sql
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
    Sucursal SUC ON E.id_sucursal = SUC.id_sucursal -- Sucursal donde trabaja el Empleado;
```

### 3.2 Vista Indexada: `VwIdx_Ventas_Agregadas_Sucursal`

Esta vista indexada está diseñada para **facilitar la supervisión del rendimiento general** y **proporcionar reportes detallados** sobre ventas a nivel gerencial, calculando el monto total vendido por cada sucursal. Al ser indexada, optimiza significativamente la consulta de este indicador de rendimiento clave.

**Pasos requeridos para una Vista Indexada (T-SQL):**

1.  La vista debe crearse con la opción `WITH SCHEMABINDING` para asegurar que las tablas base no puedan ser modificadas de manera que afecten la vista.
2.  Debe incluir agregaciones (como `SUM` o `COUNT_BIG`) (Información externa).
3.  Se debe crear un índice `UNIQUE CLUSTERED` en la vista para materializar los datos.

```sql
-- =================================================================
-- VISTA INDEXADA: VwIdx_Ventas_Agregadas_Sucursal
-- Propósito: Precalcular el total de ingresos (suma de subtotales) por cada sucursal.
-- Esto optimiza la generación de informes consolidados de rendimiento gerencial.
-- =g================================================================
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
/*
SELECT
    calle,
    Total_Ingresos,
    Cantidad_Total_Ventas
FROM
    VwIdx_Ventas_Agregadas_Sucursal
WHERE
    id_sucursal = 1;
*/
```