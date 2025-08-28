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
            using var conn = _db.CreateConnection();
            
            string sql = @"
                SELECT 
                    LogId,
                    TableName,
                    Action,
                    ChangedBy,
                    NewValues,
                    ChangeDate
                FROM AuditLogs 
                WHERE ChangedBy LIKE '%' + CAST(@EmployeeId AS NVARCHAR) + '%' 
                   OR NewValues LIKE '%EmployeeId: ' + CAST(@EmployeeId AS NVARCHAR) + '%'
                ORDER BY ChangeDate DESC";
                
            var data = await conn.QueryAsync<AuditLogDto>(sql, new { EmployeeId = employeeId });
            return data;
        }

        // Insert login entry
        public async Task<(string StatusCode, string Message)> LogLoginAsync(int employeeId)
        {
            using var conn = _db.CreateConnection();
            
            try
            {
                string sql = @"
                    INSERT INTO AuditLogs (TableName, Action, ChangedBy, NewValues, ChangeDate)
                    VALUES ('Employees', 'LOGIN', 
                            (SELECT FullName FROM Employees WHERE EmployeeId = @EmployeeId), 
                            'Employee ' + (SELECT FullName FROM Employees WHERE EmployeeId = @EmployeeId) + ' logged in at ' + CONVERT(NVARCHAR, GETDATE(), 120),
                            GETDATE())";
                            
                await conn.ExecuteAsync(sql, new { EmployeeId = employeeId });
                return ("Success", "Login logged successfully");
            }
            catch (Exception ex)
            {
                return ("Error", $"Failed to log login: {ex.Message}");
            }
        }


    }
}
