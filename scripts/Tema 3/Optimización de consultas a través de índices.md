## 1. Introducción

En esta práctica, se analizó el impacto de diferentes estrategias de indexación en una consulta de rango de fechas sobre la tabla `Venta`, que contenía  un millón de registros. El objetivo era comprobar cómo la teoría de los índices de SQL Server se aplica en un escenario real, midiendo el costo de I/O (lecturas lógicas) y el tiempo transcurrido.

En la documentacion de Microsoft indica que los índices "aceleran la recuperación de filas". Nuestra consulta base (la **Búsqueda Sin Índice Útil**), que tardó **4662 ms**, fue nuestro punto de partida para demostrar esta afirmación.

---

## 2. Análisis del Escenario Base (Búsqueda Sin Índice Útil)

### Teoría
El texto explica que "solo puede haber un índice clúster por cada tabla...". Nuestra `PRIMARY KEY` en `id_venta` ya ocupaba este índice.

### Práctica (Resultados de la Búsqueda Sin Índice Útil)
* **Resultados:** `lecturas lógicas 7833` | `tiempo transcurrido = 4662 ms`
* **Plan de Ejecución:** `Clustered Index Scan`

Al buscar por `fecha_venta`, nuestro índice clúster en `id_venta` no servía. Tal como dice la teoría, el optimizador realizó un "recorrido de tabla" (`Scan`). Esto generó un costo altísimo de **7833 lecturas lógicas** y un tiempo de ejecución inaceptable.

---

## 3. El Problema del Índice Parcial (Búsqueda con `Key Lookup`)

### Teoría
El texto explica que los índices no clúster "tienen una estructura separada" y un "localizador de fila" (un puntero) que apunta a los datos reales.

### Práctica (Resultados de la Búsqueda con Índice Parcial)
Al crear un índice simple (sólo en `fecha_venta`), obtuvimos el peor resultado en tiempo:

* **Resultados:** `lecturas lógicas 2872` | `tiempo transcurrido = 4523 ms`
* **Plan de Ejecución:** `Index Seek` + `Key Lookup`

El motor usó el índice para encontrar las fechas (`Seek`), pero luego tuvo que usar ese "localizador de fila" **28,234 veces** (una por cada fila) para "saltar" a la tabla a buscar `id_cliente` e `id_empleado`. Esos "saltos" (`Key Lookups`) fueron tan costosos que el tiempo total fue casi idéntico al del `Scan`.

---

## 4. La Solución: El Índice "Covering" (Búsqueda Optimizada)

### Teoría
El texto menciona la solución exacta: "Puede agregar columnas sin clave... para ejecutar **consultas totalmente cubiertas**".

### Práctica (Resultados de la Búsqueda Optimizada)
Esto fue lo que hicimos al crear un índice que "cubría" la consulta (ya sea con `INCLUDE` o creando el clúster en la fecha):

* **Resultados:** `lecturas lógicas 78` | `tiempo transcurrido = 514 ms`
* **Plan de Ejecución:** `Index Seek` (o `Clustered Index Seek`)

Al crear una "consulta totalmente cubierta", el plan de ejecución se simplificó a un solo `Index Seek` sin `Key Lookups`. El motor obtuvo toda la información leyendo *únicamente* el índice.

**El resultado fue favorable:**

* **Lecturas lógicas:** 78 (de 7833 en el `Scan`)
* **Tiempo transcurrido:** 514 ms (de 4662 ms en el `Scan`)

---

## 5. Conclusión General

Esta serie de pruebas demostró  que el rendimiento de una consulta no depende de si existe un índice, sino de si existe el diseño correcto del índice. Logramos transformar una consulta de 4.6 segundos en una de medio segundo y con una lectura lógica de 7833 a solo 78.

Esto comprueba que una estrategia de indexación correcta, diseñada específicamente para las consultas que debe resolver, mejora 
notablemente  el rendimiento de una base de datos.

---
## Bibliografía.
### Tema 3: “Optimización de Índices en SQL Server” 
https://learn.microsoft.com/es-es/sql/relational-databases/indexes/clustered-and-nonclustered-indexes-described?view=sql-server-ver17

