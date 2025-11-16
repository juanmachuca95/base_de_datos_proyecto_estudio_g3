
#  Manejo de Transacciones y Transacciones Anidadas

## ¿Qué es una Transacción?

Una **transacción** es una **unidad única de trabajo** en la base de datos. Es esencial para garantizar que las operaciones comerciales críticas de **Gestor Franquicias** (como registrar una venta o actualizar el stock) se completen en su totalidad.

  * Si la transacción tiene éxito, todas las modificaciones de los datos se **confirman** (`COMMIT`) y se vuelven permanentes.
  * Si la transacción encuentra errores, todas las modificaciones de los datos se **revierten** (`ROLLBACK`), asegurando que la base de datos permanezca **consistente** (propiedad ACID).

-----

### Modos de Transacción en SQL Server

| Modo | Descripción | Uso en Gestor Franquicias |
| :--- | :--- | :--- |
| **Transacciones de confirmación automática** | Cada instrucción individual (`INSERT`, `UPDATE`, `DELETE`) es una transacción que se confirma automáticamente al finalizar. | Ideal para operaciones sencillas que no dependen de pasos consecutivos, como la actualización del estado de una sucursal (`UPDATE Sucursal`). |
| **Transacciones explícitas** | La transacción se inicia con `BEGIN TRANSACTION` y debe finalizarse explícitamente con `COMMIT` o `ROLLBACK`. | **Crucial** para operaciones complejas como el **registro de una venta**, que toca múltiples tablas (`Venta`, `Detalle_Venta`, `Producto`). |
| **Transacciones implícitas** | Se inicia una nueva transacción al completarse la anterior, pero requiere un `COMMIT` o `ROLLBACK` manual para cerrarla. | Utilizado cuando se establece `SET IMPLICIT_TRANSACTIONS ON;`. |
| **Transacciones de ámbito de lote** | Transacciones implícitas o explícitas que se inician en una sesión de MARS (Conjuntos de Resultados Activos Múltiples). | El lote finaliza revirtiendo automáticamente si no hay un `COMMIT` o `ROLLBACK` explícito. |

-----

### Instrucciones de Transacción en SQL Server

  * **`BEGIN TRANSACTION` o `BEGIN TRAN`**: Marca el inicio de la secuencia de operaciones.
  * **`COMMIT TRANSACTION` o `COMMIT TRAN`**: Confirma el conjunto de operaciones, haciendo los datos definitivos.
  * **`ROLLBACK TRANSACTION` o `ROLLBACK TRAN`**: Revierte la transacción en caso de error o para anularla.

-----

### 📝 Ejemplos Aplicados a Gestor Franquicias

#### **Transacciones de confirmación automática**

```sql
-- Insertar un nuevo perfil de usuario para un rol (ej. 'Administrador del Sistema')
INSERT INTO Perfil (nombre, activo) VALUES ('AdminSistema', 1);
-- Actualizar el estado (activo) de una sucursal/franquicia
UPDATE Sucursal SET activo = 0 WHERE id_sucursal = 5;
```

#### **Transacciones explícitas**

**Caso de uso:** Registro completo de una Venta (debe insertar la cabecera y los detalles)

```sql
BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Insertar la cabecera de la venta
        DECLARE @VentaID INT;
        INSERT INTO Venta (date_create, id_cliente, id_empleado, id_metodo_pago) 
        VALUES (GETDATE(), 12, 5, 1);
        SET @VentaID = SCOPE_IDENTITY();

        -- 2. Descontar stock e insertar los detalles del producto vendido
        UPDATE Producto SET stock = stock - 2 WHERE id_producto = 10;
        INSERT INTO Detalle_Venta (id_venta, id_producto, cantidad, precio_producto) 
        VALUES (@VentaID, 10, 2, 45.99);

        -- 3. Confirmar la transacción
        COMMIT TRANSACTION;
        PRINT 'Venta registrada y stock actualizado con éxito.';
    END TRY
    BEGIN CATCH
        -- En caso de error (ej. stock insuficiente, error de FK), revertir todo.
        ROLLBACK TRANSACTION;
        PRINT 'Error al registrar la venta. Operación revertida completamente.';
    END CATCH;
```

-----

## ¿Qué es una Transacción Anidada?

Una **transacción anidada** es una transacción que se inicia con `BEGIN TRANSACTION` dentro del contexto de otra transacción ya activa. En **GestorFranquicias**, esto permite modular operaciones complejas (ej. insertar un producto y su categoría asociada).

> **Nota Crucial en SQL Server**: SQL Server no soporta completamente las transacciones anidadas. **Solo la transacción más externa controla el `COMMIT` o `ROLLBACK`**. Si se produce un `ROLLBACK` en cualquier nivel interno, SQL Server revierte toda la transacción hasta el `BEGIN TRANSACTION` más externo.

### Ejemplo de una Transacción Anidada

**Caso de uso:** Inserción de un nuevo Producto con su Categoría.

```sql
BEGIN TRANSACTION;  -- Transacción Principal: Registrar Producto

    BEGIN TRY
        -- 1. Inserción de la Categoría (Transacción Anidada)
        BEGIN TRANSACTION;  -- Inicia la transacción anidada
            DECLARE @CatID INT;
            INSERT INTO Categoria (nombre, activo) VALUES ('LimpiezaHogar', 1);
            SET @CatID = SCOPE_IDENTITY();
        COMMIT TRANSACTION; -- Cierra el contador anidado, no confirma definitivamente.

        -- 2. Inserción del Producto
        INSERT INTO Producto (nombre, id_categoria, stock, precio) 
        VALUES ('Trapeador Pro', @CatID, 50, 15.50); 
        
        -- 3. Confirmación de la transacción principal (hace permanentes ambas inserciones)
        COMMIT TRANSACTION;
        PRINT 'Producto y Categoría registrados con éxito.';
    END TRY
    BEGIN CATCH
        -- Si falla el paso 2, el ROLLBACK revierte todo, incluyendo la Categoria.
        ROLLBACK TRANSACTION; 
        PRINT 'Error: No se pudo registrar el Producto. Operación revertida.';
    END CATCH;
```

-----

## Ventajas de las Transacciones 

Las transacciones son vitales para mantener la **integridad y confiabilidad** de los datos :

  * **Atomicidad (Todo o Nada):** Asegura la completitud de las operaciones críticas.
  * **Consistencia:** Garantiza que los datos cumplen con todas las reglas y restricciones de negocio (ej. integridad referencial, stock $\ge 0$).
  * **Aislamiento:** Permite que múltiples vendedores y sucursales registren datos simultáneamente sin interferir entre sí.
  * **Durabilidad:** Una vez confirmado el cambio, el registro es permanente, protegiendo los datos contra fallos del sistema.
  * **Manejo de Errores y Recuperación:** Proporciona un mecanismo controlado para deshacer operaciones fallidas (`ROLLBACK`), manteniendo el sistema en un estado válido.
  * **Mejora en la Concurrencia y Seguridad:** Facilita el manejo eficiente de accesos simultáneos y limita el acceso a datos solo a las operaciones confirmadas.


## Fuentes


1\. \[Transacciones en SQL Server - Documentación de Microsoft](https://learn.microsoft.com/es-es/sql/t-sql/language-elements/transactions-transact-sql?view=sql-server-ver16)

2\. \[Transacciones en SQL Server - Programación.net](https://programacion.net/articulo/transacciones\_en\_sql\_server\_299)

3\. \[Transacciones en SQL Server para principiantes - SQL Shack](https://www.sqlshack.com/transactions-in-sql-server-for-beginners/)

