using System.Text;
using System.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Data.SqlClient;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Elecnor_Informes_Comerciales.Repositories;
using Elecnor_Informes_Comerciales.Services;
using Elecnor_Informes_Comerciales.Middleware;
using Elecnor_Informes_Comerciales.DTOs.Errors;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes;
using Serilog;
using System.Text.Json;

// ===============================================================================
//                      INICIO CONFIGURACIÓN APLICACIÓN
// ===============================================================================

var builder = WebApplication.CreateBuilder(args);

// 1. Configuración de Serilog
builder.Host.UseSerilog((context, configuration) => configuration
    .WriteTo.Console()
    .WriteTo.File(Path.Combine(AppContext.BaseDirectory, "Logs", "log_.txt"), rollingInterval: RollingInterval.Day));

// 2. Agregar soporte para Controladores con Vistas (MVC) e Inyectar Caching
builder.Services.AddControllersWithViews();
builder.Services.AddResponseCaching();

// 3. Configurar IDbConnection (SqlConnection) para Dapper
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddScoped<IDbConnection>(_ => new SqlConnection(connectionString));

// 4. Registrar servicios y repositorios para Inyección de Dependencias
builder.Services.AddScoped<UserRepository>();
builder.Services.AddScoped<TokenService>();

// Autenticación
builder.Services.AddSingleton<ActiveDirectoryService>();
builder.Services.AddScoped<AuthenticationService>();
Console.WriteLine("[AUTH] Servicios de autenticación registrados.");

// Informes
builder.Services.AddScoped<InformeRepository>();
builder.Services.AddScoped<InformeGerenciasTotalesCrucesService>();
builder.Services.AddScoped<InformeContratacionMercadosAIService>();
builder.Services.AddScoped<InformeMercadosService>();
builder.Services.AddScoped<InformePaisesService>();
builder.Services.AddScoped<InformeActividadesService>();
builder.Services.AddScoped<InformeContratacionesService>();
builder.Services.AddScoped<InformeContratacionesAIService>();
builder.Services.AddScoped<InformeRankingContratacionClientesService>();
builder.Services.AddScoped<InformeContratacionesSignificativasService>();
Console.WriteLine("[DI] Servicios y repositorios registrados.");

// Catálogos
builder.Services.AddScoped<CatalogoService>();
Console.WriteLine("[DI] Servicio de catálogos registrado.");

// 5. Configurar Autenticación JWT
var jwtSettings = builder.Configuration.GetSection("JWT");
var secretKey = jwtSettings["ClaveSecreta"];

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey!))
    };

    // Personalizar respuesta cuando falla la autenticación (401)
    options.Events = new JwtBearerEvents
    {
        OnChallenge = context =>
        {
            context.HandleResponse();
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            context.Response.ContentType = "application/json";

            var response = new ApiErrorResponse(401, "No autorizado: Token inválido o expirado.");
            return context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    };
});
Console.WriteLine("[AUTH] Autenticación JWT configurada.");

// 6. Configurar Swagger/OpenAPI con soporte para JWT
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Elecnor Informes Comerciales", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Authorization header usando el esquema Bearer.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement {
        {
            new OpenApiSecurityScheme {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            new List<string>()
        }
    });
});
Console.WriteLine("[API] Swagger/OpenAPI configurado.");

// ===============================================================================
// CONSTRUCCIÓN DE LA APLICACIÓN (APP BUILD)
// ===============================================================================

var app = builder.Build();

// 7. Verificar conexión a la base de datos al inicio (Fail-Fast)
Console.WriteLine("[DB] Verificando conexión DB...");
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var logger = services.GetRequiredService<ILogger<Program>>();
    try
    {
        using var connection = services.GetRequiredService<IDbConnection>();
        connection.Open();

        var sqlConnection = (SqlConnection)connection;
        Console.WriteLine($"[DB] Conexión exitosa a {sqlConnection.DataSource} (Base: {sqlConnection.Database})");

        connection.Close();
    }
    catch (Exception ex)
    {
        var connStr = builder.Configuration.GetConnectionString("DefaultConnection");
        var sb = new SqlConnectionStringBuilder(connStr);
        var errorMsg = $"Error crítico al intentar conectar con SQL ({sb.DataSource}) en DB '{sb.InitialCatalog}'.";

        logger.LogCritical(ex, errorMsg);
        Console.WriteLine($"\n[FATAL] {errorMsg}");
        return;
    }
}

// 8. Registro del Middleware de Excepciones Global
app.UseMiddleware<ExceptionMiddleware>();

// 9. Configuración del Entorno (Desarrollo vs Producción)
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    Console.WriteLine("[PIPELINE] Usando Developer Exception Page.");

    app.UseSwagger();
    app.UseSwaggerUI();
    Console.WriteLine("[PIPELINE] Swagger UI habilitado.");
}
else
{
    app.UseExceptionHandler("/Home/Error");
}

// 10. Configuración de Redirección y Archivos Estáticos
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseResponseCaching();

// 11. Habilitar Autenticación y Autorización
app.UseAuthentication();
app.UseAuthorization();

// 12. Mapeo de Rutas y Controladores
app.MapControllers();
app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");

Log.Information($">>> Aplicación iniciada - {DateTime.Now:dd/MM/yyyy HH:mm:ss} <<<");

app.Run();
