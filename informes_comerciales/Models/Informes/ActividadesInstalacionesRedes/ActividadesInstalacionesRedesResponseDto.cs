using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.ActividadesInstalacionesRedes;

/// <summary>Respuesta del informe "Actividades SDG" con 3 secciones: DG, Nacional, Internacional.</summary>
public class ActividadesInstalacionesRedesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<SeccionMercadoDto> Secciones { get; set; } = new();
}

public class SeccionMercadoDto
{
    public string Mercado { get; set; } = string.Empty;     // "" (DG/Total) | "Nacional" | "Internacional"
    public string MercadoBadge { get; set; } = string.Empty;
    public List<ActividadBloqueDto> Actividades { get; set; } = new();
    public decimal TotalContrat { get; set; }
    public decimal TotalContratAnterior { get; set; }
    public decimal TotalObjetivos { get; set; }
    public decimal Ip { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
}

public class ActividadBloqueDto
{
    public int Orden { get; set; }
    public string Actividad { get; set; } = string.Empty;
    public decimal TotalContrat { get; set; }
    public decimal TotalContratAnterior { get; set; }
    public decimal TotalObjetivos { get; set; }
    public decimal Ip { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
    public List<SubActividadBloqueDto> SubActividades { get; set; } = new();
}

public class SubActividadBloqueDto
{
    public string SubActividad { get; set; } = string.Empty;
    public decimal TotalContrat { get; set; }
    public decimal TotalContratAnterior { get; set; }
    public decimal TotalObjetivos { get; set; }
    public decimal Ip { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
}
