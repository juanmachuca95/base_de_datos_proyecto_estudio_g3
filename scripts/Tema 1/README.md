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
