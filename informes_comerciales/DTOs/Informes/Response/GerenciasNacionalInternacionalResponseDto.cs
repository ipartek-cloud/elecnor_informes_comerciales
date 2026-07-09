namespace Elecnor_Informes_Comerciales.DTOs.Informes.Response;

/// <summary>
/// DTO raíz del informe Gerencias Nacional/Internacional.
/// Contiene 3 bloques: Total, Nacional e Internacional.
/// Cada bloque está dividido en grupos de gerencias (SumarizaGerentes).
/// </summary>
public class GerenciasNacionalInternacionalResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public BloqueGerenciasDto Total { get; set; } = new();
    public BloqueGerenciasDto Nacional { get; set; } = new();
    public BloqueGerenciasDto Internacional { get; set; } = new();
}

/// <summary>
/// Un bloque de gerencias (Total, Nacional o Internacional).
/// </summary>
public class BloqueGerenciasDto
{
    public string TituloBloque { get; set; } = "";
    public string SubtituloBloque { get; set; } = "";
    public string Linea1 { get; set; } = "";
    public string Linea2 { get; set; } = "";
    public List<GrupoGerenciasDto> Grupos { get; set; } = new();
    public TotalesEstandarDto TotalBloque { get; set; } = new();
}

/// <summary>
/// Grupo de gerencias dentro de un bloque (ej: "Construcción y Agua", "Electricidad").
/// </summary>
public class GrupoGerenciasDto
{
    public string NombreGrupo { get; set; } = "";
    public List<GerenciaItemDto> Gerencias { get; set; } = new();
    public TotalesEstandarDto Subtotal { get; set; } = new();
}
