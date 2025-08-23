using EmployeePayrollAPI.Models.DTOs;

namespace EmployeePayrollAPI.Repositories
{
    public interface IAuditRepository
    {

        Task<IEnumerable<AuditLogDto>> GetAuditLogAsync(int employeeId);
        Task<(string StatusCode, string Message)> LogLoginAsync(int employeeId);

    }
}
