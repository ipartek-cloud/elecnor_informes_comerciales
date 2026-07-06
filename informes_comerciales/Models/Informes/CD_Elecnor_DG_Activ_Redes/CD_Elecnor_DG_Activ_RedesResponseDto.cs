using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.CD_Elecnor_DG_Activ_Redes;

/// <summary>Respuesta del informe "Actividades x DN" - Sin Objetivos ni IP.</summary>
public class CD_Elecnor_DG_Activ_RedesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<SeccionMercadoDNDto> Secciones { get; set; } = new();
}

public class SeccionMercadoDNDto
{
    public string Mercado { get; set; } = string.Empty;
    public string MercadoBadge { get; set; } = string.Empty;
    public List<ActividadBloqueDNDto> Actividades { get; set; } = new();
    public decimal TotalContrat { get; set; }
    public decimal TotalContratAnterior { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
}

public class ActividadBloqueDNDto
{
    public int Orden { get; set; }
    public string Actividad { get; set; } = string.Empty;
    public decimal TotalContrat { get; set; }
    public decimal TotalContratAnterior { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
    public List<SubActividadBloqueDNDto> SubActividades { get; set; } = new();
}

public class SubActividadBloqueDNDto
{
    public string SubActividad { get; set; } = string.Empty;
    public decimal TotalContrat { get; set; }
    public decimal TotalContratAnterior { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
}
