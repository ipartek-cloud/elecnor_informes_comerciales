using System.Data;
using Dapper;
using Elecnor_Informes_Comerciales.Models;

namespace Elecnor_Informes_Comerciales.Repositories;

public class UserRepository
{
    private readonly IDbConnection _connection;

    public UserRepository(IDbConnection connection)
    {
        _connection = connection;
    }

    public async Task<User?> GetByUsernameAsync(string username)
    {
        const string sql = @"SELECT Usuario,
                                    NombreUsuario,
                                    Usuario AS Password,
                                    Puesto,
                                    CodEntidad
                            FROM   
                                    dbo.WEB_Usuarios
                            WHERE  
                                        LOWER(Usuario) = LOWER(@Username)
                                    AND Acceso_Informes = 1";

        return await _connection.QueryFirstOrDefaultAsync<User>(sql, new { Username = username });
    }
}
