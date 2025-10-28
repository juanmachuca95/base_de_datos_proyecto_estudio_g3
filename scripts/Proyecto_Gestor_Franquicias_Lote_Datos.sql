/*	BASE DE DATOS I - 2025
	PROYECTO DE ESTUDIO - Gestor Franquicias
	GRUPO 3 
--*/

-----------------------------------
-- LOTE DE DATOS
-----------------------------------

USE GestorFranquiciasDB -- Ubicarse en la BD a trabajar

-- Tabla Persona
INSERT INTO Persona (nombre, apellido, dni, telefono, email, fecha_nacimiento)
VALUES 
('Juan', 'Perez', 12345678, '1111111', 'juan.perez@example.com', '1980-05-15'),--1
('Ana', 'Gomez', 87654321, '2222222', 'ana.gomez@example.com', '1992-07-20'),--2
('Luis', 'Lopez', 34567890, '3333333', 'luis.lopez@example.com', '1985-03-10'),--3
('Maria', 'Martinez', 45678901, '4444444', 'maria.martinez@example.com', '1990-08-25'),--4
('Carlos', 'Garcia', 56789012, '5555555', 'carlos.garcia@example.com', '2001-02-12'),--5
('Laura', 'Fernandez', 67890123, '6666666', 'laura.fernandez@example.com', '1988-12-05'),--6
('Jorge', 'Rodriguez', 78901234, '7777777', 'jorge.rodriguez@example.com', '2001-10-30'),--7
('Sofia', 'Romero', 89012345, '8888888', 'sofi256@example.com', '1994-01-16'),--8
('Ricardo', 'Sanchez', 90123456, '9999999', 'r.sanchez@example.com', '1996-06-22'),--9
('Patricia', 'Diaz', 23456789, '1010101', 'patricia10@example.com', '2000-11-03'),--10
('Pedro', 'Lopez', 67640114, '3794205741', 'plopez@gmail.com', '1988-11-23'),--11
('Julieta', 'Vallejos', 90703432, '3795626754', 'jsanchez@gmail.com', '1993-06-21'),--12
('Lautaro', 'Velazquez', 99885565, '3795014483', 'lau487@gmail.com', '1990-04-03')--13;

SELECT * FROM Persona;

-- Tabla Cliente
INSERT INTO Cliente (activo, id_persona)
VALUES 
(1, 1),
(1, 2),
(0, 3),
(1, 4),
(0, 5),
(1, 6);

SELECT * FROM Cliente;

-- Tabla Perfil
INSERT INTO Perfil (nombre, activo)
VALUES 
('Gerente', 1),
('Vendedor', 1),
('Administrador', 1),
('Cajero', 0),
('Supervisor', 0);

SELECT * FROM Perfil;

-- Tabla Categoria
INSERT INTO Categoria (nombre, activo)
VALUES 
('Electrodomésticos', 1),
('Computadoras', 1),
('Telefonía', 0),
('Hogar', 1),
('Muebles', 0),
('Juguetería', 1),
('Ropa', 1),
('Calzado', 1),
('Deportes', 1),
('Libros', 0),
('Jardinería', 0),
('Cocina y accesorios', 1);

SELECT * FROM Categoria;

-- Tabla Metodo_pago
INSERT INTO Metodo_pago (nombre, proveedor)
VALUES 
('Tarjeta de Crédito', 'Visa'),
('Tarjeta de Débito', 'Mastercard'),
('Transferencia Bancaria', 'BBVA'),
('Efectivo', 'N/A'),
('Pago con QR', 'MercadoPago');

SELECT * FROM Metodo_pago;

-- Tabla Ciudad
INSERT INTO Ciudad (nombre, cod_postal)
VALUES
('Corrientes', '3400'),
('Bella Vista', '3432'),
('Itati', '3414'),
('San Cosme', '3412'),
('Goya', '3450');

SELECT * FROM Ciudad;

-- Tabla Sucursal
INSERT INTO Sucursal (calle, telefono, nro_calle, activo, id_ciudad)
VALUES
('Av. Siempre Viva', '1122334455', 320, 1, 1),
('Av. Belgrano', '1122334410', 147, 0, 1),
('Calle Borges', '1122334420', 850, 0, 2),
('Cazadores Correntinos', '1122334466', 456, 1, 2),
('San Juan', '1122334477', 789, 1, 3),
('Av. Libertad', '1122334488', 321, 1, 4),
('Pellegrini', '1122334499', 1020, 0, 5);

SELECT * FROM Sucursal;

-- Tabla Producto
INSERT INTO Producto (nombre, descripcion, precio, stock, stock_minimo, imagen, activo, id_categoria)
VALUES
('Lavadora', 'Lavadora de alta eficiencia', 400.00, 50, 10, NULL, 1, 1),
('Laptop', 'Laptop con 16GB RAM y SSD', 1000.00, 20, 10, NULL, 1, 2),
('Smartphone', 'Smartphone de última generación', 800.00, 100, 20, NULL, 0, 3),
('Aspiradora', 'Aspiradora portátil', 150.00, 75, 10, NULL, 0, 4),
('Sofá', 'Sofá de cuero', 700.00, 10, 5, NULL, 1, 5),
('Pelota de Fútbol', 'Pelota oficial de la liga', 30.00, 200, 50, NULL, 0, 6),
('Camiseta', 'Camiseta deportiva', 25.00, 300, 50, NULL, 1, 7),
('Zapatos', 'Zapatos de cuero', 60.00, 300, 50, NULL, 0, 8),
('Bicicleta', 'Bicicleta de montaña', 300.00, 20, 5, NULL, 1, 9),
('Libro', 'Novela bestseller', 15.00, 100, 20, NULL, 0, 10),
('Sillón', 'Sillón reclinable', 200.00, 20, 5, NULL, 1, 5),
('Cafetera', 'Cafetera automática', 100.00, 50, 10, NULL, 1, 11),
('Plancha', 'Plancha de ropa', 40.00, 80, 10, NULL, 1, 1),
('Reproductor DVD', 'Reproductor DVD portátil', 50.00, 60, 10, NULL, 1, 2),
('Estante', 'Estante para libros', 45.00, 40, 10, NULL, 0, 3);

SELECT * FROM Producto;

-- Tabla Empleado
INSERT INTO Empleado (clave, sueldo, hora_entrada, hora_salida, activo, id_perfil, id_persona, id_sucursal)
VALUES
('gerente01', 250000, '08:00', '12:00', 1, 1, 7, 2),	-- gerente activo
('gerente02', 230000, '13:00', '17:00', 0, 1, 8, 1),	-- gerente inactivo
('admin01', 300000, '17:00', '21:00', 1, 2, 9, 1),	-- admin activo
('admin02', 280000, '13:00', '17:00', 0, 2, 10, 3),	-- admin inactivo
('vend01', 150000, '08:00', '12:00', 1, 3, 11, 3),	-- vendedor activo
('vend02', 155000, '16:00', '21:00', 1, 3, 12, 2),	-- vendedor activo
('vend03', 150000, '13:00', '17:00', 0, 3, 13, 1);	-- vendedor inactivo

SELECT * FROM Empleado;

-- Tabla Venta
INSERT INTO Venta (fecha_venta, id_cliente, id_empleado, id_metodo_pago)
VALUES
('2024-10-15', 1, 6, 1),
('2024-10-20', 2, 6, 2),
('2024-10-10', 3, 6, 3),
('2024-10-05', 4, 7, 4),
('2024-10-15', 5, 7, 1),
('2024-10-22', 6, 6, 2),
('2024-10-18', 1, 7, 5),
('2024-11-01', 2, 7, 3),
('2024-11-03', 3, 6, 4),
('2024-11-04', 4, 6, 2);

SELECT * FROM Venta;

-- Tabla Detalle_Venta
INSERT INTO Detalle_Venta (cantidad, precio_producto, id_producto, id_venta)
VALUES
(2, 400.00, 1, 2),		-- Detalle para Venta 1
(1, 1000.00, 2, 2),		-- Detalle para Venta 1
(1, 150.00, 4, 3),		-- Detalle para Venta 2
(2, 30.00, 6, 3),		-- Detalle para Venta 2
(1, 60.00, 8, 4),		-- Detalle para Venta 3
(3, 800.00, 3, 5),		-- Detalle para Venta 4
(1, 45.00, 15, 5),		-- Detalle para Venta 4
(3, 700.00, 5, 6),		-- Detalle para Venta 5
(1, 300.00, 9, 7),		-- Detalle para Venta 6
(1, 200.00, 11, 7),		-- Detalle para Venta 6	
(3, 25.00, 7, 8),		-- Detalle para Venta 7
(1, 60.00, 8, 9),		-- Detalle para Venta 8
(1, 45.00, 14, 9),		-- Detalle para Venta 8
(1, 100.00, 12, 10),		-- Detalle para Venta 9
(1, 150.00, 4, 10),		-- Detalle para Venta 9
(2, 150.00, 5, 10),		-- Detalle para Venta 9
(1, 400.00, 1, 11),		-- Detalle para Venta 10
(1, 700.00, 5, 11),		-- Detalle para Venta 10
(1, 15.00, 10, 11);		-- Detalle para Venta 10

SELECT * FROM Detalle_Venta;