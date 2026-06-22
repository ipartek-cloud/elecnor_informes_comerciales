using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using Elecnor_Informes_Comerciales.Models;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Services;

public class TokenService
{
    private readonly IConfiguration _configuration;
    private readonly InformeSeguridadService _seguridadService;

    public TokenService(IConfiguration configuration, InformeSeguridadService seguridadService)
    {
        _configuration = configuration;
        _seguridadService = seguridadService;
    }

    public async Task<string> CreateTokenAsync(User user)
    {
        var informesClaim = await _seguridadService.ObtenerPermisosSerializadosAsync(user.Puesto, bypassCache: true);

        var claims = new List<Claim>
        {
            new(ClaimTypes.Name, user.Usuario),
            new(JwtRegisteredClaimNames.Sub, user.Usuario),
            new("NombreUsuario", user.NombreUsuario),
            new("Puesto", user.Puesto),
            new("CodEntidad", user.CodEntidad ?? string.Empty),
            new("InformesPermitidos", informesClaim)
        };

        var jwtSettings = _configuration.GetSection("JWT");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["ClaveSecreta"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256Signature);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddHours(Convert.ToDouble(jwtSettings["CaducidadHoras"])),
            Issuer = jwtSettings["Issuer"],
            Audience = jwtSettings["Audience"],
            SigningCredentials = creds
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);

        return tokenHandler.WriteToken(token);
    }
}
