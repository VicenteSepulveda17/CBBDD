-- ============================================================
-- PRY2205 - SEMANA 3
-- Actividad: Aplicando funciones de agrupacion
-- Empresa: ASOCIADOS
-- Usuario de ejecucion: PRY2205_S3
--
-- IMPORTANTE:
-- 1. Ejecutar conectado como PRY2205_S3.
-- 2. Ejecutar con F5 (Ejecutar script) en SQL Developer.
-- 3. Caso 1 solicita VALOR_TOTAL_GASTO_COMUN.
-- 4. Caso 2 solicita CODIGO_SUCURSAL.
-- 5. Los importes se muestran redondeados a enteros.
-- ============================================================


-- ============================================================
-- CASO 1: ANALISIS DE PROPIEDADES
-- Resumen por tipo de propiedad.
-- ============================================================

SELECT
    tp.id_tipo_propiedad AS "TIPO",

    COUNT(p.nro_propiedad) AS "TOTAL_PROPIEDADES",

    TO_CHAR(
        ROUND(MAX(p.valor_arriendo)),
        'FM$999G999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "MAX_ARRIENDO",

    TO_CHAR(
        ROUND(AVG(p.valor_arriendo)),
        'FM$999G999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "PROMEDIO_ARRIENDO",

    TO_CHAR(
        ROUND(MIN(p.valor_arriendo)),
        'FM$999G999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "MIN_ARRIENDO",

    CASE
        WHEN MAX(p.valor_arriendo) <= 1000000 THEN 'ESTANDAR'
        ELSE 'PREMIUM'
    END AS "CLASIFICACION",

    TO_CHAR(
        ROUND(SUM(NVL(p.valor_gasto_comun, 0))),
        'FM$999G999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "TOTAL_GASTOS_COMUNES"

FROM propiedad p
JOIN tipo_propiedad tp
    ON p.id_tipo_propiedad = tp.id_tipo_propiedad

GROUP BY
    tp.id_tipo_propiedad

HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN

ORDER BY
    SUM(NVL(p.valor_gasto_comun, 0)) DESC;


-- ============================================================
-- CASO 2: ANALISIS DE ANTIGUEDAD DE EMPLEADOS
-- Ejecutivos de Arriendo con mas de 5 anios de antiguedad,
-- excluyendo la sucursal indicada por el operador.
-- ============================================================

SELECT
    UPPER(TRIM(e.nombre_emp)) || ' ' ||
    UPPER(TRIM(e.appaterno_emp)) AS "NOMBRE_EMPLEADO",

    TO_CHAR(
        ROUND(e.sueldo_emp),
        'FM$999G999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "SUELDO_CON_FORMATO",

    CASE
        WHEN e.sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "CLASIFICACION_SUELDO",

    TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
        AS "ANIOS_ANTIGUEDAD",

    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
             BETWEEN 5 AND 10
        THEN
            'Corresponde bono 5%: ' ||
            TO_CHAR(
                ROUND(e.sueldo_emp * 0.05),
                'FM$999G999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            )

        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
             BETWEEN 11 AND 20
        THEN
            'Corresponde bono 10%: ' ||
            TO_CHAR(
                ROUND(e.sueldo_emp * 0.10),
                'FM$999G999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            )

        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) > 20
        THEN
            'Corresponde bono 15%: ' ||
            TO_CHAR(
                ROUND(e.sueldo_emp * 0.15),
                'FM$999G999G999G999',
                'NLS_NUMERIC_CHARACTERS='',.'''
            )
    END AS "BONO"

FROM empleado e

WHERE e.id_categoria_emp = 3
  AND TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) > 5
  AND e.id_sucursal <> &CODIGO_SUCURSAL

ORDER BY
    e.sueldo_emp DESC;


-- ============================================================
-- CASO 3: LISTA DE CLIENTES
-- Clasificacion por renta, cantidad, promedio y disponibilidad
-- de telefono por clasificacion.
-- ============================================================

SELECT
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS "CLASIFICACION_RENTA",

    COUNT(*) AS "CANTIDAD_CLIENTES",

    TO_CHAR(
        ROUND(AVG(renta_cli)),
        'FM$999G999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "RENTA_PROMEDIO",

    CASE
        WHEN COUNT(fonofijo_cli) + COUNT(celular_cli) = 0
        THEN 'Clientes sin Telefono'
        ELSE 'Clientes con Telefono'
    END AS "ESTADO_TELEFONO"

FROM cliente

GROUP BY
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END

HAVING AVG(renta_cli) > 200000

ORDER BY
    CASE
        WHEN
            CASE
                WHEN renta_cli >= 1000000 THEN 'PREMIUM'
                WHEN renta_cli >= 600000 THEN 'ALTA'
                WHEN renta_cli >= 300000 THEN 'MEDIA'
                ELSE 'BAJA'
            END = 'ALTA' THEN 1
        WHEN
            CASE
                WHEN renta_cli >= 1000000 THEN 'PREMIUM'
                WHEN renta_cli >= 600000 THEN 'ALTA'
                WHEN renta_cli >= 300000 THEN 'MEDIA'
                ELSE 'BAJA'
            END = 'MEDIA' THEN 2
        WHEN
            CASE
                WHEN renta_cli >= 1000000 THEN 'PREMIUM'
                WHEN renta_cli >= 600000 THEN 'ALTA'
                WHEN renta_cli >= 300000 THEN 'MEDIA'
                ELSE 'BAJA'
            END = 'BAJA' THEN 3
        ELSE 4
    END;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
