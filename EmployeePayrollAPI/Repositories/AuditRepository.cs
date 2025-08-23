using Dapper;
using EmployeePayrollAPI.Infrastructure;
using EmployeePayrollAPI.Models.DTOs;
using System.Data;

namespace EmployeePayrollAPI.Repositories
{
    public class AuditRepository:IAuditRepository
    {
        private readonly IDbConnectionFactory _db;

        public AuditRepository(IDbConnectionFactory db)
        {
          _db = db;
        }

        // Fetch logs
        public async Task<IEnumerable<AuditLogDto>> GetAuditLogAsync(int employeeId)
        {
            // No parameters in this SP — if it requires dates or anything
            // \include them here.
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EmployeeId", employeeId);

            var data = await conn.QueryAsync<AuditLogDto>(
            "dbo.usp_AuditLogs_GetByEmployee", p, commandType: CommandType.StoredProcedure);

            return data;

        }

        // Insert login entry
        public async Task<(string StatusCode, string Message)> LogLoginAsync(int employeeId)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EmployeeId", employeeId);

            var result = await conn.QueryFirstOrDefaultAsync<dynamic>(
                "dbo.usp_Employee_LoginAudit", p, commandType: CommandType.StoredProcedure);

            string statusCode = Convert.ToString(result?.StatusCode);
            string message = Convert.ToString(result?.Message);
            return (statusCode, message);
        }


    }
}
