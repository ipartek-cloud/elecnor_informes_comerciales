using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.GerenciasTotalesCruces;

public class GerenciasTotalesCrucesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<GrupoOrdenDto> GruposOrden { get; set; } = new();
    public TotalesEstandarDto TotalGeneral { get; set; } = new();
}

public class GrupoOrdenDto
{
    public string Orden { get; set; } = string.Empty;
    public List<GrupoGerenciaDto> Gerencias { get; set; } = new();
}

public class GrupoGerenciaDto
{
    public string NombreGerente { get; set; } = string.Empty;
    public string Mercado { get; set; } = string.Empty;
    public List<BloqueDireccionNegocioDto> BloquesDN { get; set; } = new();
    public TotalesEstandarDto TotalGerencia { get; set; } = new();
}

public class BloqueDireccionNegocioDto
{
    public string CodDDirNegocio { get; set; } = string.Empty;
    public string NombreDirNegocio { get; set; } = string.Empty;
    public int? OrdenCodDDirNegocio { get; set; }
    public bool MostrarNotaDN800 { get; set; }
    public List<CentroItemDto> Centros { get; set; } = new();
    public TotalesEstandarDto TotalDN { get; set; } = new();
}

public class CentroItemDto
{
    public string CodCentro { get; set; } = string.Empty;
    public string NombreCentro { get; set; } = string.Empty;
    public decimal ObjetivoMensual { get; set; }
    public decimal ContratacionMensual { get; set; }
    public decimal ObjetivoAnual { get; set; }
    public decimal ContratacionAcumulada { get; set; }
    public decimal IndiceProduccion { get; set; }
    public decimal AnoAnterior { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
    public string VariacionCartera { get; set; } = string.Empty;
    public decimal CarteraPdteAñoActual { get; set; }
    public decimal CarteraPdteAñoAnterior { get; set; }
}
