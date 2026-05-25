using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.MercadosSGDelegaciones;

public class MercadosSGDelegacionesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<SubDirGeneralDto> SubDireccionesGenerales { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

public class SubDirGeneralDto
{
    public string NombreSubDirGeneral { get; set; } = string.Empty;
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public int OrdenSubDirGeneral { get; set; }
    public List<DirNegocioDto> DireccionesNegocio { get; set; } = new();
    public TotalesSDGDto Totales { get; set; } = new();
}

public class DirNegocioDto
{
    public string NombreDirNegocio { get; set; } = string.Empty;
    public int? Orden_CodDDirNegocio { get; set; }
    public List<AreaDto> Areas { get; set; } = new();
    public TotalesDNDto Totales { get; set; } = new();
}

public class AreaDto
{
    public string Area { get; set; } = string.Empty;
    public List<DelegacionDto> Delegaciones { get; set; } = new();
}

public class DelegacionDto
{
    public string NombreDelegacion { get; set; } = string.Empty;
    public string CodDelegacion { get; set; } = string.Empty;
    public MetricasMensualesDto Mensual { get; set; } = new();
    public MetricasAcumuladasDto Acumulado { get; set; } = new();
    public VariacionesDto Variaciones { get; set; } = new();
}

public class MetricasMensualesDto
{
    public decimal Objetivos { get; set; }
    public decimal Contratacion { get; set; }
}

public class MetricasAcumuladasDto
{
    public decimal Objetivos { get; set; }
    public decimal Contratacion { get; set; }
    public decimal IP { get; set; }
}

public class VariacionesDto
{
    public string Contratacion { get; set; } = string.Empty;
    public string Cartera { get; set; } = string.Empty;
}

public class TotalesSDGDto
{
    public decimal ObjetivosMensual { get; set; }
    public decimal ContratacionMensual { get; set; }
    public decimal ObjetivosAcumulado { get; set; }
    public decimal ContratacionAcumulado { get; set; }
    public decimal IP { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
    public string VariacionCartera { get; set; } = string.Empty;
}

public class TotalesDNDto
{
    public decimal ObjetivosMensual { get; set; }
    public decimal ContratacionMensual { get; set; }
    public decimal ObjetivosAcumulado { get; set; }
    public decimal ContratacionAcumulado { get; set; }
    public decimal IP { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
    public string VariacionCartera { get; set; } = string.Empty;
    public ResumenNacionalInternacionalDto Resumen { get; set; } = new();
}

public class ResumenNacionalInternacionalDto
{
    public decimal ObjetivosMensualNacional { get; set; }
    public decimal ContratacionMensualNacional { get; set; }
    public decimal ObjetivosAcumuladoNacional { get; set; }
    public decimal ContratacionAcumuladoNacional { get; set; }
    public decimal IpNacional { get; set; }

    public decimal ObjetivosMensualInternacional { get; set; }
    public decimal ContratacionMensualInternacional { get; set; }
    public decimal ObjetivosAcumuladoInternacional { get; set; }
    public decimal ContratacionAcumuladoInternacional { get; set; }
    public decimal IpInternacional { get; set; }
}
