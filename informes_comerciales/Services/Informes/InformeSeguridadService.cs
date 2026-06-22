using System.Data;
using Dapper;
using Microsoft.Extensions.Caching.Memory;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class InformeSeguridadService
{
    private readonly IDbConnection _connection;
    private readonly IMemoryCache _cache;
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(10);
    private const string CacheKey = "WEB_Usuarios_Informes_Matriz";

    public InformeSeguridadService(IDbConnection connection, IMemoryCache cache)
    {
        _connection = connection;
        _cache = cache;
    }

    /// <summary>
    /// Obtiene toda la matriz de permisos agrupada por puesto.
    /// Retorna un diccionario donde la clave es el Puesto (DG, SDG, etc.) y el valor es un conjunto de claves "Tipo_Informe_Web|Nombre_Informe_Web" permitidas.
    /// </summary>
    public async Task<Dictionary<string, HashSet<string>>> ObtenerMatrizPermisosAsync(bool bypassCache = false)
    {
        if (bypassCache)
        {
            _cache.Remove(CacheKey);
        }

        return await _cache.GetOrCreateAsync(CacheKey, async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheDuration;

            const string sql = @"
                SELECT Tipo_Informe_Web, Nombre_Informe_Web,
                       Acceso_DG, Acceso_SDG, Acceso_DN, 
                       Acceso_AREA, Acceso_DEL, Acceso_CT
                FROM dbo.WEB_Usuarios_Informes";

            var filas = await _connection.QueryAsync(sql);

            var matriz = new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
            var puestos = new[] { "DG", "SDG", "DN", "AREA", "DEL", "CT" };

            foreach (var puesto in puestos)
            {
                matriz[puesto] = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            }

            foreach (var fila in filas)
            {
                string tipo = fila.Tipo_Informe_Web?.ToString()?.Trim() ?? string.Empty;
                string nombre = fila.Nombre_Informe_Web?.ToString()?.Trim() ?? string.Empty;
                if (string.IsNullOrEmpty(tipo) || string.IsNullOrEmpty(nombre)) continue;

                string key = $"{tipo}|{nombre}";

                var d = (IDictionary<string, object>)fila;
                if (d.TryGetValue("Acceso_DG", out var dg) && Convert.ToBoolean(dg)) matriz["DG"].Add(key);
                if (d.TryGetValue("Acceso_SDG", out var sdg) && Convert.ToBoolean(sdg)) matriz["SDG"].Add(key);
                if (d.TryGetValue("Acceso_DN", out var dn) && Convert.ToBoolean(dn)) matriz["DN"].Add(key);
                if (d.TryGetValue("Acceso_AREA", out var area) && Convert.ToBoolean(area)) matriz["AREA"].Add(key);
                if (d.TryGetValue("Acceso_DEL", out var del) && Convert.ToBoolean(del)) matriz["DEL"].Add(key);
                if (d.TryGetValue("Acceso_CT", out var ct) && Convert.ToBoolean(ct)) matriz["CT"].Add(key);
            }

            return matriz;
        }) ?? new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Verifica si un puesto tiene acceso a un informe por su tipo y nombre comercial.
    /// </summary>
    public async Task<bool> TieneAccesoAsync(string puesto, string tipo, string nombre)
    {
        if (string.IsNullOrWhiteSpace(puesto)) return false;
        var matriz = await ObtenerMatrizPermisosAsync();
        if (matriz.TryGetValue(puesto.Trim(), out var permitidos))
        {
            return permitidos.Contains($"{tipo.Trim()}|{nombre.Trim()}");
        }
        return false;
    }

    /// <summary>
    /// Retorna una cadena con la lista de informes permitidos en formato CSV: "Tipo|Nombre,Tipo|Nombre"
    /// útil para inyectar en el token JWT.
    /// </summary>
    public async Task<string> ObtenerPermisosSerializadosAsync(string puesto, bool bypassCache = false)
    {
        if (string.IsNullOrWhiteSpace(puesto)) return string.Empty;
        var matriz = await ObtenerMatrizPermisosAsync(bypassCache);
        if (matriz.TryGetValue(puesto.Trim(), out var permitidos))
        {
            return string.Join(",", permitidos);
        }
        return string.Empty;
    }
}
