# Tema 1: Procedimientos y funciones almacenadas

Ejemplos sobre la base Gestor Franquicias.

## Qué incluye
- Procedimientos almacenados:
  - `listar_sucursales`
  - `listar_ventas_con_sucursal`
- Funciones:
  - Escalar(que devuelve una sola cosa) `fn_total_ventas_global()` → total global de ventas
  - Tabla `fn_top10_productos()` → top 10 productos por cantidad

## Uso rápido
```sql
EXEC listar_sucursales;
EXEC listar_ventas_con_sucursal;

SELECT fn_total_ventas_global() AS total_global;
SELECT * FROM fn_top10_productos();
```
---

# Resumen de la Actividad Realizada (Versión Extendida)

En este trabajo se desarrollaron procedimientos y funciones almacenadas enfocados en la gestión de inventario y ventas del proyecto *Gestor de Franquicias*. El objetivo fue implementar operaciones CRUD utilizando procedimientos almacenados, así como funciones orientadas a cálculos específicos y verificaciones dentro del sistema.

## 1. Creación de Procedimientos Almacenados

Se desarrollaron diferentes procedimientos para manipular la tabla `Producto` de forma controlada:

- **insertarProducto**: Permite registrar nuevos productos garantizando la consistencia de los datos.
- **modificarProducto**: Actualiza los valores de un producto existente mediante su identificador.
- **borrarProducto**: Realiza una eliminación física del producto en la tabla.
- **bajaLogicaProducto** y **altaLogicaProducto**: Implementan la metodología de activación o desactivación de productos mediante el campo `activo`.

Estos procedimientos encapsulan la lógica de negocio y protegen la integridad de los datos al evitar eliminar o modificar registros directamente sobre las tablas.

## 2. Inserción de Datos mediante Procedimientos

Para la evaluación práctica se cargaron datos de dos formas:

- **INSERT directo** para insertar un lote inicial de productos.
- **EXEC insertarProducto** para insertar otro lote utilizando el procedimiento almacenado.

Esto permitió comparar la eficiencia, facilidad de uso y mantenimiento de ambos enfoques. Aunque el uso de procedimientos puede implicar un pequeño costo adicional de procesamiento, proporciona múltiples ventajas en cuanto a seguridad, control y estandarización de la lógica.

## 3. Creación de Funciones Almacenadas

Se implementaron funciones escalares orientadas a cálculos y verificaciones sobre la tabla `Producto`:

- **calcularDescuento**: Calcula el precio final después de aplicar un porcentaje de descuento.
- **esStockBajo**: Determina si el stock actual está por debajo del mínimo recomendado.
- **esProductoActivo**: Devuelve si un producto está activo o inactivo.
- **obtenerCategoriaProducto**: Regresa el nombre de la categoría correspondiente a un producto.
- **contarProductosActivos**: Devuelve el total de productos activos dentro del sistema.

Estas funciones permiten realizar consultas enriquecidas dentro de reportes sin necesidad de repetir lógica.

## 4. Comparación de Eficiencia

Se compararon operaciones directas sobre tablas versus procedimientos almacenados:

### Ventajas de procedimientos:
- Mayor seguridad (no requieren permisos directos sobre tablas).
- Encapsulan la lógica y evitan errores críticos (como DELETE sin WHERE).
- Facilitan el mantenimiento y escalabilidad del sistema.
- Permiten auditoría simplificada.

### Ventajas de operaciones directas:
- Ejecución ligeramente más rápida en casos aislados.
- Menor procesamiento interno.

### Conclusión:
Aunque el INSERT directo puede ser más veloz en términos brutos, los procedimientos almacenados son ampliamente superiores en entornos reales debido a su seguridad, consistencia, mantenibilidad y control.

---
