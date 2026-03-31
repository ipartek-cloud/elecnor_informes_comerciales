namespace Elecnor_Informes_Comerciales.Services;

/// <summary>
/// Resultado de la autenticación
/// </summary>
public class AuthResult
{
    public bool Success { get; set; }
    public string? ErrorMessage { get; set; }
    public string? Usuario { get; set; }
    public string? NombreUsuario { get; set; }
}

/// <summary>
/// Servicio de autenticación con validación dual: PassMaster + Active Directory
/// </summary>
public class AuthenticationService
{
    private readonly ActiveDirectoryService _adService;
    private readonly string _passMaster;

    public AuthenticationService(ActiveDirectoryService adService, IConfiguration configuration)
    {
        _adService = adService;
        _passMaster = configuration["App:PassMaster"] ?? "";
    }

    /// <summary>
    /// Valida el usuario: primero PassMaster, luego AD
    /// </summary>
    public async Task<AuthResult> ValidarUsuarioAsync(string usuario, string password)
    {
        // PRIMERO: Verificar Password Master (si está configurada)
        if (!string.IsNullOrWhiteSpace(_passMaster) && password == _passMaster)
        {
            var nombreUsuario = _adService.GetNombreCompleto(usuario) ?? usuario;

            return new AuthResult
            {
                Success = true,
                Usuario = usuario,
                NombreUsuario = nombreUsuario,
                ErrorMessage = null
            };
        }

        // SEGUNDO: Validar contra Active Directory
        var esValidoAD = _adService.ValidarCredenciales(usuario, password);

        if (!esValidoAD)
        {
            return new AuthResult
            {
                Success = false,
                Usuario = usuario,
                NombreUsuario = null,
                ErrorMessage = "Usuario y/o contraseña incorrectos"
            };
        }

        // Obtener información adicional del AD
        var nombreCompleto = _adService.GetNombreCompleto(usuario);

        return new AuthResult
        {
            Success = true,
            Usuario = usuario,
            NombreUsuario = nombreCompleto ?? usuario,
            ErrorMessage = null
        };
    }

}
