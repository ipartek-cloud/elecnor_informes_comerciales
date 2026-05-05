namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetalle;

/// <summary>
/// POCO que mapea el resultset del SP
/// spCarteraContratacionDetalle_DGDesarrolloInternacional_DosAños (@pInforme='9.1').
/// El SP devuelve 10 columnas; la tabla temporal solo almacena 8 de ellas.
/// </summary>
public class CarteraContratacionDetallePoco
{
    public int AnioInforme { get; set; }
    public int MesInforme { get; set; }
    public string? Pais { get; set; }
    public string? NomCliente { get; set; }
    public string? DesOferta { get; set; }
    public decimal? ImporteCarteraOferta { get; set; }
    public decimal? ImporteContratadoOferta { get; set; }
    public decimal? ImporteCarteraPais { get; set; }
    public decimal? ImporteCarteraPaisAñoAnterior { get; set; }
    public decimal? ImporteCarteraOfertaAñoAnterior { get; set; }
}
