
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

    -- Insertamos datos aleatorios 
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
PRINT 'Carga masiva completada.';
SET NOCOUNT OFF;
GO

-- Verificamos la cantidad de filas
SELECT COUNT(*) AS TotalFilas FROM Venta;
GO

-- Vemos tdoas las ventas
SELECT *
FROM venta;