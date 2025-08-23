using System.Net;
using System.Text.Json;

namespace EmployeePayrollAPI.Middleware
{
    public class ErrorHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ErrorHandlingMiddleware> _logger;

        public ErrorHandlingMiddleware(RequestDelegate next, ILogger<ErrorHandlingMiddleware> logger) 
        {
            _next = next;
            _logger = logger;
        }
    public async Task InvokeAsync(HttpContext context)
        {
            try
            { 
                await _next(context); //go to next middleware/ controller
            }
            catch (Exception ex) 
            {
                _logger.LogError(ex, "Unhandled Error");
                await HandleExceptionAsync(context, ex);
            }
        }
        private Task HandleExceptionAsync(HttpContext context, Exception ex)
        {
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;

            var response = new
            {
                StatusCode = context.Response.StatusCode,
                Message = ex.Message,
                Details = ex.InnerException?.Message
            };
            
            var json = JsonSerializer.Serialize(response);
            return context.Response.WriteAsync(json);
        }

    }
}
