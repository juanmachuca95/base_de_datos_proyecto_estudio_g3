# Prueba de Rama de Fernandez Gotusso, Maria Daniela (yoquienmas)
# Proyecto Gestor de Franquicias

## Integrantes
- **Benitez, Lucas Emmanuel** – DNI: 43930915
- **Díaz, Cristian Leandro** – DNI: 42734520
- **Fernandez Gotusso, Maria Daniela** – DNI: 43822520
- **Machuca, Juan Gabriel** – DNI: 40048379

Año: 2025

---

## CAPÍTULO 1: INTRODUCCIÓN

### 1.1 Tema
**Automatización de la gestión de ventas e inventario para una red de franquicias.**

### 1.2 Definición y planteamiento del Problema
Actualmente, muchas tiendas de comercio minorista, en particular las que operan bajo un modelo de franquicias, dependen de procesos manuales para la gestión de ventas, el control de inventarios y la administración de clientes.

Este enfoque tradicional es propenso a errores, genera una alta ineficiencia operativa y retrasa la toma de decisiones estratégicas.

La falta de un sistema de gestión centralizado y automatizado en cada sucursal de la franquicia provoca una desconexión entre las áreas clave (ventas, inventario y atención al cliente).

Como resultado, la productividad se ve afectada, ya que el personal invierte tiempo en tareas repetitivas y de registro manual, como la actualización de inventarios o la generación de reportes.

Esta situación conduce a problemas críticos, como:
- La falta de visibilidad en tiempo real del stock.
- La duplicación de datos e inconsistencia en los registros.
- La imposibilidad de dar una respuesta ágil a los cambios en la demanda del mercado.
- Un impacto negativo en la calidad del servicio al cliente.

Además, la fragmentación de la información dificulta la obtención de reportes consolidados y precisos a nivel de franquicia. Esto limita la capacidad de la gerencia para:
- Supervisar el rendimiento general.
- Identificar oportunidades de mejora.
- Tomar decisiones basadas en datos confiables.

### 1.3 Objetivo del Trabajo Práctico
El objetivo principal de este trabajo es desarrollar un sistema de gestión automatizado, denominado **Gestor Franquicias**, que proporcione una solución integral a los problemas de ineficiencia y falta de control en las operaciones diarias de una red de franquicias.

Además, el proyecto incorpora la investigación y aplicación de conceptos avanzados como el análisis de datos para la toma de decisiones, la implementación de un robusto sistema de permisos a nivel de usuario en la base de datos y la optimización de consultas para garantizar un rendimiento óptimo.

### 1.4 Preguntas de Investigación

#### Preguntas Generales
- ¿Cómo se puede optimizar la gestión de ventas, inventarios y clientes para una red de franquicias?

#### Preguntas Específicas
- ¿Cómo podemos asegurar que la búsqueda de una factura de venta sea eficiente y rápida?
- ¿Qué estrategia permite optimizar la carga y actualización del inventario de productos?
- ¿Cómo se puede implementar un control de stock efectivo y en tiempo real para cada producto?
- ¿De qué manera se puede gestionar el registro y la eliminación de clientes de forma segura y eficiente?
- ¿Cómo podemos agilizar el proceso de registro de una venta, minimizando errores y tiempo de espera?

### 1.5 Objetivos

#### Objetivos Generales
Desarrollar un sistema de gestión automatizado que resuelva la problemática de la falta de control y la ineficiencia en las operaciones de ventas, inventario y clientes en un modelo de franquicias.

#### Objetivos Específicos
- Reducir significativamente el tiempo y los errores asociados al registro manual de inventario y a las tareas de búsqueda de datos.
- Optimizar los procesos de búsqueda y recuperación de facturas de venta.
- Proveer informes y reportes detallados que permitan analizar el rendimiento de ventas y el comportamiento del inventario.
- Implementar un sistema de control de stock que evite la falta de productos y facilite la toma de decisiones sobre reabastecimiento.

### 1.6 Descripción del Sistema
El sistema **Gestor Franquicias** está diseñado para ser la herramienta central de administración de tiendas físicas de artículos de bazar y polirrubro con múltiples sucursales en la provincia de Corrientes. Su propósito es centralizar el registro y la administración de ventas, clientes, productos y otros datos comerciales.

El sistema cuenta con un esquema de perfiles de usuario que asigna funcionalidades específicas según el rol del personal: gerente, vendedor y administrador del sistema. Los vendedores tienen acceso a la gestión diaria de clientes y productos, así como al procesamiento de ventas. El gerente general supervisa el rendimiento de las ventas, gestiona el personal y accede a informes detallados. Finalmente, el administrador del sistema es responsable del mantenimiento, la seguridad y las copias de seguridad de la base de datos.

### 1.7 Alcance
Este proyecto se centrará en el procesamiento y la administración de datos clave relacionados con las ventas. El sistema abordará las interacciones fundamentales del negocio: el registro de qué vendedor realizó una venta, a qué cliente se le vendió, qué productos fueron adquiridos y con qué método de pago.

El alcance del proyecto no incluye funcionalidades de integración con proveedores para el reabastecimiento de stock, ni se profundizará en el análisis de datos a un nivel que exceda los informes y reportes básicos para la toma de decisiones a nivel gerencial.

---
## CAPITULO 2: MARCO CONCEPTUAL O REFERENCIAL

### Tema 2: “Gestión de Transacciones y Transacciones Anidadas” 
El manejo de datos en un sistema de administración centralizado demanda un mecanismo riguroso que garantice la integridad operacional. Las transacciones representan la unidad fundamental de trabajo, diseñadas para ser indivisibles. Su implementación es esencial, ya que adhieren a las propiedades ACID (Atomicidad, Consistencia, Aislamiento y Durabilidad), asegurando que las operaciones críticas (como el registro de una venta que afecta tanto a la tabla Venta como al stock del Producto) se ejecuten completamente o no se ejecuten en absoluto. 
Dentro de esta estructura, las transacciones anidadas se emplean para modular y estructurar operaciones más complejas. Permiten iniciar transacciones menores dentro del contexto de una transacción principal ya activa. Este enfoque es crucial para gestionar la lógica de negocio con múltiples dependencias, ya que facilita el manejo de errores intermedios. Garantiza que, si una sub-operación falla, la función de reversión (ROLLBACK) pueda restablecer el sistema a su estado original sin comprometer la integridad de la base de datos.

---
## CAPÍTULO 3: METODOLOGÍA SEGUIDA

---
## CAPÍTULO 4: DESARROLLO DEL TEMA

### 4.1 Diagrama de Modelo Relacional
Un Diagrama de Modelo Relacional, comúnmente conocido como Diagrama Entidad-Relación (DER), es una representación gráfica que ilustra la estructura de la base de datos. Este diagrama muestra cómo las entidades (tablas) se relacionan entre sí a través de llaves primarias y foráneas, proporcionando una visión clara del flujo de datos y la organización del sistema. El modelo siguiente representa el diseño de la base de datos para el sistema Gestor Franquicias.

### 4.2 Diccionario de Datos
El Diccionario de Datos es una herramienta esencial para la gestión de la información. Proporciona una descripción completa y estructurada de cada elemento de la base de datos. En él se detallan los nombres de las tablas, sus campos (atributos), los tipos de datos, longitudes, descripciones y las restricciones o relaciones que existen entre ellos.

#### Tabla: Perfil
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_perfil | int | 4 | Identificación única para un perfil | PRIMARY KEY |
| nombre | varchar | 100 | Indica el nombre del perfil | - |
| activo | bit | 1 | Indica el estado del perfil (0-inactivo, 1-activo) | DEFAULT |

#### Tabla: Persona
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_persona | int | 4 | Identificación única para una persona | PRIMARY KEY |
| nombre | varchar | 100 | Indica el nombre de la persona | - |
| apellido | varchar | 100 | Indica el apellido de la persona | - |
| dni | numeric | 8 | Indica el DNI de la persona | UNIQUE |
| telefono | varchar | 15 | Indica el teléfono de la persona | - |
| email | varchar | 200 | Indica el email de la persona | UNIQUE |
| fecha_nacimiento | date | - | Indica la fecha de nacimiento de la persona | - |
| date_create | date | - | Indica la fecha de creación del registro | DEFAULT |
| user_create | int | 4 | Indica el usuario de DB que creó el registro | DEFAULT |

#### Tabla: Empleado
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_empleado | int | 4 | Identificación única para un empleado | PRIMARY KEY |
| clave | varchar | 200 | Indica la clave del empleado | - |
| sueldo | float | - | Indica el sueldo del empleado | - |
| hora_entrada | time | - | Indica el horario de entrada del empleado | - |
| hora_salida | time | - | Indica el horario de salida del empleado | - |
| id_perfil | int | 4 | Identificación del tipo de perfil del empleado | FOREIGN KEY |
| id_persona | int | 4 | Identificación única de la persona | FOREIGN KEY |
| id_sucursal | int | 4 | Identificación única de la sucursal | FOREIGN KEY |
| activo | bit | 1 | Indica el estado del empleado (0-inactivo, 1-activo) | DEFAULT |

#### Tabla: Cliente
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_cliente | int | 4 | Identificación única para un cliente | PRIMARY KEY |
| id_persona | int | 4 | Identificación única de la persona | FOREIGN KEY |
| activo | bit | 1 | Indica el estado del cliente (0-inactivo, 1-activo) | DEFAULT |

#### Tabla: Sucursal
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_sucursal | int | 4 | Identificación única para una sucursal | PRIMARY KEY |
| calle | varchar | 100 | Indica el nombre de la calle de la sucursal | - |
| telefono | varchar | 15 | Indica el número de teléfono de la sucursal | - |
| nro_calle | int | 4 | Indica el número de calle de la sucursal | - |
| id_ciudad | int | 4 | Identificación única para una ciudad | FOREIGN KEY |
| activo | bit | 1 | Indica el estado de la sucursal (0-inactivo, 1-activo) | DEFAULT |

#### Tabla: Ciudad
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_ciudad | int | 4 | Identificación única para una ciudad | PRIMARY KEY |
| nombre | varchar | 100 | Indica el nombre de la ciudad | - |
| cod_postal | varchar | 100 | Indica el código postal de la ciudad | - |

#### Tabla: Venta
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_venta | int | 4 | Identificación única para una venta | PRIMARY KEY |
| date_create | date | - | Fecha y hora de creación del registro | DEFAULT |
| user_create | varchar | 100 | Usuario que creó el registro | DEFAULT |
| id_cliente | int | 4 | Identificación única para un cliente | FOREIGN KEY |
| id_empleado | int | 4 | Identificación única para un empleado | FOREIGN KEY |
| id_metodo_pago | int | 4 | Identificación única para un método de pago | FOREIGN KEY |
| activo | bit | 1 | Indica el estado de la venta (0-inactivo, 1-activo) | DEFAULT |

#### Tabla: Detalle_Venta
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_producto | int | 4 | Identificación única para un producto | PRIMARY KEY, FOREIGN KEY |
| id_venta | int | 4 | Identificación única para una venta | PRIMARY KEY, FOREIGN KEY |
| cantidad | int | 4 | Indica la cantidad de productos | - |
| precio_producto | float | - | Indica el precio del producto | - |

#### Tabla: Producto
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_producto | int | 4 | Identificación única para un producto | PRIMARY KEY |
| nombre | varchar | 100 | Indica el nombre del producto | - |
| descripcion | varchar | 200 | Indica la descripción del producto | - |
| precio | float | - | Indica el precio del producto | - |
| stock | int | 4 | Indica el stock actual del producto | - |
| stock_minimo | int | 4 | Indica el stock de reposición del producto | - |
| imagen | varchar | 200 | Indica la imagen del producto | - |
| activo | bit | 1 | Indica el estado del producto (0-inactivo, 1-activo) | DEFAULT |
| id_categoria | int | 4 | Identificación única de la categoría del producto | FOREIGN KEY |

#### Tabla: Categoria
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_categoria | int | 4 | Identificación única para una categoría | PRIMARY KEY |
| nombre | varchar | 100 | Indica el nombre de la categoría | - |
| activo | bit | 1 | Indica el estado de la categoría (0-inactivo, 1-activo) | DEFAULT |

#### Tabla: Metodo_pago
| Campo | Tipo | Longitud | Significado | Restricciones |
|-------|------|-----------|-------------|---------------|
| id_metodo_pago | int | 4 | Identificación única para un método de pago | PRIMARY KEY |
| nombre | varchar | 100 | Nombre del método de pago (efectivo, transferencia, crédito, etc.) | - |
| proveedor | varchar | 100 | Entidad que facilita el uso del método de pago | - |

---
## CAPÍTULO 5: CONCLUSIONES
## Tema 1: "Procedmimientos y funciones de almacenado"
Aunque el INSERT directo puede ser más veloz en términos brutos, los procedimientos almacenados son ampliamente superiores en entornos reales debido a su seguridad, consistencia, mantenibilidad y control.

### Tema 2: “Gestión de Transacciones y Transacciones Anidadas” 
La implementación de transacciones y transacciones anidadas resultó ser una estrategia clave para asegurar la integridad y consistencia del sistema. Este mecanismo no solo protege la atomicidad de las operaciones críticas, como el registro de ventas y la actualización de stock, sino que también optimiza el manejo de errores, garantizando que los datos sean reversibles en caso de fallos.

### Tema 3: “Optimización de Índices en SQL Server” 
Esta serie de pruebas demostró que el rendimiento de una consulta no depende de si existe un índice, sino de si existe el diseño correcto del índice. Logramos transformar una consulta de 4.6 segundos en una de medio segundo y con una lectura lógica de 7833 a solo 78.
Esto comprueba que una estrategia de indexación correcta, diseñada específicamente para las consultas que debe resolver, mejora notablemente el rendimiento de una base de datos.

### Tema 4: "Vistas y Vistas Indexadas en SQL Server"
Las **Vistas** y **Vistas Indexadas**, son esenciales para la optimización de consultas y la garantía de un rendimiento óptimo. Estos elementos son cruciales para cumplir con los objetivos del sistema, como la provisión de informes gerenciales detallados y la optimización de los procesos de búsqueda y recuperación de datos.

---
## Bibliografía.
### Tema 2: “Gestión de Transacciones y Transacciones Anidadas” 
https://learn.microsoft.com/es-es/office/client-developer/access/desktop-database-reference/transaction-processing
### Tema 3: “Optimización de Índices en SQL Server” 
https://learn.microsoft.com/es-es/sql/relational-databases/indexes/clustered-and-nonclustered-indexes-described?view=sql-server-ver17
### Tema 4: "Vistas y Vistas Indexadas en SQL Server"
https://learn.microsoft.com/en-us/sql/t-sql/statements/create-view-transact-sql?view=sql-server-ver17
https://learn.microsoft.com/es-es/sql/relational-databases/views/create-indexed-views?view=sql-server-ver16 

