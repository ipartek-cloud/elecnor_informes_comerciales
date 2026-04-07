using System.ComponentModel.DataAnnotations;

namespace Elecnor_Informes_Comerciales.DTOs.Auth;

public class LoginRequestDto
{
    [Required(ErrorMessage = "El nombre de usuario es obligatorio.")]
    [StringLength(20, MinimumLength = 1, ErrorMessage = "El nombre de usuario debe tener entre 1 y 20 caracteres.")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "La contraseña es obligatoria.")]
    public string Password { get; set; } = string.Empty;
}



