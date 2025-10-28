/*	BASE DE DATOS I - 2025
	PROYECTO DE ESTUDIO - Gestor Franquicias
	GRUPO 3 
--*/

-----------------------------------
-- MODELO DE DATOS
-----------------------------------

-- Crear la base de datos
CREATE DATABASE GestorFranquiciasDB;

-- Ubicarse en la BD a trabajar
USE GestorFranquiciasDB;

-- Crear las tablas necesarias

-- Tabla Persona
CREATE TABLE Persona
(
  id_persona INT IDENTITY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  dni NUMERIC(8) NOT NULL,
  telefono VARCHAR(15) NOT NULL,
  email VARCHAR(200) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  date_create DATETIME NOT NULL CONSTRAINT DF_Persona_date_create DEFAULT GETDATE(),
  user_create VARCHAR(100) NOT NULL CONSTRAINT DF_Persona_user_create DEFAULT SUSER_SNAME(),
  CONSTRAINT PK_Persona PRIMARY KEY (id_persona),
  CONSTRAINT UQ_Persona_email UNIQUE (email),
  CONSTRAINT UQ_Persona_dni UNIQUE (dni)
);

-- Tabla Cliente
CREATE TABLE Cliente
(
  id_cliente INT IDENTITY NOT NULL,
  activo BIT CONSTRAINT DF_Cliente_activo DEFAULT 1 NOT NULL,
  id_persona INT NOT NULL,
  CONSTRAINT PK_Cliente PRIMARY KEY (id_cliente),
  CONSTRAINT FK_Cliente_Persona FOREIGN KEY (id_persona) REFERENCES Persona(id_persona)
);

-- Tabla Perfil
CREATE TABLE Perfil
(
  id_perfil INT IDENTITY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  activo BIT CONSTRAINT DF_Perfil_activo DEFAULT 1 NOT NULL,
  CONSTRAINT PK_Perfil PRIMARY KEY (id_perfil)
);

-- Tabla Categoria
CREATE TABLE Categoria
(
  id_categoria INT IDENTITY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  activo BIT CONSTRAINT DF_Categoria_activo DEFAULT 1 NOT NULL,
  CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria)
);

-- Tabla Metodo_pago
CREATE TABLE Metodo_pago
(
  id_metodo_pago INT IDENTITY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  proveedor VARCHAR(100) NOT NULL,
  CONSTRAINT PK_Metodo_pago PRIMARY KEY (id_metodo_pago)
);

-- Tabla Ciudad
CREATE TABLE Ciudad
(
  id_ciudad INT IDENTITY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  cod_postal VARCHAR(10) NOT NULL,
  CONSTRAINT PK_Ciudad PRIMARY KEY (id_ciudad)
);

-- Tabla Sucursal
CREATE TABLE Sucursal
(
  id_sucursal INT IDENTITY NOT NULL,
  calle VARCHAR(100) NOT NULL,
  telefono VARCHAR(15) NOT NULL,
  nro_calle INT NOT NULL,
  activo BIT CONSTRAINT DF_Sucursal_activo DEFAULT 1 NOT NULL,
  id_ciudad INT NOT NULL,
  CONSTRAINT PK_Sucursal PRIMARY KEY (id_sucursal),
  CONSTRAINT FK_Sucursal_Ciudad FOREIGN KEY (id_ciudad) REFERENCES Ciudad(id_ciudad)
);

-- Tabla Producto
CREATE TABLE Producto
(
  id_producto INT IDENTITY NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(200) NOT NULL,
  precio FLOAT NOT NULL,
  stock INT NOT NULL,
  stock_minimo INT NOT NULL,
  imagen VARCHAR(200) NULL,
  activo BIT CONSTRAINT DF_Producto_activo DEFAULT 1 NOT NULL,
  id_categoria INT NOT NULL,
  CONSTRAINT PK_Producto PRIMARY KEY (id_producto),
  CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);

-- Tabla Empleado
CREATE TABLE Empleado
(
  id_empleado INT IDENTITY NOT NULL,
  clave VARCHAR(100) NOT NULL,
  sueldo FLOAT NOT NULL,
  hora_entrada TIME NOT NULL,
  hora_salida TIME NOT NULL,
  activo BIT CONSTRAINT DF_Empleado_activo DEFAULT 1 NOT NULL,
  id_perfil INT NOT NULL,
  id_persona INT NOT NULL,
  id_sucursal INT NOT NULL,
  CONSTRAINT PK_Empleado PRIMARY KEY (id_empleado),
  CONSTRAINT FK_Empleado_Perfil FOREIGN KEY (id_perfil) REFERENCES Perfil(id_perfil),
  CONSTRAINT FK_Empleado_Persona FOREIGN KEY (id_persona) REFERENCES Persona(id_persona),
  CONSTRAINT FK_Empleado_Sucursal FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

-- Tabla Venta
CREATE TABLE Venta
(
  id_venta INT IDENTITY NOT NULL,
  fecha_venta DATE NOT NULL,
  date_create DATETIME NOT NULL CONSTRAINT DF_Venta_date_create DEFAULT GETDATE(),
  user_create VARCHAR(100) NOT NULL CONSTRAINT DF_Venta_user_create DEFAULT SUSER_SNAME(),
  activo BIT CONSTRAINT DF_Venta_activo DEFAULT 1 NOT NULL,
  id_cliente INT NOT NULL,
  id_empleado INT NOT NULL,
  id_metodo_pago INT NOT NULL,
  CONSTRAINT PK_Venta PRIMARY KEY (id_venta),
  CONSTRAINT FK_Venta_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
  CONSTRAINT FK_Venta_Empleado FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
  CONSTRAINT FK_Venta_Metodo_pago FOREIGN KEY (id_metodo_pago) REFERENCES Metodo_pago(id_metodo_pago)
);

-- Tabla Detalle_Venta
CREATE TABLE Detalle_Venta
(
  cantidad INT NOT NULL,
  precio_producto FLOAT NOT NULL,
  id_producto INT NOT NULL,
  id_venta INT NOT NULL,
  CONSTRAINT PK_Detalle_Venta PRIMARY KEY (id_producto, id_venta),
  CONSTRAINT FK_Detalle_Venta_Producto FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
  CONSTRAINT FK_Detalle_Venta_Venta FOREIGN KEY (id_venta) REFERENCES Venta(id_venta)
);