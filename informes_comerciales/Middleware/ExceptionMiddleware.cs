using System.Net;
using System.Text.Json;
using Elecnor_Informes_Comerciales.DTOs.Errors;

namespace Elecnor_Informes_Comerciales.Middleware;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;
    private readonly IHostEnvironment _env;

    public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger, IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            // Construir información contextual de la petición para el log
            var request = context.Request;
            var url = $"{request.Path}{request.QueryString}";
            var method = request.Method;
            var userAgent = request.Headers["User-Agent"].ToString();
            var requestId = context.TraceIdentifier;

            // Log enriquecido con información completa de la petición
            _logger.LogError(ex,
                "Excepción no controlada en {Method} {Url} - {Message}",
                method,
                url,
                ex.Message);

            // Información adicional para debugging (nivel Debug)
            _logger.LogDebug(
                "Detalles: Method={Method}, Path={Path}, QueryString={QueryString}, UserAgent={UserAgent}, RequestId={RequestId}",
                method,
                request.Path,
                request.QueryString,
                userAgent,
                requestId);

            // Si es una llamada al API REST, devolvemos JSON
            if (context.Request.Path.StartsWithSegments("/api"))
            {
                context.Response.ContentType = "application/json";
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

                var response = _env.IsDevelopment()
                    ? new ApiErrorResponse(context.Response.StatusCode, ex.Message, ex.StackTrace?.ToString())
                    : new ApiErrorResponse(context.Response.StatusCode, "Ocurrió un error interno en el servidor.");

                var options = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
                var json = JsonSerializer.Serialize(response, options);

                await context.Response.WriteAsync(json);
            }
            else
            {
                // Si es un controlador MVC, propagamos la excepción para que el gestor por defecto
                // (UseExceptionHandler o vista desarrollador) intercepte y devuelva HTML.
                throw;
            }
        }
    }
}


