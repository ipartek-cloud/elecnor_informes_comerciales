using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Models.Informes.Mercados;
using Elecnor_Informes_Comerciales.Models.Informes.MercadosDG;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes
{
    /// <summary>
    /// Servicio para el informe D.G. Infraestructuras x Mercado.
    /// </summary>
    public class InformeMercadosDGService
    {
        private readonly InformeRepository _informeRepository;

        public InformeMercadosDGService(InformeRepository informeRepository)
        {
            _informeRepository = informeRepository;
        }

        public async Task<MercadosDGResponseDto> ObtenerInformeMercadosDGAsync(int anio, int mes)
        {
            var taskMercados = _informeRepository.ObtenerMercadosAsync(anio, mes);
            var taskCarteraDiferida = _informeRepository.ObtenerMercadosDGCarteraDiferidaAsync(anio, mes);

            await Task.WhenAll(taskMercados, taskCarteraDiferida);

            var datosMercados = taskMercados.Result;
            var datosCarteraDiferida = taskCarteraDiferida.Result;

            var response = new MercadosDGResponseDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "D.G. Infraestructuras x Mercados",
                    Descripcion = "Informe de Contratación — D.G. Infraestructuras",
                    Filtros = new { anio = anio, mes = mes },
                    FechaGeneracion = DateTime.Now
                }
            };

            if (datosMercados == null || !datosMercados.Any())
            {
                response.CarteraDiferida = CalcularSubinformeCarteraDiferida(datosCarteraDiferida);
                return response;
            }

            int mesActual = mes;

            var datosValidos = datosMercados.Where(d => !string.IsNullOrWhiteSpace(d.Pais)).ToList();
            foreach (var d in datosValidos) { d.Pais = d.Pais.Trim(); }

            var globalMercados = datosValidos.GroupBy(d => d.Pais)
                                             .Select(g => CrearFilaDato(g.Key, g, true, true, mesActual))
                                             .OrderBy(f => f.Nombre)
                                             .ToList();

            response.ResumenGlobal.AddRange(globalMercados);

            response.TotalGlobal = new FilaDatoDto
            {
                Nombre = "TOTAL",
                Mensual = SumarValores(globalMercados.Select(m => m.Mensual)),
                Acumulado = SumarValores(globalMercados.Select(m => m.Acumulado))
            };

            CalcularPorcentajes(response.TotalGlobal.Mensual, 1);
            CalcularPorcentajes(response.TotalGlobal.Acumulado, mesActual);

            response.DirNegocios = datosValidos.Where(d => !string.IsNullOrWhiteSpace(d.NombreSubDirGeneral))
                                                .GroupBy(d => d.NombreSubDirGeneral)
                                                .Select(gSDG => new DirNegocioItemDto
                                                {
                                                    Nombre = gSDG.Key!,
                                                    // Mercados (Nac/Int) por DG
                                                    Mercados = gSDG.GroupBy(d => d.Pais)
                                                        .Select(gPais => CrearFilaDato(gPais.Key!, gPais, false, true, mesActual))
                                                        .OrderByDescending(f => f.Nombre)
                                                        .ToList(),
                                                    // Unidades de Negocio por DG
                                                    Unidades = gSDG.GroupBy(d => d.NombreDirNegocio)
                                                        .Select(gDN => CrearFilaDato(gDN.Key!, gDN, false, false, mesActual))
                                                        .OrderBy(f => f.Nombre)
                                                        .ToList(),
                                                    // Totales de la Dirección de Negocio
                                                    Total = new FilaDatoDto
                                                    {
                                                        Nombre = "TOTAL " + gSDG.Key,
                                                        Mensual = SumarValores(gSDG.GroupBy(p => p.Pais).Select(gP => CrearFilaDato(gP.Key!, gP, false, true, mesActual).Mensual)),
                                                        Acumulado = SumarValores(gSDG.GroupBy(p => p.Pais).Select(gP => CrearFilaDato(gP.Key!, gP, false, true, mesActual).Acumulado))
                                                    }
                                                })
                                                .OrderBy(d => d.Nombre)
                                                .ToList();

            foreach (var dn in response.DirNegocios)
            {
                CalcularPorcentajes(dn.Total.Mensual, 1);
                CalcularPorcentajes(dn.Total.Acumulado, mesActual);
            }

            response.CarteraDiferida = CalcularSubinformeCarteraDiferida(datosCarteraDiferida);

            return response;
        }

        /**
         * Mapea un grupo de datos a una fila de informe (DTO).
         */
        private FilaDatoDto CrearFilaDato(string nombre, IEnumerable<MercadosPoco> datos, bool esResumenGlobal = false, bool esPais = false, int mesActual = 1)
        {
            decimal objetivoBase;

            if (esResumenGlobal)
            {
                objetivoBase = datos.Any() ? datos.Max(d => d.ObjetivoPais) : 0;
            }
            else if (esPais)
            {
                objetivoBase = datos.Any() ? datos.Max(d => d.ObjetivoSDGPais) : 0;
            }
            else
            {
                objetivoBase = datos.Sum(d => d.ImporteObjetivo);
            }

            var fila = new FilaDatoDto
            {
                Nombre = nombre,
                Mensual = new ValoresSeccionDto
                {
                    ImporteContratado = datos.Sum(d => d.ImporteContratado) / 1000,
                    ImporteObjetivo = objetivoBase / 12,
                },
                Acumulado = new ValoresSeccionDto
                {
                    ImporteContratado = datos.Sum(d => d.ImporteContratadoAcumulado) / 1000,
                    ImporteObjetivo = objetivoBase,
                    ImporteAñoAnterior = datos.Sum(d => d.ImporteContratadoAcumuladoAñoAnterior) / 1000
                }
            };

            CalcularPorcentajes(fila.Mensual, 1);
            CalcularPorcentajes(fila.Acumulado, mesActual);

            return fila;
        }

        private ValoresSeccionDto SumarValores(IEnumerable<ValoresSeccionDto> valores)
        {
            return new ValoresSeccionDto
            {
                ImporteContratado = valores.Sum(v => v.ImporteContratado),
                ImporteObjetivo = valores.Sum(v => v.ImporteObjetivo),
                ImporteAñoAnterior = valores.Sum(v => v.ImporteAñoAnterior)
            };
        }

        private void CalcularPorcentajes(ValoresSeccionDto seccion, int nMeses)
        {
            decimal objetivoMensualParaUtilidad = nMeses == 1
                ? seccion.ImporteObjetivo
                : seccion.ImporteObjetivo / 12;

            seccion.IndiceProduccion = InformeCalculosUtils.CalcularIp(seccion.ImporteContratado, objetivoMensualParaUtilidad, nMeses);

            // Variación %
            if (seccion.ImporteAñoAnterior == 0)
            {
                seccion.Variacion = "-";
            }
            else
            {
                decimal vContratacion = (seccion.ImporteContratado - seccion.ImporteAñoAnterior) / Math.Abs(seccion.ImporteAñoAnterior);

                if (vContratacion > 10 || seccion.ImporteContratado < 0)
                {
                    seccion.Variacion = ">1000%";
                }
                else if (vContratacion < -10)
                {
                    seccion.Variacion = "<-1000%";
                }
                else
                {
                    seccion.Variacion = Math.Round(vContratacion * 100, 0).ToString() + "%";
                }
            }
        }

        /// <summary>
        /// Transforma los datos crudos del subinforme Cartera Diferida.
        /// </summary>
        private MercadosDGCarteraDiferidaDto CalcularSubinformeCarteraDiferida(List<MercadosDGCarteraDiferidaPoco> datos)
        {
            if (datos == null || !datos.Any()) return new MercadosDGCarteraDiferidaDto();

            var datosOrdenados = datos.OrderBy(d => d.Orden).ToList();

            return new MercadosDGCarteraDiferidaDto
            {
                Lineas = datosOrdenados.Select(d => new MercadosDGCarteraDiferidaLineaDto
                {
                    Concepto = d.CarteraDiferida,
                    ValorCartPrev = d.ValorCartPrev,
                    ValorCartAct = d.ValorCartAct,
                    ValorFuturo1 = d.ValorFuturo1,
                    ValorFuturo2 = d.ValorFuturo2
                }).ToList(),
                Totales = new MercadosDGCarteraDiferidaTotalesDto
                {
                    ValorCartPrev = datosOrdenados.Sum(d => d.ValorCartPrev),
                    ValorCartAct = datosOrdenados.Sum(d => d.ValorCartAct),
                    ValorFuturo1 = datosOrdenados.Sum(d => d.ValorFuturo1),
                    ValorFuturo2 = datosOrdenados.Sum(d => d.ValorFuturo2)
                }
            };
        }
    }
}
