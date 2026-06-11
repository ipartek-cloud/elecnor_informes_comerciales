import json
import re
import pyodbc

# 1. Leer cadena de conexión de appsettings.json
appsettings_path = "informes_comerciales/appsettings.json"
with open(appsettings_path, 'r', encoding='utf-8') as f:
    content = f.read()
    content_clean = re.sub(r'//.*', '', content)
    content_clean = re.sub(r'/\*.*?\*/', '', content_clean, flags=re.DOTALL)
    config = json.loads(content_clean)
conn_str = config['ConnectionStrings']['DefaultConnection']

conn_str = conn_str.replace("TrustServerCertificate=True", "TrustServerCertificate=yes")
conn_str = conn_str.replace("MultipleActiveResultSets=True;", "")
conn_str = conn_str.replace("MultipleActiveResultSets=True", "")
conn_str = conn_str.replace("User Id=", "uid=")
conn_str = conn_str.replace("Password=", "pwd=")
conn_str = conn_str.replace("Microsoft.Data.SqlClient", "SQL Server")
if "Driver=" not in conn_str:
    conn_str = "Driver={ODBC Driver 17 for SQL Server};" + conn_str

# 2. Conectar a la base de datos
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

print("\n--- INICIANDO COMPROBACIONES DE AISLAMIENTO RLS (GRUPO 2: CONTRATACIONES) ---\n")

# Para probar RLS, usaremos usuarios con datos.
# Busquemos primero qué usuarios de prueba tienen obras asociadas en la base de datos en rptPrincipalesObras.
# Hacemos esto cruzando rptPrincipalesObras con Sumarigrama y WEB_Usuarios.
# O directamente elegimos algunos de los 64 usuarios y verificamos el aislamiento.

usuarios_prueba = [
    {"usuario": "Ipartek_SDG_221", "puesto": "SDG", "entidad": "221"},
    {"usuario": "Ipartek_DN_090", "puesto": "DN", "entidad": "090"},
    {"usuario": "Ipartek_DN_700", "puesto": "DN", "entidad": "700"},
    {"usuario": "Ipartek_AREA_780", "puesto": "AREA", "entidad": "780"},
    {"usuario": "Ipartek_DEL_126", "puesto": "DEL", "entidad": "126"},
    {"usuario": "Ipartek_CT_020", "puesto": "CT", "entidad": "020"}
]

anio = 2026
mes = 5
importe_limite = 0.0  # Bajamos el umbral a 0 para que devuelva todas las obras y poder auditar los centros

# SQL con RLS que nos devuelve las obras individuales con su CodCentro
sql_test = """
    DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20);
    SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad FROM dbo.WEB_Usuarios WITH (NOLOCK) WHERE Usuario = ?;

    SELECT
         rpt.CodCentro,
         S.CodSubDirGeneral,
         S.CodDDirNegocio,
         S.CodSubDirNegocioArea,
         S.CodDelegacion,
         SUM(rpt.ImporteContratado_OK) AS Importe
     FROM
         rptPrincipalesObras rpt WITH (NOLOCK)
     INNER JOIN dbo.Sumarigrama S WITH (NOLOCK) ON rpt.CodCentro = S.CodCentro AND rpt.Año = S.Año
     WHERE rpt.Año = ? AND rpt.Mes = ? AND rpt.Ocultar = 0
       AND ISNULL(rpt.NombreCliente_OK, '') <> 'SIN' AND ISNULL(rpt.DescripcionOferta_OK, '') <> 'SIN'
       AND (
           @vPuesto = 'DG' OR @vPuesto IS NULL OR ? IS NULL
           OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)
           OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)
           OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)
           OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)
           OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
       )
     GROUP BY
         rpt.CodCentro,
         S.CodSubDirGeneral,
         S.CodDDirNegocio,
         S.CodSubDirNegocioArea,
         S.CodDelegacion
"""

total_errores = 0

for u in usuarios_prueba:
    print(f"Probando usuario: {u['usuario']} (Puesto: {u['puesto']}, Entidad: {u['entidad']})")
    
    cursor.execute(sql_test, [u['usuario'], anio, mes, u['usuario']])
    rows = cursor.fetchall()
    
    if len(rows) == 0:
        print(f"  - No hay obras registradas en Año={anio}, Mes={mes} para este ámbito (0 filas).")
        print("  => [OK] Aislamiento correcto (vacío legítimo).")
        print("-" * 50)
        continue
        
    print(f"  - Se devolvieron {len(rows)} filas de obras.")
    
    usuario_errores = 0
    for row in rows:
        cod_centro = row[0]
        cod_sdg = row[1]
        cod_dn = row[2]
        cod_area = row[3]
        cod_del = row[4]
        importe = float(row[5])
        
        # Validar según el puesto
        es_valido = False
        if u['puesto'] == 'SDG':
            es_valido = (cod_sdg == u['entidad'])
            detalle = f"SDG={cod_sdg}"
        elif u['puesto'] == 'DN':
            es_valido = (cod_dn == u['entidad'])
            detalle = f"DN={cod_dn}"
        elif u['puesto'] == 'AREA':
            es_valido = (cod_area == u['entidad'])
            detalle = f"AREA={cod_area}"
        elif u['puesto'] == 'DEL':
            es_valido = (cod_del == u['entidad'])
            detalle = f"DEL={cod_del}"
        elif u['puesto'] == 'CT':
            es_valido = (cod_centro == u['entidad'])
            detalle = f"Centro={cod_centro}"
            
        if not es_valido:
            print(f"  => 🔴 FILTRADO DEFECTUOSO: Obra en Centro {cod_centro} ({detalle}) visible para usuario {u['usuario']}!")
            usuario_errores += 1
            total_errores += 1
            
    if usuario_errores == 0:
        print(f"  => [OK] Aislamiento correcto. Todas las obras pertenecen estrictamente al ámbito {u['puesto']}={u['entidad']}.")
    else:
        print(f"  => [FALLO] Se detectaron {usuario_errores} fugas de información.")
    print("-" * 50)

conn.close()

if total_errores == 0:
    print("\n[OK] EXCELENTE: Todas las pruebas de aislamiento RLS de contrataciones pasaron al 100%!")
else:
    print(f"\n[FALLO] ALERTA: Se detectaron {total_errores} brechas de seguridad en el aislamiento RLS.")
