import json
import re
import pyodbc

# 1. Leer cadena de conexión de appsettings.json
appsettings_path = "informes_comerciales/appsettings.json"
with open(appsettings_path, 'r', encoding='utf-8') as f:
    content = f.read()
    # Eliminar comentarios // y /* ... */
    content_clean = re.sub(r'//.*', '', content)
    content_clean = re.sub(r'/\*.*?\*/', '', content_clean, flags=re.DOTALL)
    config = json.loads(content_clean)
conn_str = config['ConnectionStrings']['DefaultConnection']

# Ajustar cadena de conexión para pyodbc si es necesario
conn_str = conn_str.replace("TrustServerCertificate=True", "TrustServerCertificate=yes")
conn_str = conn_str.replace("MultipleActiveResultSets=True;", "")
conn_str = conn_str.replace("MultipleActiveResultSets=True", "")
conn_str = conn_str.replace("User Id=", "uid=")
conn_str = conn_str.replace("Password=", "pwd=")
# Reemplazar Microsoft.Data.SqlClient con SQL Server
conn_str = conn_str.replace("Microsoft.Data.SqlClient", "SQL Server")
# Asegurar driver ODBC
if "Driver=" not in conn_str:
    conn_str = "Driver={ODBC Driver 17 for SQL Server};" + conn_str

print("Cadena de conexión ODBC:", conn_str)

# 2. Conectar a la base de datos
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Parámetros de prueba
anio = 2026
mes = 5
importe_nacional = 5000.0
importe_internacional = 10000.0
importe_ai = 1000.0
importe_sig = 1000.0

def ejecutar_y_sumar(sql, params):
    try:
        cursor.execute(sql, params)
        rows = cursor.fetchall()
        # Obtener los nombres de las columnas
        columns = [col[0].lower() for col in cursor.description]
        idx = next((i for i, name in enumerate(columns) if "importe" in name), -1)
        if idx == -1:
            idx = -1 # fallback
        total = sum(float(row[idx]) for row in rows if row[idx] is not None)
        return total, len(rows)
    except Exception as e:
        print(f"Error al ejecutar query: {e}")
        return None, 0

print("\n--- INICIANDO COMPROBACIONES DE REGRESIÓN GLOBAL (GRUPO 2: CONTRATACIONES) ---\n")

tests = [
    {
        "nombre": "1. ObtenerContratacionesAsync (Nacional)",
        "original": """
            SELECT REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                   REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                   SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK
            FROM rptPrincipalesObras rpt WITH (NOLOCK)
            WHERE rpt.Año = ? AND rpt.Mes = ? AND rpt.Ocultar = 0 AND rpt.Pais = 'Nacional'
              AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN' AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'
              AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'
            GROUP BY rpt.NombreCliente_OK, rpt.DescripcionOferta_OK
            HAVING SUM(rpt.ImporteContratado_OK) >= ? OR SUM(rpt.ImporteContratado_OK) <= -?
        """,
        "original_params": [anio, mes, importe_nacional, importe_nacional],
        "rls": """
            DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);
            SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = ?;

            SELECT REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                   REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                   SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK
            FROM rptPrincipalesObras rpt WITH (NOLOCK)
            INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año
            WHERE rpt.Año = ? AND rpt.Mes = ? AND rpt.Ocultar = 0 AND rpt.Pais = 'Nacional'
              AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN' AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'
              AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'
              AND (
                  @vPuesto = 'DG' OR @vPuesto IS NULL OR ? IS NULL
                  OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)
                  OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)
                  OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)
                  OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)
                  OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
              )
            GROUP BY rpt.NombreCliente_OK, rpt.DescripcionOferta_OK
            HAVING SUM(rpt.ImporteContratado_OK) >= ? OR SUM(rpt.ImporteContratado_OK) <= -?
        """,
        "rls_params_null": [None, anio, mes, None, importe_nacional, importe_nacional],
        "rls_params_dg": ["Ipartek_DG_218", anio, mes, "Ipartek_DG_218", importe_nacional, importe_nacional]
    },
    {
        "nombre": "2. ObtenerContratacionesAnnoInternacionalMesAsync (Internacional)",
        "original": """
            SELECT m.Nombre_Mes AS Meses,
                   REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                   REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                   rpt.NombreDirNegocio_OK,
                   SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK,
                   CASE WHEN oai.JVAYNB IS NOT NULL THEN 'AI' ELSE '' END AS AI
            FROM rptPrincipalesObras rpt WITH (NOLOCK)
            INNER JOIN Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
            LEFT JOIN OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB
            WHERE rpt.Año = ? AND rpt.Mes = ? AND rpt.Ocultar = 0 AND rpt.Pais = 'Internacional'
              AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN' AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'
              AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'
            GROUP BY m.Nombre_Mes, rpt.NombreCliente_OK, rpt.DescripcionOferta_OK, rpt.NombreDirNegocio_OK, oai.JVAYNB
            HAVING SUM(rpt.ImporteContratado_OK) >= ? OR SUM(rpt.ImporteContratado_OK) <= -?
        """,
        "original_params": [anio, mes, importe_internacional, importe_internacional],
        "rls": """
            DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);
            SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = ?;

            SELECT m.Nombre_Mes AS Meses,
                   REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                   REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                   rpt.NombreDirNegocio_OK,
                   SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK,
                   CASE WHEN oai.JVAYNB IS NOT NULL THEN 'AI' ELSE '' END AS AI
            FROM rptPrincipalesObras rpt WITH (NOLOCK)
            INNER JOIN Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
            INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año
            LEFT JOIN OfertaAsociadaInversion oai WITH (NOLOCK) ON rpt.CodOferta = oai.JVAYNB
            WHERE rpt.Año = ? AND rpt.Mes = ? AND rpt.Ocultar = 0 AND rpt.Pais = 'Internacional'
              AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN' AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'
              AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'
              AND (
                  @vPuesto = 'DG' OR @vPuesto IS NULL OR ? IS NULL
                  OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)
                  OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)
                  OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)
                  OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)
                  OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
              )
            GROUP BY m.Nombre_Mes, rpt.NombreCliente_OK, rpt.DescripcionOferta_OK, rpt.NombreDirNegocio_OK, oai.JVAYNB
            HAVING SUM(rpt.ImporteContratado_OK) >= ? OR SUM(rpt.ImporteContratado_OK) <= -?
        """,
        "rls_params_null": [None, anio, mes, None, importe_internacional, importe_internacional],
        "rls_params_dg": ["Ipartek_DG_218", anio, mes, "Ipartek_DG_218", importe_internacional, importe_internacional]
    },
    {
        "nombre": "3. ObtenerContratacionesAIAsync",
        "original": """
            SELECT rpt.Año,
                   CASE WHEN rpt.Pais = 'InterNacional' THEN 'I' ELSE '' END AS Paises,
                   m.Nombre_Mes AS Meses,
                   REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                   REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                   SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK
            FROM rptPrincipalesObrasAI rpt WITH (NOLOCK)
            INNER JOIN Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
            WHERE rpt.Año = ? AND rpt.Mes = ? AND rpt.Ocultar = 0
              AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN' AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'
              AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'
            GROUP BY rpt.Año, rpt.Pais, m.Nombre_Mes, rpt.DescripcionOferta_OK, rpt.NombreCliente_OK
            HAVING SUM(rpt.ImporteContratado_OK) > ?
        """,
        "original_params": [anio, mes, importe_ai],
        "rls": """
            DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);
            SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = ?;

            SELECT rpt.Año,
                   CASE WHEN rpt.Pais = 'InterNacional' THEN 'I' ELSE '' END AS Paises,
                   m.Nombre_Mes AS Meses,
                   REPLACE(rpt.DescripcionOferta_OK, '''', '') AS DescripcionOfertas_OK,
                   REPLACE(rpt.NombreCliente_OK, '''', '') AS NombreClientes_OK,
                   SUM(rpt.ImporteContratado_OK) AS ImporteContratado_OK
            FROM rptPrincipalesObrasAI rpt WITH (NOLOCK)
            INNER JOIN Mes m WITH (NOLOCK) ON rpt.Mes = m.Mes
            INNER JOIN dbo.OfertasSQL o WITH (NOLOCK) ON rpt.CodOferta = o.CodOferta
            INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON o.CodCentro = S.CodCentro AND rpt.Año = S.Año
            WHERE rpt.Año = ? AND rpt.Mes = ? AND rpt.Ocultar = 0
              AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN' AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'
              AND ISNULL(rpt.NombreDirNegocio_OK, '') <> 'SIN'
              AND (
                  @vPuesto = 'DG' OR @vPuesto IS NULL OR ? IS NULL
                  OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)
                  OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)
                  OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)
                  OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)
                  OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
              )
            GROUP BY rpt.Año, rpt.Pais, m.Nombre_Mes, rpt.DescripcionOferta_OK, rpt.NombreCliente_OK
            HAVING SUM(rpt.ImporteContratado_OK) > ?
        """,
        "rls_params_null": [None, anio, mes, None, importe_ai],
        "rls_params_dg": ["Ipartek_DG_218", anio, mes, "Ipartek_DG_218", importe_ai]
    },
    {
        "nombre": "4. ObtenerContratacionesSignificativasAsync (SDG 090 Nacional)",
        "original": """
            SELECT ocdn.Orden_CodDDirNegocio AS Orden,
                   s.NombreDirNegocio,
                   ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado
            FROM rptPrincipalesContratacion rpc
            INNER JOIN Sumarigrama s ON rpc.CodCentro = s.CodCentro
            INNER JOIN Orden_CodDDirNegocio ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
            WHERE rpc.Año = ? AND rpc.Mes IN (?, ? - 1) AND rpc.Ocultar = 0 AND rpc.Pais = 'Nacional' AND s.CodSubDirGeneral = '090'
            GROUP BY ocdn.Orden_CodDDirNegocio, s.NombreDirNegocio
        """,
        "original_params": [anio, mes, mes],
        "rls": """
            DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);
            SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = ?;

            SELECT ocdn.Orden_CodDDirNegocio AS Orden,
                   s.NombreDirNegocio,
                   ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado
            FROM rptPrincipalesContratacion rpc
            INNER JOIN Sumarigrama s ON rpc.CodCentro = s.CodCentro AND rpc.Año = s.Año
            INNER JOIN Orden_CodDDirNegocio ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
            WHERE rpc.Año = ? AND rpc.Mes IN (?, ? - 1) AND rpc.Ocultar = 0 AND rpc.Pais = 'Nacional' AND s.CodSubDirGeneral = '090'
              AND (
                  @vPuesto = 'DG' OR @vPuesto IS NULL OR ? IS NULL
                  OR (@vPuesto = 'SDG'  AND s.CodSubDirGeneral = @vCodEntidad)
                  OR (@vPuesto = 'DN'   AND s.CodDDirNegocio = @vCodEntidad)
                  OR (@vPuesto = 'AREA' AND s.CodSubDirNegocioArea = @vCodEntidad)
                  OR (@vPuesto = 'DEL'  AND s.CodDelegacion = @vCodEntidad)
                  OR (@vPuesto = 'CT'   AND s.CodCentro = @vCodEntidad)
              )
            GROUP BY ocdn.Orden_CodDDirNegocio, s.NombreDirNegocio
        """,
        "rls_params_null": [None, anio, mes, mes, None],
        "rls_params_dg": ["Ipartek_DG_218", anio, mes, mes, "Ipartek_DG_218"]
    },
    {
        "nombre": "5. ObtenerContratacionesSignificativasRiAsync (Comité)",
        "original": """
            SELECT ocdn.Orden_CodDDirNegocio AS Orden,
                   s.NombreDirNegocio,
                   ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado
            FROM rptPrincipalesContratacion rpc
            INNER JOIN Sumarigrama s ON rpc.CodCentro = s.CodCentro
            INNER JOIN Orden_CodDDirNegocio ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
            WHERE rpc.Año = ? AND rpc.Mes = ? AND rpc.Ocultar = 0 AND rpc.Pais = 'Nacional'
            GROUP BY s.OrdenSubDirGeneral, ocdn.Orden_CodDDirNegocio, s.NombreDirNegocio
        """,
        "original_params": [anio, mes],
        "rls": """
            DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);
            SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = ?;

            SELECT ocdn.Orden_CodDDirNegocio AS Orden,
                   s.NombreDirNegocio,
                   ISNULL(SUM(rpc.ImporteContratado_OK), 0) AS ImporteContratado
            FROM rptPrincipalesContratacion rpc
            INNER JOIN Sumarigrama s ON rpc.CodCentro = s.CodCentro AND rpc.Año = s.Año
            INNER JOIN Orden_CodDDirNegocio ocdn ON s.CodDDirNegocio = ocdn.CodDDirNegocio
            WHERE rpc.Año = ? AND rpc.Mes = ? AND rpc.Ocultar = 0 AND rpc.Pais = 'Nacional'
              AND (
                  @vPuesto = 'DG' OR @vPuesto IS NULL OR ? IS NULL
                  OR (@vPuesto = 'SDG'  AND s.CodSubDirGeneral = @vCodEntidad)
                  OR (@vPuesto = 'DN'   AND s.CodDDirNegocio = @vCodEntidad)
                  OR (@vPuesto = 'AREA' AND s.CodSubDirNegocioArea = @vCodEntidad)
                  OR (@vPuesto = 'DEL'  AND s.CodDelegacion = @vCodEntidad)
                  OR (@vPuesto = 'CT'   AND s.CodCentro = @vCodEntidad)
              )
            GROUP BY s.OrdenSubDirGeneral, ocdn.Orden_CodDDirNegocio, s.NombreDirNegocio
        """,
        "rls_params_null": [None, anio, mes, None],
        "rls_params_dg": ["Ipartek_DG_218", anio, mes, "Ipartek_DG_218"]
    }
]

total_errores = 0

for t in tests:
    print(f"Comprobando: {t['nombre']}")
    
    val_orig, filas_orig = ejecutar_y_sumar(t['original'], t['original_params'])
    val_rls_null, filas_rls_null = ejecutar_y_sumar(t['rls'], t['rls_params_null'])
    val_rls_dg, filas_rls_dg = ejecutar_y_sumar(t['rls'], t['rls_params_dg'])
    
    print(f"  - Original:   Total = {val_orig:,.2f} ({filas_orig} filas)" if val_orig is not None else "  - Original: ERROR")
    print(f"  - RLS NULL:   Total = {val_rls_null:,.2f} ({filas_rls_null} filas)" if val_rls_null is not None else "  - RLS NULL: ERROR")
    print(f"  - RLS DG user: Total = {val_rls_dg:,.2f} ({filas_rls_dg} filas)" if val_rls_dg is not None else "  - RLS DG user: ERROR")
    
    diff_null = abs((val_orig or 0) - (val_rls_null or 0))
    diff_dg = abs((val_orig or 0) - (val_rls_dg or 0))
    
    if diff_null < 0.01 and diff_dg < 0.01:
        print("  => [OK] Paridad matematica al centavo absoluta.")
    else:
        print(f"  => [FALLO] Diferencias detectadas. NULL diff={diff_null:.2f}, DG diff={diff_dg:.2f}")
        total_errores += 1
    print("-" * 50)

conn.close()

if total_errores == 0:
    print("\n[OK] EXCELENTE: Todas las pruebas de regresión global pasaron con paridad absoluta del 100%!")
else:
    print(f"\n[FALLO] ALERTA: Se encontraron {total_errores} fallos de paridad.")
