
-- Ejemplo de una transacción de confirmación automática			
		
-- Insertar un nuevo perfil de usuario para un rol (ej. 'Gerente')
-- La inserción se confirma inmediatamente al ejecutarse.
INSERT INTO Perfil (nombre, activo) VALUES ('Gerente', 1);

-- Actualizar el stock mínimo de un producto
-- La actualización se confirma inmediatamente.
UPDATE Producto SET stock_minimo = 5 WHERE id_producto = 50;


-- Ejemplo de una transacción explícita	
-- La operación se inicia y se confirma (COMMIT) o revierte (ROLLBACK) manualmente.

BEGIN TRY
	BEGIN TRANSACTION;
		
		-- Declaración de variables dentro del lote
		DECLARE @VentaID INT;
		DECLARE @ProductoID_Venta INT = 10; -- Cambiamos el nombre para evitar conflicto
		DECLARE @Cantidad_Venta INT = 2;

		INSERT INTO Venta (fecha_venta, date_create, user_create, id_cliente, id_empleado, id_metodo_pago)
		VALUES (GETDATE(), GETDATE(), 'usuario_actual', 15, 8, 1);
		SET @VentaID = SCOPE_IDENTITY();
	
		-- Descontar el stock del producto
		UPDATE Producto
		SET stock = stock - @Cantidad_Venta
		WHERE id_producto = @ProductoID_Venta;

		-- Insertar el detalle de la venta
		INSERT INTO Detalle_Venta (id_venta, id_producto, cantidad, precio_producto)
		VALUES (@VentaID, @ProductoID_Venta, @Cantidad_Venta, 45.99);

		COMMIT TRANSACTION;
		PRINT 'Transacción (Venta y Stock) completada con éxito';

END TRY
BEGIN CATCH
		ROLLBACK TRANSACTION;
		PRINT 'Error en la transacción. Operación (Venta) revertida.';
		-- Redefinimos la variable localmente si es necesario, o usamos el mensaje directamente
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE(); 
		PRINT @ErrorMsg;
END CATCH;
GO

-- Ejemplo de una transacción implícita	
		
SET IMPLICIT_TRANSACTIONS ON;

-- Inicia automáticamente una transacción (INSERT)
INSERT INTO Metodo_pago (nombre, proveedor) VALUES ('Transferencia', 'Banco A');

-- Confirmar la primera transacción manualmente
COMMIT TRANSACTION;

-- Inicia automáticamente otra transacción (UPDATE)
UPDATE Empleado SET sueldo = 100000 WHERE id_empleado = 10;

-- Revertir la segunda transacción manualmente en caso de error
ROLLBACK TRANSACTION;

SET IMPLICIT_TRANSACTIONS OFF;



-- Ejemplo de una transacción en ámbito de lote		

BEGIN TRANSACTION;

-- Insertar una nueva Ciudad y obtener su ID
DECLARE @CiudadID INT;
INSERT INTO Ciudad (nombre, cod_postal) VALUES ('Resistencia', '3500');
SET @CiudadID = SCOPE_IDENTITY();

-- Insertar una nueva Sucursal que depende de esa Ciudad
INSERT INTO Sucursal (telefono, calle, nro_calle, activo, id_ciudad) 
VALUES ('3794123456', 'San Martin', '1234', 1, @CiudadID);

-- Si el lote finaliza sin un COMMIT o ROLLBACK explícito,
-- SQL Server revertirá automáticamente la transacción.

-- Confirmar la transacción manualmente
COMMIT TRANSACTION;



-- Ejemplo de una transacción explicita

BEGIN TRY
		BEGIN TRANSACTION;
			DECLARE @PersonaID_Cliente INT; -- Cambiamos el nombre
			INSERT INTO Persona (nombre, apellido, dni, telefono, email, fecha_nacimiento)
			VALUES ('Roberto', 'Fuentes', 35123456, '3794112233', 'roberto.f@ejemplo.com', '1980-05-15');
			SET @PersonaID_Cliente = SCOPE_IDENTITY();
		
			-- Insertar el registro de Cliente, dependiente de Persona
			INSERT INTO Cliente (id_persona, activo) VALUES (@PersonaID_Cliente, 1);

			COMMIT TRANSACTION;
			PRINT 'Transacción (Alta de Cliente) completada con éxito';
	END TRY
	BEGIN CATCH
			ROLLBACK TRANSACTION;
			PRINT 'Error en la transacción. Operación revertida.';
			DECLARE @ErrorMsg2 NVARCHAR(4000) = ERROR_MESSAGE(); -- Nuevo nombre de variable
			PRINT @ErrorMsg2;
	END CATCH;
GO

-- Ejemplo de un transacción anidada

	BEGIN TRY
		BEGIN TRANSACTION;  -- Transacción principal: Registrar Producto y Actualizar Empleado

			-- 1. Primera operación: Insertar una nueva Categoria
			DECLARE @CatID INT;
			INSERT INTO Categoria (nombre, activo) VALUES ('Electrodomestico', 1);
			SET @CatID = SCOPE_IDENTITY();

			-- Transacción anidada: Insertar Producto
			BEGIN TRANSACTION;  

			-- 2. Segunda operación (dentro de la transacción anidada): Insertar el Producto
			INSERT INTO Producto (nombre, descripcion, precio, stock, stock_minimo, id_categoria) 
			VALUES ('Batidora Grande', 'Uso profesional', 5500.00, 20, 5, @CatID);
			
			-- Provocar un error después del insert para simular una falla 
			-- THROW 50001, 'Error simulado al insertar producto', 1;

			-- Confirmación de la transacción anidada
			COMMIT TRANSACTION;  

			-- 3. Tercera operación: Actualizar sueldo de un Empleado (independiente de la anidada)
			UPDATE Empleado SET sueldo = sueldo + 5000 WHERE id_empleado = 101; 

			-- Confirmación de la transacción principal
			COMMIT TRANSACTION;
			PRINT 'Transacción completada con éxito: Categoria, Producto y Sueldo actualizados.';

	END TRY
	BEGIN CATCH
			-- En caso de error, se revierte toda la transacción
			ROLLBACK TRANSACTION;
			PRINT 'Error en la transacción. Operación revertida.';
	END CATCH;
	

-- Ejemplo de actualizacion de datos de la tabla Empleado

	BEGIN TRY
		BEGIN TRAN -- Inicia la transacción
		
		DECLARE @EmpleadoID INT = 25;
		DECLARE @NuevoSueldo MONEY = 85000.00;

		UPDATE Empleado SET sueldo = @NuevoSueldo WHERE id_empleado = @EmpleadoID;
		
		-- Provocar un error después del update para simular una falla 
		-- (Descomentar la línea siguiente para probar el ROLLBACK)
		-- THROW 50001, 'Error simulado: Falla al registrar el cambio de sueldo', 1;
		
		COMMIT TRAN -- Confirma la actualización si no hubo errores
		PRINT 'Sueldo del Empleado ' + CAST(@EmpleadoID AS NVARCHAR) + ' actualizado a ' + CAST(@NuevoSueldo AS NVARCHAR) + '.';

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN; -- Revierte si ocurre un error
		PRINT 'Error en la transacción. Operación de actualización de sueldo revertida.';
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT 'Mensaje de Error: ' + @ErrorMessage;
	END CATCH

-- Ejemplo de una transacción de confirmación automático			
				
GO

-- Insertar un nuevo perfil de usuario para un rol ('Supervisor de Stock')
INSERT INTO Perfil (nombre, activo) 
VALUES ('Supervisor Stock', 1);

-- Actualizar el horario de salida de un empleado
UPDATE Empleado 
SET hora_salida = '18:30:00' 
WHERE id_empleado = 15;

-- Ejemplo de una transacción explícita	
-- Ambos INSERT deben ser exitosos o se revierte la operación completa.
GO

BEGIN TRY
	BEGIN TRANSACTION;
		
		-- 1. Insertar la nueva persona
		DECLARE @PersonaID INT;
		INSERT INTO Persona (nombre, apellido, dni, telefono, email, fecha_nacimiento, date_create, user_create)
		VALUES ('Carla', 'Lopez', 38990123, '3794123456', 'carla.lopez@mail.com', '1995-08-20', GETDATE(), SUSER_SNAME());
		SET @PersonaID = SCOPE_IDENTITY();
	
		-- **Simular un error aquí (si la clave PRIMARY KEY o UNIQUE falla)**
		-- THROW 50001, 'Error simulado despues de insertar Persona', 1;

		-- 2. Insertar el cliente, usando el ID de la persona
		INSERT INTO Cliente (activo, id_persona) 
		VALUES (1, @PersonaID);

		-- 3. Confirmar la transacción
		COMMIT TRANSACTION;
		PRINT 'Transacción (Alta de Cliente) completada con éxito';

END TRY
BEGIN CATCH
		-- Revertir si Persona o Cliente fallan
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		PRINT 'Error en la transacción. Operación de alta de cliente revertida.';
		DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
		PRINT @ErrorMsg;
END CATCH;

-- Ejemplo de una transacción implícita	
		
GO
		
SET IMPLICIT_TRANSACTIONS ON;

-- Inicia automáticamente una transacción (INSERT)
INSERT INTO Metodo_pago (nombre, proveedor) 
VALUES ('Criptomoneda', 'ProveedorX');

-- Confirmar la primera transacción manualmente
COMMIT TRANSACTION;

-- Inicia automáticamente otra transacción (UPDATE)
UPDATE Perfil 
SET nombre = 'Vendedor Senior' 
WHERE nombre = 'Vendedor'; -- Asumiendo que 'Vendedor' existe

-- Revertir la segunda transacción manualmente
ROLLBACK TRANSACTION;

SET IMPLICIT_TRANSACTIONS OFF;


-- Ejemplo de una transacción en ámbito de lote		

GO

BEGIN TRANSACTION;

-- 1. Insertar una nueva Ciudad
DECLARE @CiudadID INT;
INSERT INTO Ciudad (nombre, cod_postal) 
VALUES ('Corrientes Capital', '3400');
SET @CiudadID = SCOPE_IDENTITY();

-- 2. Insertar una nueva Sucursal que depende de esa Ciudad
INSERT INTO Sucursal (telefono, calle, nro_calle, activo, id_ciudad)
VALUES ('3784990011', 'Av. Libertad', 850, 1, @CiudadID);

-- 3. Confirmar la transacción manualmente
COMMIT TRANSACTION;


-- Ejemplo de una transacción anidada
	
GO
	BEGIN TRY
		BEGIN TRANSACTION;  -- Transacción principal: Configuración de Inventario

			-- 1. Primera operación: Insertar la Categoría si no existe (usando un ID conocido)
			DECLARE @CatID INT = 99;
			INSERT INTO Categoria (id_categoria, nombre, activo) 
			VALUES (@CatID, 'Nuevos_Lanzamientos', 1);

			-- Transacción anidada: Registrar un Producto
			BEGIN TRANSACTION;  

			-- 2. Segunda operación (anidada): Insertar el Producto
			INSERT INTO Producto (nombre, descripcion, precio, stock, stock_minimo, id_categoria)
			VALUES ('Difusor de Aromas', 'Con temporizador LED', 950.00, 50, 10, @CatID);
			
			-- Simular error en la inserción del producto
			-- THROW 50001, 'Error simulado al insertar producto', 1;

			-- Confirmación de la transacción anidada
			COMMIT TRANSACTION;  

			-- 3. Tercera operación (principal): Actualizar el estado de la Categoría
			UPDATE Categoria SET nombre = 'Promoción de Noviembre' WHERE id_categoria = @CatID;

			-- Confirmación de la transacción principal
			COMMIT TRANSACTION;
			PRINT 'Transacción completada con éxito: Categoría y Producto registrados.';

	END TRY
	BEGIN CATCH
			-- Revertir toda la operación si falla
			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
			PRINT 'Error en la transacción. Operación revertida.';
	END CATCH;
GO


-- Ejemplo de actualizacion de datos de la tabla Sucursal

	BEGIN TRY
		BEGIN TRAN
		-- Actualiza el teléfono de una sucursal específica
		UPDATE Sucursal SET telefono = '3794556677' WHERE id_sucursal = 100;
		
		-- Provocar un error después del update para simular una falla 
		-- THROW 50001, 'Error simulado después de actualizar teléfono', 1;
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
			PRINT 'Error en la transacción. Operación revertida.';
	END CATCH