using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.DTOs.Auth;
using Elecnor_Informes_Comerciales.Repositories;
using Elecnor_Informes_Comerciales.Services;

namespace Elecnor_Informes_Comerciales.Controllers;

[Route("api/[controller]")]
[ApiController]
public class LoginController : ControllerBase
{
    private readonly AuthenticationService _authenticationService;
    private readonly UserRepository _userRepository;
    private readonly TokenService _tokenService;

    public LoginController( AuthenticationService authenticationService, UserRepository userRepository, TokenService tokenService)
    {
        _authenticationService = authenticationService;
        _userRepository = userRepository;
        _tokenService = tokenService;
    }

    [HttpPost]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponseDto>> Login(LoginRequestDto loginRequest)
    {
        if (!ModelState.IsValid)
        {
            return Unauthorized(new { message = "Credenciales inválidas." });
        }

        // Validar credenciales (PassMaster + Active Directory)
        var authResult = await _authenticationService.ValidarUsuarioAsync(loginRequest.Username, loginRequest.Password);

        if (!authResult.Success)
        {
            return Unauthorized(new { message = authResult.ErrorMessage });
        }

        // Verificar usuario en BD con Acceso_Informes = 1
        var user = await _userRepository.GetByUsernameAsync(authResult.Usuario!);

        if (user == null)
        {
            return Unauthorized(new { message = "Usuario no tiene acceso a informes." });
        }

        // Generar token JWT
        var token = await _tokenService.CreateTokenAsync(user);

        return Ok(new LoginResponseDto { Token = token });
    }
}
