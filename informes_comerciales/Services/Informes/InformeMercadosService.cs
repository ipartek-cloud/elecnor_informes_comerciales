using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Models.Informes.Mercados;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes
{
    public class InformeMercadosService
    {
        private readonly InformeRepository _informeRepository;

        public InformeMercadosService(InformeRepository informeRepository)
        {
            _informeRepository = informeRepository;
        }

        public async Task<MercadosResponseDto> ObtenerInformeMercadosAsync(int anio, int mes, int nroPagina, string loginUsuario)
        {
            var datos = await _informeRepository.ObtenerMercadosAsync(anio, mes, loginUsuario);

            var response = new MercadosResponseDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "Mercados",
                    Filtros = new { anio = anio, mes = mes, nroPagina = nroPagina },
                    FechaGeneracion = DateTime.Now
                }
            };

            if (datos == null || !datos.Any()) return response;

            int mesActual = mes; // Guardamos el mes del informe para el cálculo de IP

            // Normalizar Pais (trim) para evitar duplicados por espacios y filtrar nulos/vacíos
            var datosValidos = datos
                .Where(d => !string.IsNullOrWhiteSpace(d.Pais))
                .ToList();

            foreach (var d in datosValidos) { d.Pais = d.Pais.Trim(); }

            // BLOQUE 1: Resumen Global (Nacional, Internacional)
            var globalMercados = datosValidos.GroupBy(d => d.Pais)
                                     .Select(g => CrearFilaDato(g.Key, g, true, true, mesActual))
                                     .OrderByDescending(f => f.Nombre)
                                     .ToList();

            response.ResumenGlobal.AddRange(globalMercados);

            // El Total Global es la suma de los resúmenes de cada mercado (N + I)
            response.TotalGlobal = new FilaDatoDto
            {
                Nombre = "TOTAL",
                Mensual = SumarValores(globalMercados.Select(m => m.Mensual)),
                Acumulado = SumarValores(globalMercados.Select(m => m.Acumulado))
            };

            CalcularPorcentajes(response.TotalGlobal.Mensual, 1);
            CalcularPorcentajes(response.TotalGlobal.Acumulado, mesActual);

            // BLOQUE 2: Desglose por SubDirGeneral (Ej: DG. Elecnor Servicios, DG. Elecnor Proyectos)
            response.DirNegocios = datosValidos
                .Where(d => !string.IsNullOrWhiteSpace(d.NombreSubDirGeneral))
                .GroupBy(d => d.NombreSubDirGeneral)
                .Select(gSDG => new DirNegocioItemDto
                {
                    Nombre = gSDG.Key!,
                    // Sub-bloque 1: Nacional/Internacional para esta DG
                    Mercados = gSDG.GroupBy(d => d.Pais)
                        .Select(gPais => CrearFilaDato(gPais.Key!, gPais, false, true, mesActual))
                        .OrderByDescending(f => f.Nombre)
                        .ToList(),
                    // Sub-bloque 2: Unidades de Negocio (DirNegocio) para esta DG
                    Unidades = gSDG.GroupBy(d => d.NombreDirNegocio)
                        .Select(gDN => CrearFilaDato(gDN.Key!, gDN, false, false, mesActual))
                        .OrderBy(f => f.Nombre)
                        .ToList(),
                    // Total de la DG
                    Total = new FilaDatoDto
                    {
                        Nombre = "TOTAL " + gSDG.Key,
                        Mensual = SumarValores(gSDG.GroupBy(p => p.Pais).Select(gP => CrearFilaDato(gP.Key!, gP, false, true, mesActual).Mensual)),
                        Acumulado = SumarValores(gSDG.GroupBy(p => p.Pais).Select(gP => CrearFilaDato(gP.Key!, gP, false, true, mesActual).Acumulado))
                    }
                })
                .OrderByDescending(d => d.Nombre)
                .ToList();

            // Calculamos porcentajes finales para los totales de cada DG
            foreach (var dn in response.DirNegocios)
            {
                CalcularPorcentajes(dn.Total.Mensual, 1);
                CalcularPorcentajes(dn.Total.Acumulado, mesActual);
            }

            return response;
        }

        private FilaDatoDto CrearFilaDato(string nombre, IEnumerable<MercadosPoco> datos, bool esResumenGlobal = false, bool esPais = false, int mesActual = 1)
        {
            decimal objetivoBase;

            if (esResumenGlobal)
            {
                // El objetivo global completo (vwObjetivosMercadoSQL)
                objetivoBase = datos.Any() ? datos.Max(d => d.ObjetivoPais) : 0;
            }
            else if (esPais)
            {
                objetivoBase = datos.Any() ? datos.Max(d => d.ObjetivoSDGPais) : 0;
            }
            else
            {
                // Desglose de unidades: tomar la suma del ImporteObjetivo individual de cada unidad inferior
                objetivoBase = datos.Sum(d => d.ImporteObjetivo);
            }

            var fila = new FilaDatoDto
            {
                Nombre = nombre,
                Mensual = new ValoresSeccionDto
                {
                    ImporteContratado = datos.Sum(d => d.ImporteContratado) / 1000,
                    ImporteObjetivo = objetivoBase / 12, // Objetivo mensual sin dividir por 1000
                },
                Acumulado = new ValoresSeccionDto
                {
                    ImporteContratado = datos.Sum(d => d.ImporteContratadoAcumulado) / 1000,
                    ImporteObjetivo = objetivoBase, // Objetivo anual sin dividir por 1000
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
                    seccion.Variacion = Math.Round(vContratacion * 100, 0, MidpointRounding.AwayFromZero).ToString() + "%";
                }
            }
        }
    }
}
