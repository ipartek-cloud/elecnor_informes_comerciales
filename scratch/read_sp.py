import pyodbc

conn_str = "Driver={ODBC Driver 17 for SQL Server};Server=172.24.16.51;Database=RP_SIC;Uid=certificaciones;Pwd=ipartek1;TrustServerCertificate=True;"

# Connect to database
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Query definition of spContratacion_Obras
cursor.execute("SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('spContratacion_Obras')")
row = cursor.fetchone()
if row and row[0]:
    definition = row[0]
    out_path = r"C:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\scratch\spContratacion_Obras_server.sql"
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(definition)
    print(f"Success! SP definition written to {out_path}. Length: {len(definition)} characters.")
else:
    print("SP not found or definition is NULL.")

conn.close()
