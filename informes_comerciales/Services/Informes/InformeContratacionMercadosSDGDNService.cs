using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosSDGDN;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes
{
    /// <summary>
    /// Servicio para el informe "DG - Unidades Negocio - Mercado".
    /// Migracion del informe Access Contratacion_Mercados_SDG_Agrupado_DN
    /// (padre + subinforme → unico informe web con DTO jerarquico).
    ///
    /// Reglas aplicadas:
    /// - Orden en C# (NO en SQL): el Repository NO lleva ORDER BY.
    /// - Division por 1000 en Service.
    /// - Variacion via InformeCalculosUtils.CalcularVariacionContratacion.
    /// - IP via InformeCalculosUtils.CalcularIp (retorna 0 si objetivo=0).
    /// - Sin objetivos por diseno (omite ImporteObjetivo del SP).
    /// </summary>
    public class InformeContratacionMercadosSDGDNService
    {
        private readonly InformeRepository _repository;

        public InformeContratacionMercadosSDGDNService(InformeRepository repository)
        {
            _repository = repository;
        }

        public async Task<ContratacionMercadosSDGDNResponseDto> ObtenerInformeAsync(
            int anio, int mes, string loginUsuario)
        {
            var datos = await _repository.ObtenerContratacionSDGDNAsync(anio, mes, loginUsuario);

            var response = new ContratacionMercadosSDGDNResponseDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "DG - Unidades Negocio - Mercado",
                    Descripcion = "Contratacion por Subdireccion General - Agrupado por Direccion de Negocio",
                    Filtros = new { anio, mes, subdireccion = "221" },
                    FechaGeneracion = DateTime.Now,
                    Usuario = loginUsuario,
                    MostrarNumeroPagina = true,
                    MostrarTitulo = false
                }
            };

            if (datos == null || !datos.Any())
                return response;

            // Orden en C#: Orden_CodDDirNegocio → Nacional antes que Internacional
            var datosOrdenados = datos
                .OrderBy(d => d.Orden_CodDDirNegocio)
                .ThenBy(d => d.Pais == "Nacional" ? 0 : 1)
                .ToList();

            // Bloque 1: Resumen por Mercado (Nacional / Internacional)
            var resumenes = datosOrdenados
                .GroupBy(d => (d.Pais ?? string.Empty).Trim())
                .Select(g => ConstruirResumenMercado(g.Key, g.ToList(), mes))
                .OrderBy(r => r.Pais == "Nacional" ? 0 : 1)
                .ToList();
            response.ResumenPorMercado.AddRange(resumenes);

            // Bloque 1b: Total Global (calculado sobre importes reales y luego redondeado)
            decimal realContMes = datos.Sum(d => d.ImporteContratado) / 1000m;
            decimal realContAcum = datos.Sum(d => d.ImporteContratadoAcumulado) / 1000m;
            decimal realContAcumAnt = datos.Sum(d => d.ImporteContratadoAcumuladoAnterior) / 1000m;
            decimal realObjAnual = datos.Sum(d => d.Objetivo);
            decimal realObjMensual = realObjAnual / 12m;

            decimal totalContMes = Math.Round(realContMes, 0, MidpointRounding.AwayFromZero);
            decimal totalContAcum = Math.Round(realContAcum, 0, MidpointRounding.AwayFromZero);
            decimal totalContAcumAnt = Math.Round(realContAcumAnt, 0, MidpointRounding.AwayFromZero);
            decimal totalObjAnual = Math.Round(realObjAnual, 0, MidpointRounding.AwayFromZero);
            decimal totalObjMensual = Math.Round(realObjMensual, 0, MidpointRounding.AwayFromZero);

            response.TotalGlobal = new TotalesGlobalesDto
            {
                ContratacionMensual           = totalContMes,
                ContratacionAcumulado         = totalContAcum,
                ContratacionAcumuladoAnterior = totalContAcumAnt,
                ObjetivoAnual                 = totalObjAnual,
                ObjetivoMensual               = totalObjMensual,
                Ip                            = InformeCalculosUtils.CalcularIp(realContAcum, realObjMensual, mes),
                VariacionContratacion         = InformeCalculosUtils.CalcularVariacionContratacion(realContAcumAnt, realContAcum)
            };

            // Bloque 2: Detalle por Dirección de Negocio (DN) + Subtotales por DN
            var detallesYSubtotales = new List<DetalleDNDto>();

            var gruposPorDN = datosOrdenados
                .GroupBy(d => d.NombreDirNegocio ?? string.Empty)
                .ToList();

            foreach (var grupo in gruposPorDN)
            {
                var filasGrupo = grupo.ToList();
                
                // 1) Filas de detalle (Nacional / Internacional)
                foreach (var d in filasGrupo)
                {
                    var dtoDetalle = ConstruirDetalleDN(d, mes);
                    // Omitir filas completamente vacías (sin objetivos ni contratación)
                    if (dtoDetalle.ContratacionMensual == 0 && dtoDetalle.ContratacionAcumulado == 0 && dtoDetalle.ObjetivoAnual == 0)
                    {
                        continue;
                    }
                    detallesYSubtotales.Add(dtoDetalle);
                }

                // 2) Fila de Subtotal de la Dirección de Negocio (si hay más de 1 fila o para dar consistencia al reporte de Access)
                decimal sumaContMes = filasGrupo.Sum(d => d.ImporteContratado) / 1000m;
                decimal sumaContAcum = filasGrupo.Sum(d => d.ImporteContratadoAcumulado) / 1000m;
                decimal sumaContAcumAnt = filasGrupo.Sum(d => d.ImporteContratadoAcumuladoAnterior) / 1000m;
                decimal sumaObjAnual = filasGrupo.Sum(d => d.Objetivo);
                decimal sumaObjMensual = sumaObjAnual / 12m;

                var subtotalDN = new DetalleDNDto
                {
                    OrdenDN                       = filasGrupo.First().Orden_CodDDirNegocio,
                    CodDDirNegocio                = filasGrupo.First().CodDDirNegocio ?? string.Empty,
                    NombreDirNegocio              = grupo.Key,
                    Pais                          = string.Empty, // Se deja vacío para el estilo del subtotal
                    ContratacionMensual           = Math.Round(sumaContMes, 0, MidpointRounding.AwayFromZero),
                    ContratacionAcumulado         = Math.Round(sumaContAcum, 0, MidpointRounding.AwayFromZero),
                    ContratacionAcumuladoAnterior = Math.Round(sumaContAcumAnt, 0, MidpointRounding.AwayFromZero),
                    ObjetivoAnual                 = Math.Round(sumaObjAnual, 0, MidpointRounding.AwayFromZero),
                    EsSubtotal                    = true,
                    Ip                            = InformeCalculosUtils.CalcularIp(sumaContAcum, sumaObjMensual, mes),
                    VariacionContratacion         = InformeCalculosUtils.CalcularVariacionContratacion(sumaContAcumAnt, sumaContAcum),
                    Umbral                        = 0.04m, // Genérico para el grupo
                    SuperaUmbral                  = false
                };

                detallesYSubtotales.Add(subtotalDN);
            }

            response.DetallesPorDN = detallesYSubtotales;

            // Marcar SuperaUmbral post-construccion en las filas que no sean subtotales
            foreach (var d in response.DetallesPorDN)
            {
                if (!d.EsSubtotal && decimal.TryParse(
                    d.VariacionContratacion.Replace("%", "").Trim(),
                    out var vPct))
                {
                    d.SuperaUmbral = vPct < (-d.Umbral * 100m);
                }
            }

            return response;
        }

        private ResumenMercadoDto ConstruirResumenMercado(string pais, List<ContratacionSDGDNPoco> datos, int mes)
        {
            decimal contMes     = datos.Sum(d => d.ImporteContratado) / 1000m;
            decimal contAcum    = datos.Sum(d => d.ImporteContratadoAcumulado) / 1000m;
            decimal contAcumAnt = datos.Sum(d => d.ImporteContratadoAcumuladoAnterior) / 1000m;
            decimal objAnual    = datos.Sum(d => d.Objetivo);
            decimal objMensual  = objAnual / 12m;

            return new ResumenMercadoDto
            {
                Pais                          = pais,
                ContratacionMensual           = Math.Round(contMes,     0, MidpointRounding.AwayFromZero),
                ContratacionAcumulado         = Math.Round(contAcum,    0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoAnterior = Math.Round(contAcumAnt, 0, MidpointRounding.AwayFromZero),
                ObjetivoAnual                 = Math.Round(objAnual,    0, MidpointRounding.AwayFromZero),
                ObjetivoMensual               = Math.Round(objMensual,  0, MidpointRounding.AwayFromZero),
                Ip                            = InformeCalculosUtils.CalcularIp(contAcum, objMensual, mes),
                VariacionContratacion         = InformeCalculosUtils.CalcularVariacionContratacion(contAcumAnt, contAcum),
                UmbralTexto                   = pais == "Nacional" ? "-4%" : "-10%"
            };
        }

        private DetalleDNDto ConstruirDetalleDN(ContratacionSDGDNPoco d, int mes)
        {
            decimal contMes     = d.ImporteContratado / 1000m;
            decimal contAcum    = d.ImporteContratadoAcumulado / 1000m;
            decimal contAcumAnt = d.ImporteContratadoAcumuladoAnterior / 1000m;
            decimal objAnual    = d.Objetivo;
            decimal objMensual  = objAnual / 12m;

            string pais = d.Pais ?? string.Empty;

            return new DetalleDNDto
            {
                OrdenDN                       = d.Orden_CodDDirNegocio,
                CodDDirNegocio                = d.CodDDirNegocio ?? string.Empty,
                NombreDirNegocio              = d.NombreDirNegocio ?? string.Empty,
                CodSubDirGeneral              = d.CodSubDirGeneral ?? string.Empty,
                NombreSubDirGeneral           = d.NombreSubDirGeneral ?? string.Empty,
                Pais                          = pais,
                ContratacionMensual           = Math.Round(contMes,     0, MidpointRounding.AwayFromZero),
                ContratacionAcumulado         = Math.Round(contAcum,    0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoAnterior = Math.Round(contAcumAnt, 0, MidpointRounding.AwayFromZero),
                ObjetivoAnual                 = Math.Round(objAnual,    0, MidpointRounding.AwayFromZero),
                EsSubtotal                    = false,
                Ip                            = InformeCalculosUtils.CalcularIp(contAcum, objMensual, mes),
                VariacionContratacion         = InformeCalculosUtils.CalcularVariacionContratacion(contAcumAnt, contAcum),
                Umbral                        = pais == "Nacional" ? 0.04m : 0.10m,
                UmbralTexto                   = pais == "Nacional" ? "-4%" : "-10%",
                SuperaUmbral                  = false
            };
        }
    }
}
