
import sys
import os

path = r'informes_comerciales\Views\Home\Index.cshtml'
if not os.path.exists(path):
    print(f"Error: {path} not found")
    sys.exit(1)

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Buscamos el bloque de generación (líneas 232 a 263 aprox)
# Lo identificamos por el comentario inicial y el div final
start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if '<!-- Fila de Generación de Datos (Horizontal en la base) -->' in line:
        start_idx = i
    if start_idx != -1 and i > start_idx and '</div>' in line:
         # El bloque termina en el div que cierra la fila de checks
         # Según el análisis es el div de la línea 263
         # Verificamos si es el div correcto (el que cierra el d-flex mt-4)
         if '</div>' in line and i - start_idx > 20: 
             end_idx = i
             break

if start_idx == -1 or end_idx == -1:
    print(f"Error: Could not identify block. Start: {start_idx}, End: {end_idx}")
    sys.exit(1)

print(f"Moving block from lines {start_idx+1} to {end_idx+1}")
block = lines[start_idx:end_idx+1]
del lines[start_idx:end_idx+1]

# Ahora buscamos el punto de inserción en "RESTO de INFORMES"
# Queremos insertar al final del card-body, después de reportButtonsContainer
insert_idx = -1
found_resto = False
for i, line in enumerate(lines):
    if 'RESTO de INFORMES' in line:
        found_resto = True
    if found_resto and 'id="reportButtonsContainer"' in line:
        # Buscamos el cierre de este container
        # Sabemos que está unas líneas más abajo
        for j in range(i, len(lines)):
            if '</div>' in lines[j]:
                # Hay varios cierres consecutivos, buscamos el que cierra el container
                # En el archivo original hay tres </div> seguidos al final de la sección
                if '</div>' in lines[j] and '</div>' in lines[j+1]:
                    insert_idx = j + 1
                    break
        if insert_idx != -1:
            break

if insert_idx == -1:
    print("Error: Could not identify insertion point")
    sys.exit(1)

print(f"Inserting block at line {insert_idx+1}")
lines.insert(insert_idx, '\n' + ''.join(block))

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Success!")
