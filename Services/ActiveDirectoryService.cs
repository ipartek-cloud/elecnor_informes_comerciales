using System.DirectoryServices.AccountManagement;

namespace Elecnor_Informes_Comerciales.Services;

/// <summary>
/// Servicio para validación de credenciales contra Active Directory
/// </summary>
public class ActiveDirectoryService
{
    private readonly string _servidor;
    private readonly string _baseDN;
    private readonly string _dominio;
    private readonly string _usuarioServicio;
    private readonly string _passwordServicio;

    public ActiveDirectoryService(IConfiguration configuration)
    {
        var adConfig = configuration.GetSection("ActiveDirectory");

        _servidor = adConfig["Server"] ?? throw new ArgumentNullException("LDAP Server no configurado");
        _baseDN = adConfig["BaseDN"] ?? throw new ArgumentNullException("BaseDN no configurado");
        _dominio = adConfig["Dominio"] ?? throw new ArgumentNullException("Dominio no configurado");
        _usuarioServicio = adConfig["ServiceAccount:Username"] ?? throw new ArgumentNullException("ServiceAccount Username no configurado");
        _passwordServicio = adConfig["ServiceAccount:Password"] ?? throw new ArgumentNullException("ServiceAccount Password no configurado");
    }

    /// <summary>
    /// Valida las credenciales del usuario contra el Directorio Activo
    /// </summary>
    public bool ValidarCredenciales(string usuario, string password)
    {
        if (string.IsNullOrEmpty(usuario) || string.IsNullOrEmpty(password))
            return false;

        PrincipalContext? context = null;
        UserPrincipal? userPrincipal = null;

        try
        {
            // Crear contexto de conexión al dominio usando la cuenta de servicio
            context = new PrincipalContext(
                ContextType.Domain,
                _servidor,
                _baseDN,
                _usuarioServicio,
                _passwordServicio
            );

            // Validar credenciales del usuario
            bool credencialesValidas = context.ValidateCredentials(usuario, password);

            if (!credencialesValidas)
            {
                // Verificar si el usuario existe
                userPrincipal = UserPrincipal.FindByIdentity(context, IdentityType.SamAccountName, usuario);

                if (userPrincipal == null)
                {
                    return false; // Usuario no encontrado
                }

                // Verificar si está deshabilitado
                if (userPrincipal.Enabled == false)
                {
                    userPrincipal.Dispose();
                    return false; // Usuario deshabilitado
                }

                userPrincipal.Dispose();
                return false; // Contraseña incorrecta
            }

            return true; // Credenciales válidas
        }
        catch (PrincipalServerDownException)
        {
            Console.WriteLine($"Servidor AD no disponible: {_servidor}");
            return false;
        }
        catch (TimeoutException)
        {
            Console.WriteLine($"Timeout conectando a {_servidor}");
            return false;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error validando usuario {usuario}: {ex.Message}");
            return false;
        }
        finally
        {
            userPrincipal?.Dispose();
            context?.Dispose();
        }
    }

    /// <summary>
    /// Obtiene el nombre completo del usuario desde AD
    /// </summary>
    public string? GetNombreCompleto(string usuario)
    {
        return GetUserInfo(usuario)?.FullName;
    }

    /// <summary>
    /// Obtiene información del usuario desde AD
    /// </summary>
    private AdUserInfo? GetUserInfo(string usuario)
    {
        PrincipalContext? context = null;
        UserPrincipal? userPrincipal = null;

        try
        {
            context = new PrincipalContext(
                ContextType.Domain,
                _servidor,
                _baseDN,
                _usuarioServicio,
                _passwordServicio
            );

            userPrincipal = UserPrincipal.FindByIdentity(context, IdentityType.SamAccountName, usuario);

            if (userPrincipal == null)
            {
                userPrincipal = UserPrincipal.FindByIdentity(context, IdentityType.UserPrincipalName, usuario);
            }

            if (userPrincipal == null)
                return null;

            return new AdUserInfo
            {
                Username = userPrincipal.SamAccountName ?? usuario,
                FullName = userPrincipal.DisplayName ?? userPrincipal.Name ?? usuario,
                Email = userPrincipal.EmailAddress,
                IsEnabled = userPrincipal.Enabled ?? false
            };
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error obteniendo información de {usuario}: {ex.Message}");
            return null;
        }
        finally
        {
            userPrincipal?.Dispose();
            context?.Dispose();
        }
    }

    /// <summary>
    /// Obtiene la Unidad Organizativa del usuario
    /// </summary>
    public string? GetUnidadOrganizativa(string usuario)
    {
        // Nota: AccountManagement no expone directamente el DN completo
        // Se podría implementar con DirectoryEntry si es estrictamente necesario
        return null;
    }
}

/// <summary>
/// Información de usuario de Active Directory
/// </summary>
public class AdUserInfo
{
    public string Username { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public bool IsEnabled { get; set; }
}
