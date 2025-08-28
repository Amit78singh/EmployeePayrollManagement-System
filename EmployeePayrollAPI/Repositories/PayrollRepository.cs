using Dapper;
using EmployeePayrollAPI.Infrastructure;
using EmployeePayrollAPI.Models.DTOs;
using System.Data;

namespace EmployeePayrollAPI.Repositories
{
    public class PayrollRepository: IPayrollRepository
    {
        private readonly IDbConnectionFactory _db;

        public PayrollRepository(IDbConnectionFactory db)
        {
            _db = db;
        }
        
        public async Task CalculateMonthlySalaryAsync(int employeeId, int year, int month)
        {
            using var conn = _db.CreateConnection();
            var p = new DynamicParameters();
            p.Add("@EmployeeId", employeeId);
            p.Add("@Year", year);
            p.Add("@Month", month);
            p.Add("@BasicSalary", 50000);
            p.Add("@HRA", 5000);
            p.Add("@DA", 2000);
            p.Add("@Deductions", 1000);

            await conn.ExecuteAsync("usp_Payroll_Calculate",
                p, commandType: CommandType.StoredProcedure);
        }
        
        public async Task GenerateMonthlyAsync(PayrollCalculateDto dto)
        { 
            using var conn = _db.CreateConnection();

            var p = new DynamicParameters();
            p.Add("@EmployeeId", dto.EmployeeId);
            p.Add("@Month", dto.Month);
            p.Add("@Year", dto.Year);
            p.Add("@BasicSalary", dto.BasicSalary);
            p.Add("@HRA", dto.HRA);
            p.Add("@DA", dto.DA);
            p.Add("@Deductions", dto.LeaveDeductions);

            await conn.ExecuteAsync("usp_Payroll_Calculate",
                p, commandType: CommandType.StoredProcedure);
        }

        public async Task<dynamic> GetSlipAsync(int employeeId, int year, int month)
        {
            using var conn = _db.CreateConnection();
            
            string sql = @"
                SELECT 
                    p.PayrollId,
                    p.EmployeeId,
                    e.FullName as EmployeeName,
                    p.Month,
                    p.Year,
                    p.BasicSalary,
                    p.HRA,
                    p.DA,
                    p.Deductions,
                    p.NetSalary,
                    p.GeneratedOn
                FROM Payroll p
                INNER JOIN Employees e ON p.EmployeeId = e.EmployeeId
                WHERE p.EmployeeId = @EmployeeId AND p.Year = @Year AND p.Month = @Month";
                
            return await conn.QueryFirstOrDefaultAsync<dynamic>(sql, new { EmployeeId = employeeId, Year = year, Month = month });
        }

        public async Task<IEnumerable<dynamic>> GetAllPayrollRecordsAsync()
        {
            using var conn = _db.CreateConnection();
            return await conn.QueryAsync(@"
                SELECT 
                    p.PayrollId,
                    p.EmployeeId,
                    e.FullName as EmployeeName,
                    p.Month,
                    p.Year,
                    p.BasicSalary,
                    p.HRA,
                    p.DA,
                    p.Deductions,
                    p.NetSalary,
                    p.GeneratedOn
                FROM Payroll p
                INNER JOIN Employees e ON p.EmployeeId = e.EmployeeId
                WHERE e.IsActive = 1
                ORDER BY p.Year DESC, p.Month DESC, e.FullName");
        }
    }
}
