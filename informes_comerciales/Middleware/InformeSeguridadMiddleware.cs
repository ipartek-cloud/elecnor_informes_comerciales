using System.Text.Json;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Middleware;

public class InformeSeguridadMiddleware
{
    private readonly RequestDelegate _next;

    // Mapeo: Segmento de ruta del controlador API -> Lista de posibles (Tipo_Pestaña, Nombre_Comercial)
    private static readonly Dictionary<string, List<(string Tipo, string Nombre)>> RutaAInforme = new(StringComparer.OrdinalIgnoreCase)
    {
        ["Actividades"] = new() { ("CONSEJO ELECNOR", "Actividades") },
        ["ActividadesInternacionalDetalle"] = new() { ("COMITÉ", "Detalle Actividades Internacional") },
        ["ActividadesObjetivos"] = new() { ("COMITÉ", "Actividades") },
        ["CarteraContratacionDetalle"] = new() 
        { 
            ("COMITÉ", "Cartera Contratación (Detalle) – Internacional"), 
            ("COMITÉ", "Cartera Contratación (Detalle) Nacional - Internacional")
        },
        ["CarteraContratacionDetalleOrgPaises"] = new() 
        { 
            ("COMITÉ", "Cartera Contratación DG Servicios (Detalle) – Internacional"), 
            ("COMITÉ", "Cartera Contratación DG Servicios (Detalle) Nacional - Internacional"),
            ("COMITÉ", "Cartera Contratación DG Proyectos (Detalle) – Internacional"), 
            ("COMITÉ", "Cartera Contratación DG Proyectos (Detalle) Nacional - Internacional")
        },
        ["CarteraContratacionDetallePaises"] = new() 
        { 
            ("COMITÉ", "Cartera Contratación Paises (Detalle) Internacional"), 
            ("COMITÉ", "Cartera Contratación Paises (Detalle) Nacional - Internacional")
        },
        ["CarteraContratacionResumenSDG"] = new() 
        { 
            ("COMITÉ", "Cartera Contratación x DG (Resumen) – Internacional"), 
            ("COMITÉ", "Cartera Contratación DG (Resumen) Nacional - Internacional")
        },
        ["CarteraDiferidaConsejo"] = new() { ("CONSEJO ELECNOR", "Mercado-AI-Cart. Producción-Cart. Diferida") },
        ["ContratacionesAI"] = new() { ("CONSEJO ELECNOR", "Contratación Asociada a Inversión") },
        ["Contrataciones"] = new() { ("CONSEJO ELECNOR", "Principales Contrataciones Nacionales - Internacionales") },
        ["ContratacionesSignificativas"] = new() 
        { 
            ("CONSEJO ELECNOR", "Contratación Significativa Nacional DG Servicios"),
            ("CONSEJO ELECNOR", "Contratación Significativa Nacional DG Proyectos"),
            ("CONSEJO ELECNOR", "Contratación Significativa Internacional DG Servicios"),
            ("CONSEJO ELECNOR", "Contratación Significativa Internacional DG Proyectos"),
            ("COMITÉ", "Contratación Significativa Internacional DG Servicios"),
            ("COMITÉ", "Contratación Significativa Internacional DG Proyectos")
        },
        ["ContratacionesSignificativasRi"] = new() 
        { 
            ("COMITÉ", "Contrataciones Significativas Nacionales"), 
            ("COMITÉ", "Contrataciones Significativas Internacionales")
        },
        ["Gerencias"] = new() { ("COMITÉ", "Gerencias DG Servicios") },
        ["Mercados"] = new() { ("CONSEJO ELECNOR", "Mercado-Direcciones Generales-Unidades Negocio") },
        ["MercadosDG"] = new() { ("COMITÉ", "Mercado-Direcciones Generales-Unidades Negocio") },
        ["MercadosSGDelegaciones"] = new() { ("COMITÉ", "DG - Unidades Negocio - Delegaciones") },
        ["Paises"] = new() 
        { 
            ("CONSEJO ELECNOR", "Países"), 
            ("CONSEJO ELECNOR", "Todos los Países"), 
            ("COMITÉ", "Mercado Internacional por Países"),
            ("COMITÉ", "Ranking Países (Incluye España)") 
        },
        ["ranking-contratacion-clientes"] = new() 
        { 
            ("CONSEJO ELECNOR", "Ranking Clientes Nacionales"), 
            ("CONSEJO ELECNOR", "Ranking Clientes Internacionales"),
            ("COMITÉ", "Ranking Clientes Nacionales"), 
            ("COMITÉ", "Ranking Clientes Internacionales")
        }
    };

    // Mapeo: Clave técnica JS -> Lista de posibles (Tipo_Pestaña, Nombre_Comercial)
    private static readonly Dictionary<string, List<(string Tipo, string Nombre)>> ClaveAInforme = new(StringComparer.OrdinalIgnoreCase)
    {
        ["cartera_diferida_consejo"] = new() { ("CONSEJO ELECNOR", "Mercado-AI-Cart. Producción-Cart. Diferida") },
        ["mercados"] = new() { ("CONSEJO ELECNOR", "Mercado-Direcciones Generales-Unidades Negocio") },
        ["mercados_dg"] = new() { ("COMITÉ", "Mercado-Direcciones Generales-Unidades Negocio") },
        ["mercados_sg_delegaciones"] = new() { ("COMITÉ", "DG - Unidades Negocio - Delegaciones") },
        ["paises"] = new() { ("CONSEJO ELECNOR", "Países"), ("CONSEJO ELECNOR", "Todos los Países"), ("COMITÉ", "Mercado Internacional por Países") },
        ["paises_all"] = new() { ("COMITÉ", "Ranking Países (Incluye España)") },
        ["actividades"] = new() { ("CONSEJO ELECNOR", "Actividades") },
        ["actividades_objetivos"] = new() { ("COMITÉ", "Actividades") },
        ["contrataciones"] = new() { ("CONSEJO ELECNOR", "Principales Contrataciones Nacionales - Internacionales") },
        ["contrataciones_ai"] = new() { ("CONSEJO ELECNOR", "Contratación Asociada a Inversión") },
        ["contrataciones_significativas"] = new() 
        { 
            ("CONSEJO ELECNOR", "Contratación Significativa Nacional DG Servicios"),
            ("CONSEJO ELECNOR", "Contratación Significativa Nacional DG Proyectos"),
            ("CONSEJO ELECNOR", "Contratación Significativa Internacional DG Servicios"),
            ("CONSEJO ELECNOR", "Contratación Significativa Internacional DG Proyectos"),
            ("COMITÉ", "Contratación Significativa Internacional DG Servicios"),
            ("COMITÉ", "Contratación Significativa Internacional DG Proyectos")
        },
        ["contrataciones_significativas_ri"] = new() { ("COMITÉ", "Contrataciones Significativas Nacionales"), ("COMITÉ", "Contrataciones Significativas Internacionales") },
        ["ranking_contratacion_clientes"] = new() 
        { 
            ("CONSEJO ELECNOR", "Ranking Clientes Nacionales"), 
            ("CONSEJO ELECNOR", "Ranking Clientes Internacionales"),
            ("COMITÉ", "Ranking Clientes Nacionales"), 
            ("COMITÉ", "Ranking Clientes Internacionales")
        },
        ["gerencias"] = new() { ("COMITÉ", "Gerencias DG Servicios") },
        ["cartera_contratacion_detalle"] = new() { ("COMITÉ", "Cartera Contratación (Detalle) – Internacional"), ("COMITÉ", "Cartera Contratación (Detalle) Nacional - Internacional") },
        ["cartera_contratacion_resumen_sdg"] = new() { ("COMITÉ", "Cartera Contratación x DG (Resumen) – Internacional"), ("COMITÉ", "Cartera Contratación DG (Resumen) Nacional - Internacional") },
        ["cartera_contratacion_detalle_org_paises"] = new() 
        { 
            ("COMITÉ", "Cartera Contratación DG Servicios (Detalle) – Internacional"), 
            ("COMITÉ", "Cartera Contratación DG Servicios (Detalle) Nacional - Internacional"),
            ("COMITÉ", "Cartera Contratación DG Proyectos (Detalle) – Internacional"), 
            ("COMITÉ", "Cartera Contratación DG Proyectos (Detalle) Nacional - Internacional")
        },
        ["cartera_contratacion_detalle_paises"] = new() { ("COMITÉ", "Cartera Contratación Paises (Detalle) Internacional"), ("COMITÉ", "Cartera Contratación Paises (Detalle) Nacional - Internacional") },
        ["actividades_internacional_detalle"] = new() { ("COMITÉ", "Detalle Actividades Internacional") }
    };

    public InformeSeguridadMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, InformeSeguridadService seguridadService)
    {
        var path = context.Request.Path.Value;

        if (path != null && path.StartsWith("/api/", StringComparison.OrdinalIgnoreCase))
        {
            var segments = path.Split('/');
            
            if (segments.Length >= 3)
            {
                var controllerName = segments[2];

                // 1. Caso Especial: Exportación a PDF
                if (controllerName.Equals("PdfExport", StringComparison.OrdinalIgnoreCase) && 
                    segments.Length >= 4 && segments[3].Equals("download", StringComparison.OrdinalIgnoreCase))
                {
                    var reportName = await ObtenerReportNameDePdfExportAsync(context);
                    if (!string.IsNullOrEmpty(reportName))
                    {
                        var puesto = context.User.FindFirst("Puesto")?.Value;
                        if (!string.IsNullOrEmpty(puesto))
                        {
                            bool tieneAcceso = await ValidarAccesoPorClaveTecnicaAsync(seguridadService, puesto, reportName);
                            if (!tieneAcceso)
                            {
                                await RetornarAccesoDenegadoAsync(context);
                                return;
                            }
                        }
                    }
                }
                // 2. Caso Especial: HTML Portable
                else if (controllerName.Equals("InformePortable", StringComparison.OrdinalIgnoreCase) && segments.Length >= 4)
                {
                    var tipoInforme = segments[3];
                    var puesto = context.User.FindFirst("Puesto")?.Value;
                    if (!string.IsNullOrEmpty(puesto))
                    {
                        bool tieneAcceso = await ValidarAccesoPorClaveTecnicaAsync(seguridadService, puesto, tipoInforme);
                        if (!tieneAcceso)
                        {
                            await RetornarAccesoDenegadoAsync(context);
                            return;
                        }
                    }
                }
                // 2b. Caso Especial: API de Descarga PDF REST
                else if (controllerName.Equals("PdfRpt", StringComparison.OrdinalIgnoreCase) && segments.Length >= 4)
                {
                    var tipoInforme = segments[3];
                    var puesto = context.User.FindFirst("Puesto")?.Value;
                    if (!string.IsNullOrEmpty(puesto))
                    {
                        bool tieneAcceso = await ValidarAccesoPorClaveTecnicaAsync(seguridadService, puesto, tipoInforme);
                        if (!tieneAcceso)
                        {
                            await RetornarAccesoDenegadoAsync(context);
                            return;
                        }
                    }
                }
                // 2c. Caso Especial: API de Descarga HTML Portable REST
                else if (controllerName.Equals("HtmlRpt", StringComparison.OrdinalIgnoreCase) && segments.Length >= 4)
                {
                    var tipoInforme = segments[3];
                    var puesto = context.User.FindFirst("Puesto")?.Value;
                    if (!string.IsNullOrEmpty(puesto))
                    {
                        bool tieneAcceso = await ValidarAccesoPorClaveTecnicaAsync(seguridadService, puesto, tipoInforme);
                        if (!tieneAcceso)
                        {
                            await RetornarAccesoDenegadoAsync(context);
                            return;
                        }
                    }
                }
                // 3. Controladores de Informes Ordinarios
                else if (RutaAInforme.TryGetValue(controllerName, out var informesAsociados))
                {
                    var puesto = context.User.FindFirst("Puesto")?.Value;
                    if (!string.IsNullOrEmpty(puesto))
                    {
                        bool tieneAcceso = false;
                        foreach (var (tipo, nombre) in informesAsociados)
                        {
                            if (await seguridadService.TieneAccesoAsync(puesto, tipo, nombre))
                            {
                                tieneAcceso = true;
                                break;
                            }
                        }

                        if (!tieneAcceso)
                        {
                            await RetornarAccesoDenegadoAsync(context);
                            return;
                        }
                    }
                }
            }
        }

        await _next(context);
    }

    private async Task<string?> ObtenerReportNameDePdfExportAsync(HttpContext context)
    {
        try
        {
            context.Request.EnableBuffering();
            context.Request.Body.Position = 0;

            using (var reader = new StreamReader(context.Request.Body, leaveOpen: true))
            {
                var body = await reader.ReadToEndAsync();
                context.Request.Body.Position = 0;

                using var doc = JsonDocument.Parse(body);
                if (doc.RootElement.TryGetProperty("ReportName", out var prop))
                {
                    return prop.GetString();
                }
            }
        }
        catch
        {
            // Fallback pasivo
        }
        return null;
    }

    private async Task<bool> ValidarAccesoPorClaveTecnicaAsync(InformeSeguridadService seguridadService, string puesto, string claveTecnica)
    {
        if (ClaveAInforme.TryGetValue(claveTecnica, out var informes))
        {
            foreach (var (tipo, nombre) in informes)
            {
                if (await seguridadService.TieneAccesoAsync(puesto, tipo, nombre))
                {
                    return true;
                }
            }
        }
        return false;
    }

    private static async Task RetornarAccesoDenegadoAsync(HttpContext context)
    {
        context.Response.StatusCode = StatusCodes.Status403Forbidden;
        context.Response.ContentType = "application/json";
        var errorResponse = new { message = "Acceso restringido. Su puesto de trabajo no cuenta con privilegios para consultar este informe." };
        await context.Response.WriteAsJsonAsync(errorResponse);
    }
}
