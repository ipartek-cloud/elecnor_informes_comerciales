using Elecnor_Informes_Comerciales.DTOs.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe de Principales Contrataciones del Año (CONSEJO ELECNOR).
/// </summary>
public class InformeContratacionesService
{
    private readonly InformeRepository _repository;

    public InformeContratacionesService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe completo de Contrataciones (informe principal + todos los subinformes).
    /// </summary>
    public async Task<ContratacionesResponseDto> ObtenerInformeCompletoAsync(int anio, int mes)
    {
        // 1. Definir umbrales y parámetros (Lógica de Negocio centralizada en el Servicio)
        const decimal umbralNacionalPrincipal = 5000;
        const decimal umbralNacionalAnterior = 15000;
        const decimal umbralInternacionalMes = 10000;
        const decimal umbralInternacionalAnterior = 25000;

        // 2. Lanzar las 4 consultas en paralelo
        var tareaPrincipal = ObtenerInformeAsync(anio, mes, umbralNacionalPrincipal, "nacional");
        var tareaNacionalAnterior = _repository.ObtenerContratacionesAnnoNacionalAnteriorAsync(anio, mes, umbralNacionalAnterior, "nacional");
        var tareaInternacionalMes = _repository.ObtenerContratacionesAnnoInternacionalMesAsync(anio, mes, umbralInternacionalMes, "internacional");
        var tareaInternacionalAnterior = _repository.ObtenerContratacionesAnnoInternacionalAnteriorAsync(anio, mes, umbralInternacionalAnterior, "internacional");
        
        // 3. Esperar a que todas terminen
        await Task.WhenAll(tareaPrincipal, tareaNacionalAnterior, tareaInternacionalMes, tareaInternacionalAnterior);

        // 3. Recoger los resultados (ya están disponibles)
        var informePrincipal = await tareaPrincipal;
        var datosNacionalAnterior = await tareaNacionalAnterior;
        var datosInternacionalMes = await tareaInternacionalMes;
        var datosInternacionalAnterior = await tareaInternacionalAnterior;

        // 4. Organizar y ordenar subinformes (descendente por importe)
        var subInformes = new SubInformesContratacionesDto
        {
            AnnoNacionalAnterior = datosNacionalAnterior
                .OrderByDescending(x => x.ImporteContratado_OK)
                .ToList(),
            
            AnnoInternacionalMes = datosInternacionalMes
                .OrderByDescending(x => x.ImporteContratado_OK)
                .ToList(),

            AnnoInternacionalAnterior = datosInternacionalAnterior
                .OrderByDescending(x => x.ImporteContratado_OK)
                .ToList()
        };

        // 5. Construir respuesta unificada
        return new ContratacionesResponseDto
        {
            Meta = informePrincipal.Meta,
            InformePrincipal = informePrincipal,
            SubInformes = subInformes
        };
    }

    public async Task<ContratacionesDto> ObtenerInformeAsync(int anio, int mes, decimal importe, string pais)
    {
        var datosPlanos = await _repository.ObtenerContratacionesAsync(anio, mes, importe, pais);

        if (datosPlanos == null || !datosPlanos.Any())
        {
            return new ContratacionesDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "Principales Contrataciones del Año",
                    Descripcion = "CONSEJO ELECNOR - Informe de Contratación Mercado Nacional",
                    Filtros = new { Anio = anio, Mes = mes },
                    FechaGeneracion = DateTime.Now,
                    Usuario = "Sistema"
                }
            };
        }

        var datosOrdenados = datosPlanos
            .OrderByDescending(x => x.ImporteContratado_OK)
            .ToList();

        return new ContratacionesDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Principales Contrataciones del Año",
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación Mercado Nacional",
                Filtros = new { Anio = anio, Mes = mes },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            },
            Datos = datosOrdenados,
            TotalesGlobales = new TotalesEstandarDto
            {
                ContratacionAcumulada = Math.Round(
                    datosOrdenados.Sum(x => x.ImporteContratado_OK),
                    0,
                    MidpointRounding.AwayFromZero
                )
            }
        };
    }

    /// <summary>
    /// Ejecuta el SP para generar/actualizar los datos de contrataciones.
    /// </summary>
    public async Task GenerarDatosAsync(int anio, int mes)
    {
        await _repository.EjecutarSPObrasAsync(anio, mes);
    }

    /// <summary>
    /// Obtiene los datos del subinforme Contrataciones Año Nacional Anterior (meses anteriores al seleccionado).
    /// </summary>
    public async Task<ContratacionesAnnoNacionalAnteriorDto> ObtenerContratacionesAnnoNacionalAnteriorAsync(int anio, int mes)
    {
        const decimal umbralDefecto = 15000;
        var datosPlanos = await _repository.ObtenerContratacionesAnnoNacionalAnteriorAsync(anio, mes, umbralDefecto, "Nacional");

        if (datosPlanos == null || !datosPlanos.Any())
        {
            return new ContratacionesAnnoNacionalAnteriorDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "Contrataciones Año Nacional Anterior",
                    Descripcion = "CONSEJO ELECNOR - Contratos acumulados meses anteriores",
                    Filtros = new { Anio = anio, Mes = mes },
                    FechaGeneracion = DateTime.Now,
                    Usuario = "Sistema"
                }
            };
        }

        // Los datos se ordenan por importe descendente
        var datosOrdenados = datosPlanos
            .OrderByDescending(x => x.ImporteContratado_OK)
            .ToList();

        return new ContratacionesAnnoNacionalAnteriorDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Contrataciones Año Nacional Anterior",
                Descripcion = "CONSEJO ELECNOR - Contratos acumulados meses anteriores",
                Filtros = new { Anio = anio, Mes = mes },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            },
            Datos = datosOrdenados
        };
    }
}
