using Elecnor_Informes_Comerciales.Models.Informes.CarteraDiferidaConsejo;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;
using System.Collections.Generic;
using System.Linq;
using System;

namespace Elecnor_Informes_Comerciales.Services.Informes
{
    /// <summary>
    /// Servicio para el informe Cartera Diferida Consejo.
    /// </summary>
    public class InformeCarteraDiferidaConsejoService
    {
        private readonly InformeRepository _repository;

        public InformeCarteraDiferidaConsejoService(InformeRepository repository)
        {
            _repository = repository;
        }

        public async Task<CarteraDiferidaConsejoDto> ObtenerInformeAsync(int anio, int mes, int? nroPagina)
        {
            var (principal, subreporte, cartera, carteraDiferida, ventas) = await _repository.ObtenerCarteraDiferidaConsejoAsync(anio, mes);

            // Validación de datos nulos o vacíos
            if (principal == null || !principal.Any())
            {
                return new CarteraDiferidaConsejoDto
                {
                    Meta = new MetaInformeDto
                    {
                        Titulo = "Cartera Diferida Consejo",
                        Descripcion = "Informe de Contratación por Mercados (Consejo Administración)",
                        Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                        FechaGeneracion = DateTime.Now,
                        Usuario = "Sistema"
                    },
                    Agrupaciones = new List<AgrupacionAñoDto>(),
                    PieTotal = new TotalesEstandarDto()
                };
            }

            var response = new CarteraDiferidaConsejoDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "Cartera Diferida Consejo",
                    Descripcion = "Informe de Contratación por Mercados (Consejo Administración)",
                    Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                    FechaGeneracion = DateTime.Now,
                    Usuario = "Sistema"
                },
                Agrupaciones = principal
                    .GroupBy(p => p.Año)
                    .OrderBy(g => g.Key)
                    .Select(gAño => {
                        var listaGlobalPrincipal = gAño.ToList();
                        var dataSubreporteAnio = subreporte.Where(s => s.Año == gAño.Key).ToList();
                        var dataCarteraAnio = cartera.Where(c => c.Año == gAño.Key).ToList();
                        var dataCarteraDiferidaAnio = carteraDiferida.Where(c => c.Año == gAño.Key).ToList();
                        var totalesSeccionPrincipal = CalcularTotalesSeccion(listaGlobalPrincipal, mes);

                        return new AgrupacionAñoDto
                        {
                            Año = gAño.Key,
                            Detalles = listaGlobalPrincipal
                                .Select(d => new MercadoDetalleDto
                                {
                                    Pais = d.Pais,
                                    ObjetivoMensual = d.ObjetivosMensual,
                                    ImporteContratadoMensual = d.Importe_Contratado,
                                    ObjetivoAnual = d.Objetivos,
                                    ImporteContratadoAcumulado = d.Importe_ContratadoAcumulado,
                                    IndiceProduccion = InformeCalculosUtils.CalcularIp(d.Importe_ContratadoAcumulado, d.Objetivos / 12, mes),
                                    Variacion = InformeCalculosUtils.CalcularVariacionContratacion(d.ImporteContratadoAcumuladoAñoAnterior, d.Importe_ContratadoAcumulado)
                                })
                                .OrderByDescending(x => x.Pais)
                                .ToList(),
                            Totales = totalesSeccionPrincipal,
                            SubMercadosAI = dataSubreporteAnio
                                .Select(s => new SubMercadoAIDto
                                {
                                    Mercado = s.Mercado,
                                    ImporteContratadoMensual = s.Mensual_Contratacion,
                                    ImporteContratadoAcumulado = s.Acumulado_Contratacion,
                                    PorcentajeSobreMercado = Math.Round(s.Mer * 1000 * 100, 2, MidpointRounding.AwayFromZero),
                                    Variacion = InformeCalculosUtils.CalcularVariacionLibre(s.Acumulado_ContratacionAñoAnterior, s.Acumulado_Contratacion)
                                })
                                .OrderByDescending(x => x.Mercado)
                                .ToList(),
                            TotalesAI = CalcularTotalesSeccionAI(dataSubreporteAnio, totalesSeccionPrincipal.ContratacionAcumulada),
                            CarteraProduccion = CalcularSubinformeCartera(dataCarteraAnio, gAño.Key, mes),
                            CarteraDiferida = CalcularSubinformeCarteraDiferida(dataCarteraDiferidaAnio, gAño.Key, mes),
                            Ventas = CalcularSubinformeVentas(ventas)
                        };
                    }).ToList(),
                PieTotal = CalcularTotalesGlobales(principal, mes)
            };

            return response;
        }

        /// <summary>
        /// Calcula totales para subinforme AI.
        /// Retorna TotalesEstandarDto para homogeneizar el payload JSON.
        /// </summary>
        private TotalesEstandarDto CalcularTotalesSeccionAI(List<MercadoAIPoco> datos, decimal totalPrincipalAcum)
        {
            if (datos == null || !datos.Any()) return new TotalesEstandarDto();

            var totalMensual = datos.Sum(x => x.Mensual_Contratacion);
            var totalAcum = datos.Sum(x => x.Acumulado_Contratacion);
            var totalAnterior = datos.Sum(x => x.Acumulado_ContratacionAñoAnterior);

            decimal porcentaje = totalPrincipalAcum == 0 ? 0 : (totalAcum * 1000 / totalPrincipalAcum) * 100;

            return new TotalesEstandarDto
            {
                ContratacionMensual = totalMensual,
                ContratacionAcumulada = totalAcum,
                PorcentajeSobreMercado = Math.Round(porcentaje, 2, MidpointRounding.AwayFromZero),
                VariacionCartera = InformeCalculosUtils.CalcularVariacionLibre(totalAnterior, totalAcum)
            };
        }

        /// <summary>
        /// Procesa los datos del subinforme de Cartera Pendiente Producir.
        /// </summary>
        private CarteraProducirDto CalcularSubinformeCartera(List<CarteraProducirPoco> datos, int anio, int mes)
        {
            if (datos == null || !datos.Any()) return new CarteraProducirDto();

            var mesNombre = InformeCalculosUtils.GetNombreMes(mes);
            var mesCorto = mesNombre.Length > 3 ? mesNombre.Substring(0, 3) : mesNombre;

            var dto = new CarteraProducirDto
            {
                TituloColInicial = $"31.12.{anio - 1}",
                TituloColActual = $"{mesCorto} {anio}",
                TituloColDelta = $"Δ Dic {anio - 1}",
                Lineas = datos.Select(d => new CarteraLineaDto
                {
                    Concepto = ((d.Concepto == "Nacional" || d.Concepto == "Internacional") && d.SumarCartera == 0)
                               ? $"     {d.Concepto}" 
                               : d.Concepto,
                    ImporteInicial = d.ImporteInicial,
                    ImporteActual = d.ImporteActual,
                    PorcentajeIncremento = d.ImporteInicial == 0 ? null : (d.ImporteActual - d.ImporteInicial) * 100 / d.ImporteInicial,
                    IsIndented = (d.Concepto == "Nacional" || d.Concepto == "Internacional") && d.SumarCartera == 0,
                    IsMainConcept = d.SumarCartera == 1
                }).ToList()
            };

            var lineasTotales = datos.Where(x => x.SumarCartera == 1).ToList();
            if (lineasTotales.Any())
            {
                var totalInicial = lineasTotales.Sum(x => x.ImporteInicial);
                var totalActual = lineasTotales.Sum(x => x.ImporteActual);
                var totalAñoAnterior = lineasTotales.Sum(x => x.CarteraAñoAnterior);

                dto.Totales = new CarteraTotalesDto
                {
                    ImporteInicial = totalInicial,
                    ImporteActual = totalActual,
                    VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(totalInicial, totalActual),
                    VariacionAñoAnterior = InformeCalculosUtils.CalcularVariacionCartera(totalAñoAnterior, totalInicial)
                };
            }

            return dto;
        }

        /// <summary>
        /// Obtiene y transforma el subinforme de Cartera Diferida (Consejo)
        /// </summary>
        private CarteraDiferidaDto CalcularSubinformeCarteraDiferida(List<CarteraDiferidaPoco> datos, int anio, int mes)
        {
            if (!datos.Any()) return new CarteraDiferidaDto();

            var dto = new CarteraDiferidaDto
            {
                TituloColInicial = $"1.1.{anio.ToString().Substring(2, 2)}",
                TituloColAnio1 = anio.ToString(),
                TituloColAnio2 = (anio + 1).ToString(),
                TituloColAnio3 = (anio + 2).ToString(),
                Lineas = datos.OrderBy(d => d.Orden).Select(d => new CarteraDiferidaLineaDto
                {
                    Concepto = d.CarteraDiferida,
                    Cart1_1 = d.Cart1_1,
                    Nuevos = d.Nuevos,
                    Total = d.Total,
                    Contr = d.Contr,
                    Ip = InformeCalculosUtils.CalcularIp(d.Contr, d.Total / 12, mes),
                    Anio1 = d.Anio1,
                    Anio2 = d.Anio2,
                    Anio3 = d.Anio3
                }).ToList(),
                Totales = new CarteraDiferidaTotalesDto
                {
                    Cart1_1 = datos.Sum(d => d.Cart1_1),
                    Nuevos = datos.Sum(d => d.Nuevos),
                    Total = datos.Sum(d => d.Total),
                    Contr = datos.Sum(d => d.Contr),
                    Ip = InformeCalculosUtils.CalcularIp(datos.Sum(d => d.Contr), datos.Sum(d => d.Total / 12), mes),
                    Anio1 = datos.Sum(d => d.Anio1),
                    Anio2 = datos.Sum(d => d.Anio2),
                    Anio3 = datos.Sum(d => d.Anio3)
                }
            };
            
            return dto;
        }

        /// <summary>
        /// Calcula totales para una sección del informe principal.
        /// Retorna TotalesEstandarDto para homogeneizar el payload JSON.
        /// </summary>
        private TotalesEstandarDto CalcularTotalesSeccion(IEnumerable<CarteraDiferidaConsejoPoco> datos, int mes)
        {
            var lista = datos.ToList();
            var totalObjAnual = lista.Sum(x => x.Objetivos);
            var totalContrAcum = lista.Sum(x => x.Importe_ContratadoAcumulado);
            var totalContrAnterior = lista.Sum(x => x.ImporteContratadoAcumuladoAñoAnterior);

            return new TotalesEstandarDto
            {
                ObjetivoMensual = lista.Sum(x => x.ObjetivosMensual),
                ContratacionMensual = lista.Sum(x => x.Importe_Contratado),
                ObjetivoAnual = totalObjAnual,
                ContratacionAcumulada = totalContrAcum,
                IndiceProduccion = InformeCalculosUtils.CalcularIp(totalContrAcum, totalObjAnual / 12, mes),
                VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalContrAnterior, totalContrAcum)
            };
        }

        /// <summary>
        /// Calcula totales globales del informe.
        /// Retorna TotalesEstandarDto para homogeneizar el payload JSON.
        /// </summary>
        private TotalesEstandarDto CalcularTotalesGlobales(IEnumerable<CarteraDiferidaConsejoPoco> datos, int mes)
        {
            var lista = datos.ToList();
            var totalObjAnual = lista.Sum(x => x.Objetivos);
            var totalContrAcum = lista.Sum(x => x.Importe_ContratadoAcumulado);
            var totalContrAnterior = lista.Sum(x => x.ImporteContratadoAcumuladoAñoAnterior);

            return new TotalesEstandarDto
            {
                ObjetivoMensual = lista.Sum(x => x.ObjetivosMensual),
                ContratacionMensual = lista.Sum(x => x.Importe_Contratado),
                ObjetivoAnual = totalObjAnual,
                ContratacionAcumulada = totalContrAcum,
                IndiceProduccion = InformeCalculosUtils.CalcularIp(totalContrAcum, totalObjAnual / 12, mes),
                VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalContrAnterior, totalContrAcum)
            };
        }
        /// <summary>
        /// Construye el subinforme de Ventas a partir del dataset plano de VentasRPT.
        /// No tiene filtro por año (los datos son estáticos de la tabla VentasRPT).
        /// </summary>
        private VentasDto CalcularSubinformeVentas(List<VentasPoco> datos)
        {
            if (datos == null || !datos.Any()) return new VentasDto();

            var lineas = datos.Select(d => new VentasLineaDto
            {
                Mercado  = d.Mercado,
                Anio2017 = d.Anio2017,
                Anio2018 = d.Anio2018,
                Anio2019 = d.Anio2019,
                Anio2020 = d.Anio2020,
                Anio2021 = d.Anio2021,
                Anio2022 = d.Anio2022,
                Anio2023 = d.Anio2023,
                Anio2024 = d.Anio2024,
                Anio2025 = d.Anio2025
            }).ToList();

            var totales = new VentasTotalesDto
            {
                Total2017 = datos.Sum(d => d.Anio2017 ?? 0),
                Total2018 = datos.Sum(d => d.Anio2018 ?? 0),
                Total2019 = datos.Sum(d => d.Anio2019 ?? 0),
                Total2020 = datos.Sum(d => d.Anio2020 ?? 0),
                Total2021 = datos.Sum(d => d.Anio2021 ?? 0),
                Total2022 = datos.Sum(d => d.Anio2022 ?? 0),
                Total2023 = datos.Sum(d => d.Anio2023 ?? 0),
                Total2024 = datos.Sum(d => d.Anio2024 ?? 0),
                Total2025 = datos.Sum(d => d.Anio2025 ?? 0)
            };

            return new VentasDto { Lineas = lineas, Totales = totales };
        }
    }
}
