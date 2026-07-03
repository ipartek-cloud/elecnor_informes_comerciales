using System.Text;
using System.Data;
using System.Security.Claims;
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

// 1. Configuración de Serilog (Ruta dinámica: Raíz en Desarrollo, Binarios en Producción)
string logPath = builder.Environment.IsDevelopment()
    ? Path.Combine(builder.Environment.ContentRootPath, "Logs", "log_.txt")
    : Path.Combine(AppContext.BaseDirectory, "Logs", "log_.txt");

builder.Host.UseSerilog((context, configuration) => configuration
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft.AspNetCore.Hosting.Diagnostics", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.Hosting", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.Routing", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.Mvc", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.StaticFiles", Serilog.Events.LogEventLevel.Error)
    .MinimumLevel.Override("Microsoft.AspNetCore.Authorization", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.Authentication", Serilog.Events.LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore.DataProtection", Serilog.Events.LogEventLevel.Error)
    .MinimumLevel.Override("Microsoft.AspNetCore.ResponseCaching", Serilog.Events.LogEventLevel.Error)
    .MinimumLevel.Override("System.Net.Http", Serilog.Events.LogEventLevel.Warning)
    .WriteTo.Console(outputTemplate: "[{Timestamp:yyyy-MM-dd HH:mm:ss}] [{Usuario}] [{Level:u3}] {Message:lj}{NewLine}{Exception}")
    .WriteTo.File(logPath, 
        rollingInterval: RollingInterval.Day, 
        outputTemplate: "[{Timestamp:yyyy-MM-dd HH:mm:ss}] [{Usuario}] [{Level:u3}] {Message:lj}{NewLine}{Exception}"));

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
builder.Services.AddScoped<InformeCarteraDiferidaConsejoService>();
builder.Services.AddScoped<InformeMercadosService>();
builder.Services.AddScoped<InformeMercadosDGService>();
builder.Services.AddScoped<InformeMercadosSGDelegacionesService>();
builder.Services.AddScoped<InformePaisesService>();
builder.Services.AddScoped<InformeActividadesService>();
builder.Services.AddScoped<InformeActividadesObjetivosService>();
builder.Services.AddScoped<InformeContratacionesService>();
builder.Services.AddScoped<InformeContratacionesAIService>();
builder.Services.AddScoped<InformeRankingContratacionClientesService>();
builder.Services.AddScoped<InformeContratacionesSignificativasService>();
builder.Services.AddScoped<InformeContratacionesSignificativasRiService>();
builder.Services.AddScoped<InformeGerenciasService>();
builder.Services.AddScoped<InformeCarteraContratacionDetalleService>();
builder.Services.AddScoped<InformeCarteraContratacionDetalleOrgPaisesService>();
builder.Services.AddScoped<InformeCarteraContratacionDetallePaisesService>();
builder.Services.AddScoped<InformeCarteraContratacionResumenSDGService>();
builder.Services.AddScoped<InformeActividadesInternacionalDetalleService>();
builder.Services.AddScoped<InformeContratacionMercadosSDGDNService>();
builder.Services.AddScoped<InformeActividadesInstalacionesRedesService>();

// Opciones de Generación (Sincronización)
builder.Services.AddScoped<OpcionesGeneracionService>();

// Servicios de HTML Portable (Self-Contained)
builder.Services.AddMemoryCache();
builder.Services.AddSingleton<AssetInliningService>();
builder.Services.AddSingleton<HtmlAssemblerService>();
builder.Services.AddScoped<InformePortableService>();
builder.Services.AddSingleton<PdfPageNumberService>();
builder.Services.AddSingleton<IPdfGeneratorService, PdfGeneratorService>();
builder.Services.AddScoped<PdfRptService>();
builder.Services.AddScoped<HtmlRptService>();
builder.Services.AddScoped<InformeSeguridadService>();
Console.WriteLine("[DI] Servicios HTML Portable registrados.");
Console.WriteLine("[DI] Servicios de PDF registrados.");
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
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey!)),
        NameClaimType = ClaimTypes.Name,
        RoleClaimType = ClaimTypes.Role
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

// 8.1 Log de peticiones HTTP (API/controladores con método, ruta, query y body - excluye estáticos)
app.UseSerilogRequestLogging(options =>
{
    options.MessageTemplate = "HTTP {RequestMethod} {RequestPath}{RequestQuery} responded {StatusCode} in {Elapsed:0.0000} ms";
    options.GetLevel = (httpContext, elapsed, ex) =>
    {
        if (ex != null || httpContext.Response.StatusCode > 499)
            return Serilog.Events.LogEventLevel.Error;
        var path = httpContext.Request.Path.Value ?? "";
        if (path.StartsWith("/css", StringComparison.OrdinalIgnoreCase)
            || path.StartsWith("/js", StringComparison.OrdinalIgnoreCase)
            || path.StartsWith("/images", StringComparison.OrdinalIgnoreCase)
            || path.StartsWith("/favicon", StringComparison.OrdinalIgnoreCase)
            || path.StartsWith("/lib", StringComparison.OrdinalIgnoreCase))
            return Serilog.Events.LogEventLevel.Verbose;
        return Serilog.Events.LogEventLevel.Information;
    };
    options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
    {
        var qs = httpContext.Request.QueryString.Value;
        diagnosticContext.Set("RequestQuery", string.IsNullOrEmpty(qs) ? "" : $" {qs}");
        
        // Usuario desde token JWT
        var usuario = httpContext.User?.Identity?.Name ?? "ANONIMO";
        diagnosticContext.Set("Usuario", usuario);

        if (httpContext.Request.Method == "POST" || httpContext.Request.Method == "PUT" || httpContext.Request.Method == "PATCH")
        {
            if (httpContext.Request.ContentLength > 0 && httpContext.Request.ContentLength <= 4096)
            {
                try
                {
                    httpContext.Request.EnableBuffering();
                    httpContext.Request.Body.Position = 0;
                    using var reader = new StreamReader(httpContext.Request.Body, leaveOpen: true);
                    var body = reader.ReadToEndAsync().GetAwaiter().GetResult();
                    diagnosticContext.Set("RequestBody", body.Length > 2000 ? body[..2000] + "...(truncated)" : body);
                    httpContext.Request.Body.Position = 0;
                }
                catch { }
            }
        }
    };
});
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

// Middleware de seguridad de Informes
app.UseMiddleware<InformeSeguridadMiddleware>();

// 12. Mapeo de Rutas y Controladores
app.MapControllers();
app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");

Log.Information($">>> Aplicación iniciada - {DateTime.Now:dd/MM/yyyy HH:mm:ss} <<<");

app.Run();
