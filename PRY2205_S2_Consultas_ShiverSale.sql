-- ============================================================
-- PRY2205 - SEMANA 2
-- Asignatura: Consulta de Bases de Datos
-- Empresa: ShiverSale
-- Usuario de ejecución: PRY2205_S2
--
-- Reúne los tres informes solicitados en la actividad.
-- Ejecutar con F5 (Ejecutar script) desde SQL Developer.
-- El Caso 3 solicita tres variables de sustitución.
-- No incluye creación de usuario ni creación/poblamiento de tablas,
-- porque esas tareas ya se realizaron con los scripts de AVA.
-- ============================================================


-- ============================================================
-- CASO 1: ANALISIS DE FACTURAS
-- Tabla: FACTURA
-- ============================================================

SELECT
    NUMFACTURA AS "N° Factura",

    TO_CHAR(FECHA, 'DD') || ' de ' ||
    INITCAP(TRIM(TO_CHAR(FECHA, 'Month',
        'NLS_DATE_LANGUAGE=SPANISH'))) || ' ' ||
    TO_CHAR(FECHA, 'YYYY') AS "Fecha Emisión",

    LPAD(RUTCLIENTE, 10, '0') AS "RUT Cliente",

    TO_CHAR(
        ROUND(NETO),
        'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "Monto Neto",

    TO_CHAR(
        ROUND(IVA),
        'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "Monto IVA",

    TO_CHAR(
        ROUND(TOTAL),
        'FM$999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "Total Factura",

    CASE
        WHEN TOTAL <= 50000 THEN 'Bajo'
        WHEN TOTAL <= 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoría Monto",

    DECODE(
        NVL(CODPAGO, 0),
        1, 'EFECTIVO',
        2, 'TARJETA DEBITO',
        3, 'TARJETA CREDITO',
        'CHEQUE'
    ) AS "Forma de pago"

FROM FACTURA
WHERE EXTRACT(YEAR FROM FECHA) =
      EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY FECHA DESC, NETO DESC;


-- ============================================================
-- CASO 2: CLASIFICACION DE CLIENTES
-- Tabla: CLIENTE
-- ============================================================

SELECT
    LPAD(RUTCLIENTE, 12, '*') AS "RUT",

    INITCAP(NOMBRE) AS "Cliente",

    NVL(TO_CHAR(TELEFONO), 'Sin teléfono') AS "TELEFONO",

    NVL(TO_CHAR(CODCOMUNA), 'Sin comuna') AS "COMUNA",

    ESTADO AS "ESTADO",

    CASE
        WHEN SALDO / CREDITO < 0.50 THEN
            'Bueno ( $' ||
            TO_CHAR(
                ROUND(CREDITO - SALDO),
                'FM999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            ) || ')'

        WHEN SALDO / CREDITO <= 0.80 THEN
            'Regular ( $' ||
            TO_CHAR(
                ROUND(SALDO),
                'FM999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            ) || ')'

        ELSE
            'Crítico'
    END AS "Estado Crédito",

    NVL(
        UPPER(SUBSTR(MAIL, INSTR(MAIL, '@') + 1)),
        'Correo no registrado'
    ) AS "Dominio Correo"

FROM CLIENTE
WHERE ESTADO = 'A'
  AND CREDITO > 0
ORDER BY NOMBRE ASC;


-- ============================================================
-- CASO 3: STOCK DE PRODUCTOS
-- Tabla: PRODUCTO
-- Variables:
--   TIPOCAMBIO_DOLAR
--   UMBRAL_BAJO
--   UMBRAL_ALTO
--
-- Ejecutar con F5. Se solicitará cada variable una sola vez.
-- ============================================================

UNDEFINE TIPOCAMBIO_DOLAR
UNDEFINE UMBRAL_BAJO
UNDEFINE UMBRAL_ALTO

SELECT
    CODPRODUCTO || ' ' || INITCAP(DESCRIPCION)
        AS "Descripción de Producto",

    CASE
        WHEN VALORCOMPRADOLAR IS NULL THEN 'Sin registro'
        ELSE
            RTRIM(
                RTRIM(
                    TO_CHAR(
                        VALORCOMPRADOLAR,
                        'FM999G999D99',
                        'NLS_NUMERIC_CHARACTERS='',.'''
                    ),
                    '0'
                ),
                ','
            ) || ' USD'
    END AS "Compra en USD",

    CASE
        WHEN VALORCOMPRADOLAR IS NULL THEN 'Sin registro'
        ELSE
            TO_CHAR(
                ROUND(VALORCOMPRADOLAR * &&TIPOCAMBIO_DOLAR),
                'FM$999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            ) || ' PESOS'
    END AS "USD convertido",

    NVL(TO_CHAR(TOTALSTOCK), 'Sin datos') AS "Stock",

    CASE
        WHEN TOTALSTOCK IS NULL THEN 'Sin datos'
        WHEN TOTALSTOCK < &&UMBRAL_BAJO
            THEN '¡ALERTA stock muy bajo!'
        WHEN TOTALSTOCK BETWEEN &&UMBRAL_BAJO AND &&UMBRAL_ALTO
            THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",

    CASE
        WHEN TOTALSTOCK > 80 THEN
            TO_CHAR(
                ROUND(VUNITARIO * 0.90),
                'FM$999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            )
        ELSE 'N/A'
    END AS "Precio Oferta"

FROM PRODUCTO
WHERE LOWER(DESCRIPCION) LIKE '%zapato%'
  AND LOWER(PROCEDENCIA) = 'i'
ORDER BY CODPRODUCTO DESC;


-- ============================================================
-- FIN DEL SCRIPT - SEMANA 2
-- ============================================================
