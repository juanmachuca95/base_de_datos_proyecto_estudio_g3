
/*Realizar una carga masiva de por lo menos un millón de registro sobre alguna tabla
que contenga un campo fecha (sin índice). Hacerlo con un script para poder automatizarlo.*/
SET NOCOUNT ON;

DECLARE @i INT = 0;

WHILE @i < 1000000
BEGIN
    IF @i % 1000 = 0
    BEGIN
        PRINT 'Insertando fila ' + CAST(@i AS VARCHAR(20));
        BEGIN TRANSACTION;
    END

    -- Inserta datos aleatorios 
    INSERT INTO Venta (
        fecha_venta,
        id_cliente,
        id_empleado,
        id_metodo_pago
    )
    VALUES (
        -- Fechas aleatorias en los últimos 3 años
        DATEADD(day, - (CAST(RAND(CHECKSUM(NEWID())) * 1095 AS INT)), GETDATE()),
        -- id_cliente aleatorio entre 1 y 6
        CAST(RAND(CHECKSUM(NEWID())) * 6 AS INT) + 1,
        -- id_empleado aleatorio entre 1 y 7
        CAST(RAND(CHECKSUM(NEWID())) * 7 AS INT) + 1,
        -- id_metodo_pago aleatorio entre 1 y 5
        CAST(RAND(CHECKSUM(NEWID())) * 5 AS INT) + 1
    );

    SET @i = @i + 1;

    IF @i % 1000 = 0
    BEGIN
        COMMIT TRANSACTION;
    END
END;

SET NOCOUNT OFF;
GO

-- Verifica la cantidad de filas
SELECT COUNT(*) AS TotalFilas FROM Venta;
GO

-- Ver tdoas las ventas
SELECT *
FROM venta;


/*
Realizar una búsqueda por periodo y registrar el plan de ejecución 
utilizado por el motor y los tiempos de respuesta.
*/

-- Limpia caché y activa las estadísticas
DBCC DROPCLEANBUFFERS;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Búsqueda por periodo 
SELECT fecha_venta, id_cliente, id_empleado
FROM Venta
WHERE fecha_venta BETWEEN '2024-01-01' AND '2024-12-31';
GO

-- Desactiva las estadísticas para no afectar futuras consultas
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
/*
Definir un índice agrupado sobre la columna fecha y repetir la consulta anterior.
Registrar el plan de ejecución utilizado por el motor y los tiempos de respuesta.
*/

-- Borra la FOREIGN KEY de la tabla "hija" (Detalle_Venta)
ALTER TABLE Detalle_Venta DROP CONSTRAINT FK_Detalle_Venta_Venta;
GO

-- Borra la PRIMARY KEY de la tabla "madre" (Venta)
ALTER TABLE Venta DROP CONSTRAINT PK_Venta;
GO

--Crea el nuevo índice agrupado en la fecha 
CREATE CLUSTERED INDEX CX_Venta_FechaVenta ON Venta(fecha_venta);
GO

-- Medición 
DBCC DROPOLEANBUFFERS;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT fecha_venta, id_cliente, id_empleado
FROM Venta
WHERE fecha_Venta BETWEEN '2024-01-01' AND '2024-12-31';
GO

/*
Borrar el índice creado
*/

-- Borra el índice agrupado de fecha
DROP INDEX CX_Venta_FechaVenta ON Venta;
GO
-- Restaura la Primary Key original (madre)
ALTER TABLE Venta ADD CONSTRAINT PK_Venta PRIMARY KEY CLUSTERED (id_venta);
GO

--  Restaura la Foreign Key (hija)
ALTER TABLE Detalle_Venta ADD CONSTRAINT FK_Detalle_Venta_Venta
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta);
GO

/*
Definir otro índice agrupado sobre la columna fecha pero que además incluya las columnas
seleccionadas y repetir la consulta anterior. Registrar el plan de ejecución utilizado por
el motor y los tiempos de respuesta.
*/

-- Borra si existe de una prueba anterior
DROP INDEX IF EXISTS IX_Venta_Fecha_Covering ON Venta;
GO

-- Crea el indice
CREATE NONCLUSTERED INDEX IX_Venta_Fecha_Covering
ON Venta(fecha_venta) 
INCLUDE (id_cliente, id_empleado); 
GO

-- Medición 
DBCC DROPOLEANBUFFERS;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Consulta de prueba
SELECT fecha_venta, id_cliente, id_empleado
FROM Venta
WHERE fecha_venta BETWEEN '2024-01-01' AND '2024-01-31';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
